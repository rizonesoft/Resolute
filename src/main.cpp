#include <windows.h>
#include <commctrl.h>
#include <uxtheme.h>
#include <algorithm>
#include "resource.h"

// ExoUI shared library
#include <exo/dpi.h>
#include <exo/theme.h>
#include <exo/render.h>
#include <exo/icons.h>
#include <exo/animation.h>
#include <exo/controls/toolbar.h>
#include <exo/controls/sidebar.h>
#include <exo/controls/statusbar.h>
#include <exo/controls/contentview.h>
#include <exo/controls/listview.h>

enum CtrlId : int {
    IDC_TOOLBAR     = 100,
    IDC_SIDEBAR     = 101,
    IDC_LISTVIEW    = 102,
    IDC_STATUSBAR   = 103,
    IDC_CONTENTVIEW = 104,
};

// ── Extension Discovery ─────────────────────────────────────
// Scans System/*.exe for embedded EXOEXT RCDATA resources.
// Each extension is a self-describing executable — no external
// config files, no registry. Drop an .exe with EXOEXT, done.
#include <shellapi.h>
#include <string>
#pragma comment(lib, "shell32.lib")

static std::vector<exo::ListItem> g_allItems;       // all scanned extensions
static std::vector<exo::ListItem*> g_filteredItems;  // current visible subset

// Rebuild filtered view based on sidebar category
static void FilterByCategory(const wchar_t* category) {
    g_filteredItems.clear();
    bool showAll = (_wcsicmp(category, L"All") == 0);
    for (auto& item : g_allItems) {
        if (showAll || _wcsicmp(item.category.c_str(), category) == 0)
            g_filteredItems.push_back(&item);
    }
}

// Minimal JSON value extractor — pulls "key": "value" pairs
static std::wstring JsonStr(const char* json, size_t len, const char* key) {
    std::string needle = std::string("\"") + key + "\"";
    const char* pos = std::search(json, json + len, needle.begin(), needle.end());
    if (pos == json + len) return {};
    pos += needle.size();
    // skip whitespace and colon
    while (pos < json + len && (*pos == ' ' || *pos == ':' || *pos == '\t')) pos++;
    if (pos >= json + len || *pos != '"') return {};
    pos++; // skip opening quote
    const char* end = pos;
    while (end < json + len && *end != '"') end++;
    // Convert UTF-8 to wstring
    int wlen = MultiByteToWideChar(CP_UTF8, 0, pos, (int)(end - pos), nullptr, 0);
    std::wstring result(wlen, 0);
    MultiByteToWideChar(CP_UTF8, 0, pos, (int)(end - pos), result.data(), wlen);
    return result;
}

// Format file size for display
static std::wstring FormatSize(DWORD high, DWORD low) {
    uint64_t bytes = (static_cast<uint64_t>(high) << 32) | low;
    wchar_t buf[32];
    if (bytes >= 1048576)
        swprintf_s(buf, L"%.1f MB", static_cast<double>(bytes) / 1048576.0);
    else if (bytes >= 1024)
        swprintf_s(buf, L"%llu KB", bytes / 1024);
    else
        swprintf_s(buf, L"%llu B", bytes);
    return buf;
}

// Format FILETIME to date string
static std::wstring FormatDate(const FILETIME& ft) {
    SYSTEMTIME st;
    FileTimeToSystemTime(&ft, &st);
    wchar_t buf[32];
    swprintf_s(buf, L"%04d-%02d-%02d", st.wYear, st.wMonth, st.wDay);
    return buf;
}

static void ScanExtensions() {
    g_allItems.clear();
    g_filteredItems.clear();


    // Get System/ folder path (relative to Resolute.exe)
    wchar_t exePath[MAX_PATH];
    GetModuleFileNameW(nullptr, exePath, MAX_PATH);
    std::wstring dir(exePath);
    dir = dir.substr(0, dir.find_last_of(L'\\') + 1) + L"System\\";

    // Search for all .exe files in System/
    WIN32_FIND_DATAW fd;
    std::wstring pattern = dir + L"*.exe";
    HANDLE hFind = FindFirstFileW(pattern.c_str(), &fd);
    if (hFind == INVALID_HANDLE_VALUE) return;

    do {
        std::wstring fullPath = dir + fd.cFileName;

        // Load as data-only — no execution, no DllMain
        HMODULE hMod = LoadLibraryExW(fullPath.c_str(), nullptr,
            LOAD_LIBRARY_AS_DATAFILE | LOAD_LIBRARY_AS_IMAGE_RESOURCE);
        if (!hMod) continue;

        // Look for EXOEXT RCDATA resource
        HRSRC hRes = FindResourceW(hMod, L"EXOEXT", RT_RCDATA);
        if (!hRes) {
            FreeLibrary(hMod);
            continue;  // Not a Resolute extension
        }

        HGLOBAL hData = LoadResource(hMod, hRes);
        DWORD resSize = SizeofResource(hMod, hRes);
        const char* json = static_cast<const char*>(LockResource(hData));

        if (json && resSize > 0) {
            // Parse EXOEXT metadata
            std::wstring name   = JsonStr(json, resSize, "name");
            std::wstring desc   = JsonStr(json, resSize, "description");
            std::wstring ver    = JsonStr(json, resSize, "version");
            std::wstring cat    = JsonStr(json, resSize, "category");

            // Extract real icon from the PE
            HICON hIcon = nullptr;
            ExtractIconExW(fullPath.c_str(), 0, &hIcon, nullptr, 1);

            // Build list item
            exo::ListItem item;
            item.icon = hIcon;
            item.category = cat;
            item.cells = {
                name.empty() ? std::wstring(fd.cFileName) : name,  // Name (from EXOEXT)
                desc.empty() ? cat : desc,     // Description
                ver.empty() ? L"—" : ver,      // Version
                FormatSize(fd.nFileSizeHigh, fd.nFileSizeLow),  // Size
                FormatDate(fd.ftLastWriteTime)  // Modified
            };
            g_allItems.push_back(std::move(item));
        }

        FreeLibrary(hMod);
    } while (FindNextFileW(hFind, &fd));
    FindClose(hFind);
}

struct AppState {
    exo::Toolbar     toolbar;
    exo::Sidebar     sidebar;
    exo::StatusBar   statusbar;
    exo::ContentView contentView;
    exo::ListView    listView;
    HBRUSH         bgBrush   = nullptr;
    int            dpi       = 96;

    void DestroyBrushes() {
        if (bgBrush) { DeleteObject(bgBrush); bgBrush = nullptr; }
    }

    void UpdateBrushes() {
        DestroyBrushes();
        bgBrush = CreateSolidBrush(exo::Theme::Colors().background);
    }
};

// Global state for theme repaint callback
static HWND      g_mainHwnd = nullptr;
static AppState* g_app      = nullptr;

// ── Layout ──────────────────────────────────────────────────
static void LayoutChildren(HWND hwnd, AppState& app) {
    RECT rc;
    GetClientRect(hwnd, &rc);

    int clientH  = rc.bottom - rc.top;
    int clientW  = rc.right - rc.left;
    int toolbarH = app.toolbar.ScaledHeight();
    int statusH  = app.statusbar.ScaledHeight();
    int sidebarW = app.sidebar.ScaledWidth();

    app.toolbar.Resize(0, 0, clientW, toolbarH);
    app.statusbar.Resize(0, clientH - statusH, clientW, statusH);

    int contentH = clientH - toolbarH - statusH;
    app.sidebar.Resize(0, toolbarH, sidebarW, contentH);

    app.listView.Resize(sidebarW, toolbarH,
        clientW - sidebarW, contentH);

    // ContentView disabled — empty state not needed when ListView has items
    // app.contentView.Resize(sidebarW, toolbarH,
    //     clientW - sidebarW, contentH);
}

// ── Theme Application ───────────────────────────────────────
static void ApplyTheme(HWND hwnd, AppState& app) {
    exo::Theme::ApplyToWindow(hwnd);
    app.UpdateBrushes();
    app.listView.Repaint();

    app.toolbar.Repaint();
    app.sidebar.Repaint();
    app.statusbar.Repaint();
    // app.contentView.Repaint();
    InvalidateRect(hwnd, nullptr, FALSE);
}

// Repaint callback for animated theme transitions
static void OnThemeFrame() {
    if (!g_app || !g_mainHwnd) return;

    // All D2D controls — safe to repaint every frame
    g_app->toolbar.Repaint();
    g_app->sidebar.Repaint();
    g_app->statusbar.Repaint();
    // g_app->contentView.Repaint();
    g_app->listView.Repaint();

    if (!exo::Theme::IsTransitioning()) {
        g_app->UpdateBrushes();
        exo::Theme::ApplyToWindow(g_mainHwnd);
        InvalidateRect(g_mainHwnd, nullptr, FALSE);
    }
}

// ── Window Procedure ────────────────────────────────────────
static LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
    AppState* app = nullptr;

    if (msg == WM_NCCREATE) {
        auto cs = reinterpret_cast<CREATESTRUCTW*>(lp);
        app = static_cast<AppState*>(cs->lpCreateParams);
        SetWindowLongPtrW(hwnd, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(app));
    } else {
        app = reinterpret_cast<AppState*>(GetWindowLongPtrW(hwnd, GWLP_USERDATA));
    }

    switch (msg) {
    case WM_CREATE: {
        auto hInst = reinterpret_cast<CREATESTRUCTW*>(lp)->hInstance;
        app->dpi = exo::Dpi::Get(hwnd);

        app->toolbar.Create(hwnd, hInst, IDC_TOOLBAR);
        app->sidebar.Create(hwnd, hInst, IDC_SIDEBAR);
        app->statusbar.Create(hwnd, hInst, IDC_STATUSBAR);

        // Multi-part status bar: right = view mode
        app->statusbar.SetRightText(L"Details");

        // Custom D2D ListView
        ScanExtensions();
        FilterByCategory(L"All");
        app->listView.Create(hwnd, hInst, IDC_LISTVIEW);

        // Load embedded fallback icon (application.ico). The identifier comes
        // from resource.h, which the .rc also includes, so one value defines it.
        app->listView.SetFallbackIcon(
            LoadIconW(hInst, MAKEINTRESOURCEW(IDI_APPFALLBACK)));

        app->listView.AddColumn(L"Name", 180);
        app->listView.AddColumn(L"Description", 280);
        app->listView.AddColumn(L"Version", 80);
        app->listView.AddColumn(L"Size", 80, true, DWRITE_TEXT_ALIGNMENT_TRAILING);
        app->listView.AddColumn(L"Modified", 120);
        app->listView.SetItemCount(static_cast<int>(g_filteredItems.size()));
        app->listView.SetItemProvider([](int idx) -> const exo::ListItem& {
            return *g_filteredItems[idx];
        });
        app->listView.SetSortColumn(0, true);
        if (!g_filteredItems.empty()) app->listView.Select(0);

        // Dynamic badge counts from scanned extensions
        app->sidebar.SetBadge(0, static_cast<int>(g_allItems.size()));  // All
        for (int c = 1; c < exo::kCategoryCount; c++) {
            int count = 0;
            for (auto& item : g_allItems)
                if (_wcsicmp(item.category.c_str(), exo::kCategories[c].label) == 0)
                    count++;
            app->sidebar.SetBadge(c, count);
        }
        // Initial status bar: show total count
        {
            wchar_t buf[64];
            swprintf_s(buf, L"%d items", static_cast<int>(g_allItems.size()));
            app->statusbar.SetCenterText(buf);
        }
        // TODO: ContentView overlay for empty state — disabled while ListView has items

        ApplyTheme(hwnd, *app);

        // Store globals for theme transition callback
        g_mainHwnd = hwnd;
        g_app = app;
        exo::Theme::SetRepaintCallback(OnThemeFrame);

        // Apply Mica Alt backdrop (Win11 22H2+, graceful fallback)
        exo::Theme::ApplyBackdrop(hwnd);
        return 0;
    }

    case WM_SIZE:
        if (app) LayoutChildren(hwnd, *app);
        return 0;

    case WM_COMMAND: {
        WORD id = LOWORD(wp);

        // Sidebar category selection
        if (id == IDC_SIDEBAR) {
            int catIdx = HIWORD(wp);
            const wchar_t* catName = exo::kCategories[catIdx].label;

            // Filter extensions by selected category
            FilterByCategory(catName);
            app->listView.SetItemCount(static_cast<int>(g_filteredItems.size()));
            if (!g_filteredItems.empty()) app->listView.Select(0);
            app->listView.Repaint();

            app->statusbar.SetText(catName);
            wchar_t buf[64];
            swprintf_s(buf, L"%d items", static_cast<int>(g_filteredItems.size()));
            app->statusbar.SetCenterText(buf);
        }

        switch (id) {
        case exo::IDC_TB_THEME:
            exo::Theme::AnimateToggle(300.0f);
            break;

        case exo::IDC_TB_VIEW_LARGE:
            app->listView.SetViewMode(exo::ViewMode::LargeIcons);
            app->statusbar.SetRightText(L"Large Icons");
            break;

        case exo::IDC_TB_VIEW_SMALL:
            app->listView.SetViewMode(exo::ViewMode::SmallIcons);
            app->statusbar.SetRightText(L"Small Icons");
            break;

        case exo::IDC_TB_VIEW_LIST:
            app->listView.SetViewMode(exo::ViewMode::List);
            app->statusbar.SetRightText(L"List");
            break;

        case exo::IDC_TB_VIEW_DETAILS:
            app->listView.SetViewMode(exo::ViewMode::Details);
            app->statusbar.SetRightText(L"Details");
            break;

        case exo::IDC_TB_REFRESH:
            app->statusbar.SetText(L"Refreshing...");
            app->statusbar.SetProgress(0.01f);  // start visible
            app->statusbar.AddNotifyIcon(1, exo::NotifyIconKind::Spinner);
            // Animate progress 0→1 over 2 seconds
            exo::AnimationManager::Instance().Animate(
                0.0f, 1.0f, 2000.0f, exo::ease::InOutCubic,
                [app](float v, const exo::Animation&) {
                    app->statusbar.SetProgress(v);
                },
                [app, hwnd]() {
                    app->statusbar.HideProgress();
                    app->statusbar.RemoveNotifyIcon(1);
                    app->statusbar.AddNotifyIcon(2, exo::NotifyIconKind::Success);
                    app->statusbar.SetText(L"Ready");
                }
            );
            break;

        case exo::IDC_TB_SETTINGS:
            break;

        case exo::IDC_LISTVIEW_SORT: {
            int col = app->listView.SortColumn();
            bool asc = app->listView.SortDirection() == exo::SortDir::Ascending;
            std::sort(g_filteredItems.begin(), g_filteredItems.end(),
                [col, asc](const exo::ListItem* a, const exo::ListItem* b) {
                    if (col < 0 || col >= static_cast<int>(a->cells.size()) ||
                        col >= static_cast<int>(b->cells.size())) return false;
                    int cmp = _wcsicmp(a->cells[col].c_str(), b->cells[col].c_str());
                    return asc ? cmp < 0 : cmp > 0;
                });
            app->listView.Repaint();
            break;
        }
        }
        return 0;
    }

    // ── Tab Cycling ─────────────────────────────────────────
    case WM_EXOTAB: {
        int fromId = static_cast<int>(wp);
        bool backward = (lp != 0);

        // Explicit tab order by control ID
        struct TabEntry { int id; HWND hwnd; };
        TabEntry tabOrder[] = {
            { IDC_SIDEBAR,  app->sidebar.Handle() },
            { IDC_TOOLBAR,  app->toolbar.Handle() },
            { IDC_LISTVIEW, app->listView.Handle() },
        };
        constexpr int tabCount = 3;

        int cur = -1;
        for (int i = 0; i < tabCount; i++) {
            if (tabOrder[i].id == fromId) { cur = i; break; }
        }

        int next = backward
            ? (cur <= 0 ? tabCount - 1 : cur - 1)
            : (cur >= tabCount - 1 ? 0 : cur + 1);

        SetFocus(tabOrder[next].hwnd);
        return 0;
    }

    case WM_DPICHANGED: {
        int newDpi = HIWORD(wp);
        app->dpi = newDpi;
        app->toolbar.UpdateDpi(newDpi);
        app->sidebar.UpdateDpi(newDpi);
        app->statusbar.UpdateDpi(newDpi);
        app->contentView.UpdateDpi(newDpi);
        app->listView.UpdateDpi(newDpi);

        auto* suggested = reinterpret_cast<RECT*>(lp);
        SetWindowPos(hwnd, nullptr,
            suggested->left, suggested->top,
            suggested->right - suggested->left,
            suggested->bottom - suggested->top,
            SWP_NOZORDER | SWP_NOACTIVATE);
        return 0;
    }

    case WM_SETTINGCHANGE:
        if (lp && wcscmp(reinterpret_cast<LPCWSTR>(lp), L"ImmersiveColorSet") == 0) {
            exo::Theme::SetDark(exo::Theme::IsDarkMode());
            ApplyTheme(hwnd, *app);
        }
        return 0;

    case WM_TIMER:
        return 0;

    case WM_PAINT: {
        PAINTSTRUCT ps;
        HDC hdc = BeginPaint(hwnd, &ps);
        HBRUSH br = CreateSolidBrush(exo::Theme::Colors().background);
        FillRect(hdc, &ps.rcPaint, br);
        DeleteObject(br);
        EndPaint(hwnd, &ps);
        return 0;
    }

    case WM_ERASEBKGND:
        return 1;

    case WM_DESTROY:
        if (app) app->DestroyBrushes();
        PostQuitMessage(0);
        return 0;
    }

    return DefWindowProcW(hwnd, msg, wp, lp);
}

// ── Entry Point ─────────────────────────────────────────────
int WINAPI wWinMain(HINSTANCE hInstance, HINSTANCE, PWSTR, int nCmdShow) {

    SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);

    INITCOMMONCONTROLSEX icc{};
    icc.dwSize = sizeof(icc);
    icc.dwICC  = ICC_STANDARD_CLASSES | ICC_LISTVIEW_CLASSES | ICC_BAR_CLASSES;
    InitCommonControlsEx(&icc);

    // Initialize ExoUI (D2D, DirectWrite, Lucide icons)
    if (!exo::RenderContext::Init()) {
        MessageBoxW(nullptr, L"Failed to initialize D2D/DirectWrite.", L"Resolute", MB_ICONERROR);
        return 1;
    }
    exo::LucideIcons::Load();
    exo::Theme::Init();

    constexpr auto CLASS_NAME = L"ResoluteMain";

    WNDCLASSEXW wc{};
    wc.cbSize        = sizeof(wc);
    wc.style         = CS_HREDRAW | CS_VREDRAW;
    wc.lpfnWndProc   = WndProc;
    wc.hInstance     = hInstance;
    wc.hCursor       = LoadCursorW(nullptr, IDC_ARROW);
    wc.hbrBackground = CreateSolidBrush(RGB(30, 30, 30));  // Dark initial fill — prevents white flash
    wc.hIcon         = LoadIconW(hInstance, MAKEINTRESOURCEW(IDI_RESOLUTE));
    wc.hIconSm       = LoadIconW(hInstance, MAKEINTRESOURCEW(IDI_RESOLUTE));
    wc.lpszClassName = CLASS_NAME;

    if (!RegisterClassExW(&wc)) {
        MessageBoxW(nullptr, L"Failed to register window class.", L"Resolute", MB_ICONERROR);
        return 1;
    }

    AppState app{};

    HWND hwnd = CreateWindowExW(
        0, CLASS_NAME, L"Resolute",
        WS_OVERLAPPEDWINDOW | WS_CLIPCHILDREN,
        CW_USEDEFAULT, CW_USEDEFAULT, 1100, 720,
        nullptr, nullptr, hInstance, &app
    );

    if (!hwnd) {
        MessageBoxW(nullptr, L"Failed to create main window.", L"Resolute", MB_ICONERROR);
        return 1;
    }

    ShowWindow(hwnd, nCmdShow);
    UpdateWindow(hwnd);

    // Set initial keyboard focus to sidebar
    SetFocus(app.sidebar.Handle());

    // Start the animation engine
    exo::AnimationManager::Instance().Start(hwnd);

    // Show empty state after animation engine is running
    app.contentView.ShowEmpty(L"No items",
        L"Select a category to browse or add items",
        exo::kCategories[0].iconName);

    // Build accelerator table
    ACCEL accels[] = {
        { FALT | FVIRTKEY, 'L', exo::IDC_TB_VIEW_LARGE },
        { FALT | FVIRTKEY, 'S', exo::IDC_TB_VIEW_SMALL },
        { FALT | FVIRTKEY, 'I', exo::IDC_TB_VIEW_LIST },
        { FALT | FVIRTKEY, 'D', exo::IDC_TB_VIEW_DETAILS },
        { FALT | FVIRTKEY, 'R', exo::IDC_TB_REFRESH },
        { FALT | FVIRTKEY, 'T', exo::IDC_TB_THEME },
    };
    HACCEL hAccel = CreateAcceleratorTableW(accels, _countof(accels));

    MSG msg{};
    while (GetMessageW(&msg, nullptr, 0, 0)) {
        if (TranslateAccelerator(hwnd, hAccel, &msg))
            continue;

        // Intercept Tab/Escape at message loop level for focus cycling
        if (msg.message == WM_KEYDOWN &&
            (msg.wParam == VK_TAB || msg.wParam == VK_ESCAPE)) {
            HWND focused = GetFocus();
            bool backward = (msg.wParam == VK_TAB &&
                             (GetKeyState(VK_SHIFT) & 0x8000));
            SendMessageW(hwnd, WM_EXOTAB,
                static_cast<WPARAM>(GetDlgCtrlID(focused)),
                backward ? 1 : 0);
            continue;
        }

        TranslateMessage(&msg);
        DispatchMessageW(&msg);
    }

    DestroyAcceleratorTable(hAccel);

    return static_cast<int>(msg.wParam);
}
