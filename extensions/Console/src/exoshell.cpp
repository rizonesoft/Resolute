// ── ExoShell ────────────────────────────────────────────────
// A lightweight shell that bypasses cmd.exe entirely.
// Programs are executed directly via CreateProcess with PATH
// resolution, avoiding ConPTY's cooked-read double-prompt bug.
//
// Only falls back to cmd.exe /C for shell operators: | > < & &&
// and for .bat/.cmd batch files.
//
// (c) 2026 Rizonesoft — MIT License
// ─────────────────────────────────────────────────────────────

#include <windows.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <string>
#include <vector>
#include <algorithm>

static HANDLE hIn, hOut;

// ── Write helpers ───────────────────────────────────────────
static void Out(const char* s, int len = -1) {
    if (len < 0) len = (int)strlen(s);
    DWORD w;
    WriteFile(hOut, s, len, &w, nullptr);
}

static void Outf(const char* fmt, ...) {
    char buf[2048];
    va_list ap;
    va_start(ap, fmt);
    int n = vsnprintf(buf, sizeof(buf), fmt, ap);
    va_end(ap);
    if (n > 0) Out(buf, n);
}

// ── String helpers ──────────────────────────────────────────
static std::string ToLower(std::string s) {
    for (auto& c : s) c = (char)tolower((unsigned char)c);
    return s;
}

static std::string Trim(const std::string& s) {
    size_t a = s.find_first_not_of(' ');
    if (a == std::string::npos) return "";
    size_t b = s.find_last_not_of(' ');
    return s.substr(a, b - a + 1);
}

// ── Get current directory ───────────────────────────────────
static std::string GetCwd() {
    char buf[MAX_PATH];
    GetCurrentDirectoryA(MAX_PATH, buf);
    return buf;
}

// ── Print prompt (VT colored) ───────────────────────────────
static void PrintPrompt() {
    std::string cwd = GetCwd();
    Outf("\x1b[38;2;24;255;255m%s\x1b[0m> ", cwd.c_str());
}

// ── Read a line from stdin (raw bytes) ──────────────────────
static std::string ReadLine() {
    std::string line;

    for (;;) {
        char ch;
        DWORD bytesRead;
        if (!ReadFile(hIn, &ch, 1, &bytesRead, nullptr) || bytesRead == 0)
            break;

        if (ch == '\r' || ch == '\n') {
            Out("\r\n");
            break;
        }

        if (ch == '\b' || ch == 0x7F) {
            if (!line.empty()) {
                line.pop_back();
                Out("\b \b");
            }
            continue;
        }

        if (ch == 3) {  // Ctrl+C
            Out("^C\r\n");
            line.clear();
            break;
        }

        if (ch == 4) {  // Ctrl+D
            if (line.empty()) ExitProcess(0);
            continue;
        }

        // ESC sequences — consume and ignore
        if (ch == '\x1b') {
            char next;
            DWORD nr;
            if (ReadFile(hIn, &next, 1, &nr, nullptr) && nr > 0 && next == '[') {
                char seq;
                while (ReadFile(hIn, &seq, 1, &nr, nullptr) && nr > 0) {
                    if (seq >= 0x40 && seq <= 0x7E) break;
                }
            }
            continue;
        }

        if (ch >= 32) {
            line += ch;
            Out(&ch, 1);
        }
    }

    return line;
}

// ── Parse into command + args ───────────────────────────────
static void ParseCommand(const std::string& line, std::string& cmd, std::string& args) {
    size_t i = 0;
    while (i < line.size() && line[i] == ' ') i++;
    size_t start = i;
    while (i < line.size() && line[i] != ' ') i++;
    cmd = line.substr(start, i - start);
    while (i < line.size() && line[i] == ' ') i++;
    args = (i < line.size()) ? line.substr(i) : "";
}

// ── Does the line need cmd.exe for shell operators? ─────────
static bool NeedsCmdShell(const std::string& line) {
    for (char c : line) {
        if (c == '|' || c == '>' || c == '<' || c == '&') return true;
    }
    // Check for .bat or .cmd files
    std::string cmd;
    std::string args;
    ParseCommand(line, cmd, args);
    std::string lower = ToLower(cmd);
    if (lower.size() >= 4) {
        std::string ext = lower.substr(lower.size() - 4);
        if (ext == ".bat" || ext == ".cmd") return true;
    }
    return false;
}

// ── Resolve executable in PATH ──────────────────────────────
static std::string FindExecutable(const std::string& name) {
    char found[MAX_PATH];
    // Try as-is first (might have extension)
    if (SearchPathA(nullptr, name.c_str(), nullptr, MAX_PATH, found, nullptr))
        return found;
    // Try with .exe
    if (SearchPathA(nullptr, name.c_str(), ".exe", MAX_PATH, found, nullptr))
        return found;
    // Try with .com
    if (SearchPathA(nullptr, name.c_str(), ".com", MAX_PATH, found, nullptr))
        return found;
    return "";
}

// ── Execute directly via CreateProcess ──────────────────────
static void ExecuteDirect(const std::string& cmdline) {
    std::string cmd, args;
    ParseCommand(cmdline, cmd, args);

    std::string exePath = FindExecutable(cmd);
    if (exePath.empty()) {
        Outf("'%s' is not recognized as an internal or external command,\r\n"
             "operable program or batch file.\r\n", cmd.c_str());
        return;
    }

    // Build command line: "exe" args
    std::string fullCmd = "\"" + exePath + "\"";
    if (!args.empty()) fullCmd += " " + args;

    STARTUPINFOA si{};
    si.cb = sizeof(si);
    PROCESS_INFORMATION pi{};

    if (CreateProcessA(nullptr, fullCmd.data(), nullptr, nullptr,
                       TRUE, 0, nullptr, nullptr, &si, &pi)) {
        WaitForSingleObject(pi.hProcess, INFINITE);
        CloseHandle(pi.hProcess);
        CloseHandle(pi.hThread);
    } else {
        Outf("Failed to execute '%s' (error %lu)\r\n", exePath.c_str(), GetLastError());
    }
}

// ── Execute via cmd.exe /C (for pipes/redirection only) ─────
static void ExecuteViaCmd(const std::string& cmdline) {
    std::string full = "cmd.exe /C " + cmdline;

    STARTUPINFOA si{};
    si.cb = sizeof(si);
    PROCESS_INFORMATION pi{};

    if (CreateProcessA(nullptr, full.data(), nullptr, nullptr,
                       TRUE, 0, nullptr, nullptr, &si, &pi)) {
        WaitForSingleObject(pi.hProcess, INFINITE);
        CloseHandle(pi.hProcess);
        CloseHandle(pi.hThread);
    }
}

// ── Built-in: cd ────────────────────────────────────────────
static void Builtin_Cd(const std::string& path) {
    if (path.empty()) {
        Outf("%s\r\n", GetCwd().c_str());
        return;
    }
    if (!SetCurrentDirectoryA(path.c_str())) {
        Outf("The system cannot find the path specified.\r\n");
    }
}

// ── Built-in: set ───────────────────────────────────────────
static void Builtin_Set(const std::string& args) {
    if (args.empty()) {
        // List all environment variables via cmd /C set
        STARTUPINFOA si{}; si.cb = sizeof(si);
        PROCESS_INFORMATION pi{};
        char cmd[] = "cmd.exe /C set";
        if (CreateProcessA(nullptr, cmd, nullptr, nullptr, TRUE, 0, nullptr, nullptr, &si, &pi)) {
            WaitForSingleObject(pi.hProcess, INFINITE);
            CloseHandle(pi.hProcess);
            CloseHandle(pi.hThread);
        }
        return;
    }
    // set VAR=VALUE
    auto eq = args.find('=');
    if (eq != std::string::npos) {
        std::string name = args.substr(0, eq);
        std::string val  = args.substr(eq + 1);
        SetEnvironmentVariableA(name.c_str(), val.empty() ? nullptr : val.c_str());
    } else {
        char buf[4096];
        if (GetEnvironmentVariableA(args.c_str(), buf, sizeof(buf)))
            Outf("%s=%s\r\n", args.c_str(), buf);
        else
            Outf("Environment variable %s not defined.\r\n", args.c_str());
    }
}

// ── Built-in: echo ──────────────────────────────────────────
static void Builtin_Echo(const std::string& args) {
    Outf("%s\r\n", args.c_str());
}

// ── Built-in: type ──────────────────────────────────────────
static void Builtin_Type(const std::string& path) {
    if (path.empty()) { Out("The syntax of the command is incorrect.\r\n"); return; }
    HANDLE f = CreateFileA(path.c_str(), GENERIC_READ, FILE_SHARE_READ,
                           nullptr, OPEN_EXISTING, 0, nullptr);
    if (f == INVALID_HANDLE_VALUE) {
        Outf("The system cannot find the file specified.\r\n");
        return;
    }
    char buf[4096];
    DWORD n;
    while (ReadFile(f, buf, sizeof(buf), &n, nullptr) && n > 0)
        Out(buf, n);
    CloseHandle(f);
}

// ── Built-in: mkdir ─────────────────────────────────────────
static void Builtin_Mkdir(const std::string& path) {
    if (path.empty()) { Out("The syntax of the command is incorrect.\r\n"); return; }
    if (!CreateDirectoryA(path.c_str(), nullptr))
        Outf("A subdirectory or file %s already exists.\r\n", path.c_str());
}

// ── Check for cd variants: cd.., cd\path, cd/path ───────────
static bool IsCdCommand(const std::string& cmd, std::string& path) {
    std::string lower = ToLower(cmd);
    if (lower.size() >= 3 && lower[0] == 'c' && lower[1] == 'd' &&
        (lower[2] == '.' || lower[2] == '\\' || lower[2] == '/')) {
        path = cmd.substr(2);
        return true;
    }
    if (lower == "cd" || lower == "chdir") return true;
    return false;
}

// ── Main ────────────────────────────────────────────────────
int main() {
    hIn  = GetStdHandle(STD_INPUT_HANDLE);
    hOut = GetStdHandle(STD_OUTPUT_HANDLE);

    DWORD outMode;
    GetConsoleMode(hOut, &outMode);
    SetConsoleMode(hOut, outMode | ENABLE_VIRTUAL_TERMINAL_PROCESSING);

    DWORD inMode;
    GetConsoleMode(hIn, &inMode);
    SetConsoleMode(hIn, ENABLE_VIRTUAL_TERMINAL_INPUT);

    Out("\x1b[38;2;24;255;255m"
        "ExoSuite Console [Version 0.1.0]\r\n"
        "\x1b[38;2;100;100;120m"
        "(c) 2026 Rizonesoft. All rights reserved.\r\n"
        "\x1b[0m\r\n");

    for (;;) {
        PrintPrompt();
        std::string line = ReadLine();
        if (line.empty()) continue;

        std::string cmd, args;
        ParseCommand(line, cmd, args);
        std::string lcmd = ToLower(cmd);

        // ── Exit ────────────────────────────────
        if (lcmd == "exit" || lcmd == "quit") break;

        // ── cd (with variants) ──────────────────
        std::string cdPath;
        if (IsCdCommand(cmd, cdPath)) {
            if (cdPath.empty()) cdPath = args;
            Builtin_Cd(cdPath);
            continue;
        }

        // ── Drive letter change: D:, E: ─────────
        if (lcmd.size() == 2 && lcmd[1] == ':' && isalpha((unsigned char)lcmd[0])) {
            Builtin_Cd(cmd + "\\");
            continue;
        }

        // ── Other builtins ──────────────────────
        if (lcmd == "cls" || lcmd == "clear") { Out("\x1b[2J\x1b[H"); continue; }
        if (lcmd == "title") { Outf("\x1b]0;%s\x07", args.c_str()); continue; }
        if (lcmd == "echo")  { Builtin_Echo(args); continue; }
        if (lcmd == "set")   { Builtin_Set(args); continue; }
        if (lcmd == "type")  { Builtin_Type(args); continue; }
        if (lcmd == "mkdir" || lcmd == "md") { Builtin_Mkdir(args); continue; }
        if (lcmd == "rmdir" || lcmd == "rd") {
            RemoveDirectoryA(args.c_str());
            continue;
        }
        if (lcmd == "del" || lcmd == "erase") {
            DeleteFileA(args.c_str());
            continue;
        }
        if (lcmd == "dir") {
            // dir is complex — delegate to cmd but it's worth it
            ExecuteViaCmd(line);
            continue;
        }

        // ── Shell operators → cmd.exe /C ────────
        if (NeedsCmdShell(line)) {
            ExecuteViaCmd(line);
            continue;
        }

        // ── Direct execution (no cmd.exe!) ──────
        ExecuteDirect(line);
    }

    SetConsoleMode(hIn, inMode);
    return 0;
}
