#include "pty_session.h"
#include <shlwapi.h>
#pragma comment(lib, "shlwapi.lib")

// ── Shell Detection ─────────────────────────────────────────
std::wstring PtySession::DetectShell() {
    // Prefer ExoShell — our custom shell that uses raw console input,
    // avoiding the ConPTY cooked-read double-prompt bug entirely.
    wchar_t exePath[MAX_PATH];
    GetModuleFileNameW(nullptr, exePath, MAX_PATH);

    // Replace the exe name with ExoShell.exe
    wchar_t* lastSlash = wcsrchr(exePath, L'\\');
    if (lastSlash) {
        wcscpy_s(lastSlash + 1, MAX_PATH - (lastSlash - exePath + 1), L"ExoShell.exe");
        if (GetFileAttributesW(exePath) != INVALID_FILE_ATTRIBUTES) {
            return exePath;
        }
    }

    // Fall back to cmd.exe
    return L"cmd.exe";
}

// ── Start ───────────────────────────────────────────────────
bool PtySession::Start(int cols, int rows) {
    Close();  // clean up any existing session

    // Create pipes: shell reads from pipeInRead, writes to pipeOutWrite
    HANDLE pipeInRead = nullptr, pipeOutWrite = nullptr;

    if (!CreatePipe(&pipeInRead, &m_pipeIn, nullptr, 0)) return false;
    if (!CreatePipe(&m_pipeOut, &pipeOutWrite, nullptr, 0)) {
        CloseHandle(pipeInRead); CloseHandle(m_pipeIn);
        return false;
    }

    // Create the pseudo-console
    COORD size{static_cast<SHORT>(cols), static_cast<SHORT>(rows)};
    HRESULT hr = CreatePseudoConsole(size, pipeInRead, pipeOutWrite, 0, &m_hPC);

    // Close the child-side handles — ConPTY owns them now
    CloseHandle(pipeInRead);
    CloseHandle(pipeOutWrite);

    if (FAILED(hr)) {
        CloseHandle(m_pipeIn);  m_pipeIn = nullptr;
        CloseHandle(m_pipeOut); m_pipeOut = nullptr;
        return false;
    }

    // Set up process attributes with the pseudo-console
    SIZE_T attrSize = 0;
    InitializeProcThreadAttributeList(nullptr, 1, 0, &attrSize);
    auto attrList = reinterpret_cast<LPPROC_THREAD_ATTRIBUTE_LIST>(HeapAlloc(
        GetProcessHeap(), 0, attrSize));
    if (!attrList) { Close(); return false; }

    InitializeProcThreadAttributeList(attrList, 1, 0, &attrSize);
    UpdateProcThreadAttribute(attrList, 0,
        PROC_THREAD_ATTRIBUTE_PSEUDOCONSOLE, m_hPC, sizeof(HPCON),
        nullptr, nullptr);

    // Launch the shell
    std::wstring shell = DetectShell();
    STARTUPINFOEXW si{};
    si.StartupInfo.cb = sizeof(si);
    si.lpAttributeList = attrList;

    PROCESS_INFORMATION pi{};
    BOOL created = CreateProcessW(
        nullptr,
        shell.data(),  // mutable command line
        nullptr, nullptr,
        FALSE,
        EXTENDED_STARTUPINFO_PRESENT,
        nullptr, nullptr,
        &si.StartupInfo, &pi);

    DeleteProcThreadAttributeList(attrList);
    HeapFree(GetProcessHeap(), 0, attrList);

    if (!created) { Close(); return false; }

    m_process = pi.hProcess;
    m_thread = pi.hThread;
    m_running = true;

    // Start the background reader thread
    m_readThread = std::thread(&PtySession::ReaderLoop, this);

    return true;
}

// ── Write ───────────────────────────────────────────────────
void PtySession::Write(const char* data, size_t len) {
    if (!m_pipeIn || !m_running) return;
    DWORD written = 0;
    WriteFile(m_pipeIn, data, static_cast<DWORD>(len), &written, nullptr);
}

// ── Resize ──────────────────────────────────────────────────
void PtySession::Resize(int cols, int rows) {
    if (!m_hPC) return;
    COORD size{static_cast<SHORT>(cols), static_cast<SHORT>(rows)};
    ResizePseudoConsole(m_hPC, size);
}

// ── Close ───────────────────────────────────────────────────
void PtySession::Close() {
    m_running = false;

    // Close the PTY first — this unblocks ReadFile in the reader thread
    if (m_hPC) { ClosePseudoConsole(m_hPC); m_hPC = nullptr; }

    if (m_pipeIn)  { CloseHandle(m_pipeIn);  m_pipeIn = nullptr; }
    if (m_pipeOut) { CloseHandle(m_pipeOut); m_pipeOut = nullptr; }

    if (m_readThread.joinable()) m_readThread.join();

    if (m_process) {
        TerminateProcess(m_process, 0);
        CloseHandle(m_process); m_process = nullptr;
    }
    if (m_thread)  { CloseHandle(m_thread);  m_thread = nullptr; }
}

// ── Reader Loop (background thread) ────────────────────────
void PtySession::ReaderLoop() {
    char buf[4096];
    while (m_running) {
        DWORD bytesRead = 0;
        BOOL ok = ReadFile(m_pipeOut, buf, sizeof(buf), &bytesRead, nullptr);
        if (!ok || bytesRead == 0) break;

        if (OnOutput) OnOutput(buf, bytesRead);
    }

    m_running = false;
    if (OnExit) OnExit();
}
