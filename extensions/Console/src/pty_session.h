#pragma once
// ── ConPTY Session ──────────────────────────────────────────
// Manages a ConPTY pseudo-console attached to a shell process.
// Provides pipe-based I/O with a background reader thread.

#include <windows.h>
#include <string>
#include <functional>
#include <thread>
#include <atomic>

class PtySession {
public:
    ~PtySession() { Close(); }

    // Start a shell session with the given terminal dimensions.
    // Auto-detects pwsh.exe → powershell.exe → cmd.exe.
    bool Start(int cols, int rows);

    // Write data to the shell's stdin (keyboard input).
    void Write(const char* data, size_t len);
    void Write(std::string_view sv) { Write(sv.data(), sv.size()); }

    // Resize the pseudo-console (e.g. on WM_SIZE).
    void Resize(int cols, int rows);

    // Tear down the session and kill the shell process.
    void Close();

    // Is the session alive?
    bool IsRunning() const { return m_running.load(); }

    // Callback invoked on the I/O thread when output bytes arrive.
    // WARNING: Called from a background thread — you must synchronize.
    std::function<void(const char* data, size_t len)> OnOutput;

    // Callback invoked when the shell process exits.
    std::function<void()> OnExit;

private:
    HPCON  m_hPC      = nullptr;
    HANDLE m_pipeIn    = nullptr;  // our write end → shell stdin
    HANDLE m_pipeOut   = nullptr;  // our read end  ← shell stdout
    HANDLE m_process   = nullptr;
    HANDLE m_thread    = nullptr;

    std::thread m_readThread;
    std::atomic<bool> m_running{false};

    void ReaderLoop();
    static std::wstring DetectShell();
};
