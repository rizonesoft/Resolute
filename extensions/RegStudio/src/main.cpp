/**
 * RegStudio - Modern Windows Registry Editor
 * Copyright (c) 2026 Rizonesoft
 * 
 * Entry point for the application.
 */

#include <windows.h>
#include <commctrl.h>
#include <dwmapi.h>
#include <shellapi.h>
#include <uxtheme.h>
#include <string>
#include <vector>

// Forward declarations
LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
void ApplyDarkTitleBar(HWND hwnd);
void CreateMainMenu(HWND hwnd);
void CreateChildPanes(HWND hwnd);
void ResizePanes(HWND hwnd, int width, int height);
void OnTreeItemExpanding(HWND hwndTree, NMTREEVIEWW* pnmtv);
void OnTreeSelectionChanged(HWND hwndTree, NMTREEVIEWW* pnmtv);
void PopulateSubKeys(HWND hwndTree, HTREEITEM hParent, HKEY hParentKey, const std::wstring& subKeyPath);
void PopulateValues(HKEY hKey, const std::wstring& subKeyPath);
std::wstring GetRegistryTypeName(DWORD dwType);
std::wstring FormatRegistryData(DWORD dwType, const BYTE* data, DWORD dataSize);
void InitializeImageLists();
void ReinitializeImageLists(int dpi);
int GetValueTypeIconIndex(DWORD dwType);
void UpdateStatusBar(const std::wstring& keyPath, int valueCount);
std::wstring GetItemPath(HWND hwndTree, HTREEITEM hItem, HKEY& hRootKey);
void RefreshCurrentView();
void ShowTreeViewContextMenu(HWND hwnd, int x, int y);
void ShowListViewContextMenu(HWND hwnd, int x, int y);

// Application constants
constexpr const wchar_t* APP_CLASS_NAME = L"RegStudioMainWindow";
constexpr const wchar_t* APP_TITLE = L"RegStudio";
constexpr int DEFAULT_WIDTH = 1024;
constexpr int DEFAULT_HEIGHT = 768;

// Splitter constants
constexpr int SPLITTER_WIDTH = 4;           // Width of the splitter bar
constexpr int MIN_PANE_WIDTH = 100;         // Minimum width for each pane
constexpr double DEFAULT_SPLIT_RATIO = 0.3; // 30% left pane by default

// Menu IDs
constexpr UINT IDM_FILE_EXIT = 1001;
constexpr UINT IDM_EDIT_FIND = 2001;
constexpr UINT IDM_EDIT_COPY = 2002;
constexpr UINT IDM_EDIT_PASTE = 2003;
constexpr UINT IDM_VIEW_REFRESH = 3001;
constexpr UINT IDM_HELP_ABOUT = 4001;

// Context Menu IDs - TreeView (Keys)
constexpr UINT IDM_KEY_NEW = 5001;
constexpr UINT IDM_KEY_DELETE = 5002;
constexpr UINT IDM_KEY_RENAME = 5003;
constexpr UINT IDM_KEY_EXPORT = 5004;
constexpr UINT IDM_KEY_COPY_PATH = 5005;

// Context Menu IDs - ListView (Values)
constexpr UINT IDM_VALUE_MODIFY = 6001;
constexpr UINT IDM_VALUE_NEW_STRING = 6002;
constexpr UINT IDM_VALUE_NEW_DWORD = 6003;
constexpr UINT IDM_VALUE_NEW_BINARY = 6004;
constexpr UINT IDM_VALUE_DELETE = 6005;
constexpr UINT IDM_VALUE_RENAME = 6006;
constexpr UINT IDM_VALUE_COPY_NAME = 6007;
constexpr UINT IDM_VALUE_COPY_DATA = 6008;

// Child window IDs
constexpr UINT IDC_LEFT_PANE = 101;
constexpr UINT IDC_RIGHT_PANE = 102;
constexpr UINT IDC_STATUS_BAR = 103;

// Icon resource IDs (from resource.rc)
constexpr UINT IDI_STRING = 2;
constexpr UINT IDI_NUM = 3;
constexpr UINT IDI_BIN = 4;

// Icon indices in ImageLists
constexpr int ICON_FOLDER_CLOSED = 0;
constexpr int ICON_FOLDER_OPEN = 1;
constexpr int ICON_STRING = 0;
constexpr int ICON_NUM = 1;
constexpr int ICON_BIN = 2;

// Registry value cache structure for virtual ListView
struct RegistryValueInfo {
    std::wstring name;
    std::wstring typeName;
    std::wstring data;
    DWORD type;
    int iconIndex;
};

// Global state
HINSTANCE g_hInstance = nullptr;
HWND g_hwndLeftPane = nullptr;   // Left pane (TreeView)
HWND g_hwndRightPane = nullptr;  // Right pane (ListView)
HIMAGELIST g_hTreeImageList = nullptr;  // TreeView icons
HIMAGELIST g_hListImageList = nullptr;  // ListView icons
HWND g_hwndStatusBar = nullptr;         // Status bar
double g_splitRatio = DEFAULT_SPLIT_RATIO;  // Stored pane ratio
bool g_isDragging = false;       // Splitter drag state
std::vector<RegistryValueInfo> g_valueCache;  // Virtual ListView cache

int WINAPI wWinMain(
    HINSTANCE hInstance,
    [[maybe_unused]] HINSTANCE hPrevInstance,
    [[maybe_unused]] LPWSTR lpCmdLine,
    int nCmdShow)
{
    g_hInstance = hInstance;

    // Initialize Common Controls (required for TreeView, ListView, etc.)
    INITCOMMONCONTROLSEX icex{};
    icex.dwSize = sizeof(INITCOMMONCONTROLSEX);
    icex.dwICC = ICC_WIN95_CLASSES | ICC_STANDARD_CLASSES | ICC_TREEVIEW_CLASSES | ICC_LISTVIEW_CLASSES;
    if (!InitCommonControlsEx(&icex)) {
        MessageBoxW(nullptr, L"Failed to initialize Common Controls", APP_TITLE, MB_ICONERROR);
        return 1;
    }

    // Register the window class
    WNDCLASSEXW wc{};
    wc.cbSize = sizeof(WNDCLASSEXW);
    wc.style = CS_HREDRAW | CS_VREDRAW;
    wc.lpfnWndProc = WindowProc;
    wc.hInstance = hInstance;
    wc.hIcon = LoadIconW(hInstance, MAKEINTRESOURCEW(1)); // IDI_APP from resource.rc
    wc.hCursor = LoadCursorW(nullptr, IDC_ARROW);
    wc.hbrBackground = reinterpret_cast<HBRUSH>(COLOR_3DFACE + 1);
    wc.lpszClassName = APP_CLASS_NAME;
    wc.hIconSm = wc.hIcon;

    if (!RegisterClassExW(&wc)) {
        MessageBoxW(nullptr, L"Failed to register window class", APP_TITLE, MB_ICONERROR);
        return 1;
    }

    // Create the main window
    HWND hwnd = CreateWindowExW(
        0,                      // Optional window styles
        APP_CLASS_NAME,         // Window class
        APP_TITLE,              // Window text
        WS_OVERLAPPEDWINDOW,    // Window style
        CW_USEDEFAULT, CW_USEDEFAULT,  // Position
        DEFAULT_WIDTH, DEFAULT_HEIGHT, // Size
        nullptr,                // Parent window
        nullptr,                // Menu (set via CreateMenu)
        hInstance,              // Instance handle
        nullptr                 // Additional application data
    );

    if (!hwnd) {
        MessageBoxW(nullptr, L"Failed to create main window", APP_TITLE, MB_ICONERROR);
        return 1;
    }

    // Apply modern styling
    ApplyDarkTitleBar(hwnd);
    CreateMainMenu(hwnd);
    CreateChildPanes(hwnd);

    // Show the window
    ShowWindow(hwnd, nCmdShow);
    UpdateWindow(hwnd);

    // Create keyboard accelerator table
    ACCEL accels[] = {
        { FVIRTKEY, VK_F5, IDM_VIEW_REFRESH },
        { FVIRTKEY | FCONTROL, 'F', IDM_EDIT_FIND }
    };
    HACCEL hAccel = CreateAcceleratorTableW(accels, sizeof(accels) / sizeof(accels[0]));

    // Message loop with accelerator support
    MSG msg{};
    while (GetMessageW(&msg, nullptr, 0, 0)) {
        if (!TranslateAcceleratorW(hwnd, hAccel, &msg)) {
            TranslateMessage(&msg);
            DispatchMessageW(&msg);
        }
    }

    DestroyAcceleratorTable(hAccel);
    return static_cast<int>(msg.wParam);
}

void ApplyDarkTitleBar(HWND hwnd) {
    // Force Dark Mode on Title Bar (Windows 10 Build 19041+)
    // DWMWA_USE_IMMERSIVE_DARK_MODE = 20
    BOOL value = TRUE;
    DwmSetWindowAttribute(hwnd, 20, &value, sizeof(value));
}

void CreateMainMenu(HWND hwnd) {
    HMENU hMenuBar = CreateMenu();
    
    // File menu
    HMENU hFileMenu = CreatePopupMenu();
    AppendMenuW(hFileMenu, MF_STRING, IDM_FILE_EXIT, L"E&xit\tAlt+F4");
    AppendMenuW(hMenuBar, MF_POPUP, reinterpret_cast<UINT_PTR>(hFileMenu), L"&File");
    
    // Edit menu
    HMENU hEditMenu = CreatePopupMenu();
    AppendMenuW(hEditMenu, MF_STRING, IDM_EDIT_FIND, L"&Find...\tCtrl+F");
    AppendMenuW(hEditMenu, MF_SEPARATOR, 0, nullptr);
    AppendMenuW(hEditMenu, MF_STRING, IDM_EDIT_COPY, L"&Copy\tCtrl+C");
    AppendMenuW(hEditMenu, MF_STRING, IDM_EDIT_PASTE, L"&Paste\tCtrl+V");
    AppendMenuW(hMenuBar, MF_POPUP, reinterpret_cast<UINT_PTR>(hEditMenu), L"&Edit");
    
    // View menu
    HMENU hViewMenu = CreatePopupMenu();
    AppendMenuW(hViewMenu, MF_STRING, IDM_VIEW_REFRESH, L"&Refresh\tF5");
    AppendMenuW(hMenuBar, MF_POPUP, reinterpret_cast<UINT_PTR>(hViewMenu), L"&View");
    
    // Help menu
    HMENU hHelpMenu = CreatePopupMenu();
    AppendMenuW(hHelpMenu, MF_STRING, IDM_HELP_ABOUT, L"&About RegStudio");
    AppendMenuW(hMenuBar, MF_POPUP, reinterpret_cast<UINT_PTR>(hHelpMenu), L"&Help");
    
    SetMenu(hwnd, hMenuBar);
}

void CreateChildPanes(HWND hwnd) {
    // Initialize icon ImageLists
    InitializeImageLists();

    // Create left pane - TreeView for registry keys
    g_hwndLeftPane = CreateWindowExW(
        WS_EX_CLIENTEDGE,
        WC_TREEVIEWW,
        nullptr,
        WS_CHILD | WS_VISIBLE | WS_TABSTOP |
        TVS_HASLINES | TVS_HASBUTTONS | TVS_LINESATROOT | TVS_SHOWSELALWAYS,
        0, 0, 100, 100,
        hwnd,
        reinterpret_cast<HMENU>(IDC_LEFT_PANE),
        g_hInstance,
        nullptr
    );

    // Apply Explorer visual theme and double-buffering to TreeView
    SetWindowTheme(g_hwndLeftPane, L"Explorer", nullptr);
    TreeView_SetExtendedStyle(g_hwndLeftPane, TVS_EX_DOUBLEBUFFER, TVS_EX_DOUBLEBUFFER);

    // Assign TreeView ImageList
    if (g_hTreeImageList) {
        TreeView_SetImageList(g_hwndLeftPane, g_hTreeImageList, TVSIL_NORMAL);
    }

    // Create right pane - ListView for registry values (virtual mode)
    g_hwndRightPane = CreateWindowExW(
        WS_EX_CLIENTEDGE,
        WC_LISTVIEWW,
        nullptr,
        WS_CHILD | WS_VISIBLE | WS_TABSTOP |
        LVS_REPORT | LVS_SHOWSELALWAYS | LVS_SINGLESEL | LVS_OWNERDATA,
        0, 0, 100, 100,
        hwnd,
        reinterpret_cast<HMENU>(IDC_RIGHT_PANE),
        g_hInstance,
        nullptr
    );

    // Apply Explorer visual theme to ListView
    SetWindowTheme(g_hwndRightPane, L"Explorer", nullptr);

    // Assign ListView ImageList (small icons)
    if (g_hListImageList) {
        ListView_SetImageList(g_hwndRightPane, g_hListImageList, LVSIL_SMALL);
    }

    // Enable full row select and gridlines on ListView
    ListView_SetExtendedListViewStyle(g_hwndRightPane, 
        LVS_EX_FULLROWSELECT | LVS_EX_GRIDLINES | LVS_EX_DOUBLEBUFFER);

    // Create status bar
    g_hwndStatusBar = CreateWindowExW(
        0,
        STATUSCLASSNAMEW,
        nullptr,
        WS_CHILD | WS_VISIBLE | SBARS_SIZEGRIP,
        0, 0, 0, 0,
        hwnd,
        reinterpret_cast<HMENU>(IDC_STATUS_BAR),
        g_hInstance,
        nullptr
    );

    // Set up status bar parts (key path | value count)
    int statusParts[] = { -1 };  // Single part that stretches
    SendMessageW(g_hwndStatusBar, SB_SETPARTS, 1, reinterpret_cast<LPARAM>(statusParts));
    UpdateStatusBar(L"", 0);

    // Add ListView columns: Name, Type, Data
    LVCOLUMNW lvc{};
    lvc.mask = LVCF_TEXT | LVCF_WIDTH | LVCF_SUBITEM;

    lvc.iSubItem = 0;
    lvc.pszText = const_cast<LPWSTR>(L"Name");
    lvc.cx = 200;
    ListView_InsertColumn(g_hwndRightPane, 0, &lvc);

    lvc.iSubItem = 1;
    lvc.pszText = const_cast<LPWSTR>(L"Type");
    lvc.cx = 100;
    ListView_InsertColumn(g_hwndRightPane, 1, &lvc);

    lvc.iSubItem = 2;
    lvc.pszText = const_cast<LPWSTR>(L"Data");
    lvc.cx = 300;
    ListView_InsertColumn(g_hwndRightPane, 2, &lvc);

    // Populate TreeView with root registry hives
    struct HiveInfo {
        const wchar_t* name;
        HKEY hKey;
    };
    
    HiveInfo hives[] = {
        { L"HKEY_CLASSES_ROOT", HKEY_CLASSES_ROOT },
        { L"HKEY_CURRENT_USER", HKEY_CURRENT_USER },
        { L"HKEY_LOCAL_MACHINE", HKEY_LOCAL_MACHINE },
        { L"HKEY_USERS", HKEY_USERS },
        { L"HKEY_CURRENT_CONFIG", HKEY_CURRENT_CONFIG }
    };

    TVINSERTSTRUCTW tvis{};
    tvis.hParent = TVI_ROOT;
    tvis.hInsertAfter = TVI_LAST;
    tvis.item.mask = TVIF_TEXT | TVIF_CHILDREN | TVIF_PARAM | TVIF_IMAGE | TVIF_SELECTEDIMAGE;
    tvis.item.cChildren = 1;  // Indicates expandable (has children)
    tvis.item.iImage = ICON_FOLDER_CLOSED;
    tvis.item.iSelectedImage = ICON_FOLDER_OPEN;

    for (const auto& hive : hives) {
        tvis.item.pszText = const_cast<LPWSTR>(hive.name);
        tvis.item.lParam = reinterpret_cast<LPARAM>(hive.hKey);
        TreeView_InsertItem(g_hwndLeftPane, &tvis);
    }

    // Trigger initial resize
    RECT rc;
    GetClientRect(hwnd, &rc);
    ResizePanes(hwnd, rc.right, rc.bottom);
}

// Initialize ImageLists for TreeView and ListView (DPI-aware)
void InitializeImageLists() {
    // Get system DPI for scaling
    HDC hdc = GetDC(nullptr);
    int dpi = GetDeviceCaps(hdc, LOGPIXELSX);
    ReleaseDC(nullptr, hdc);
    
    ReinitializeImageLists(dpi);
}

// Reinitialize ImageLists with specific DPI (for per-monitor DPI changes)
void ReinitializeImageLists(int dpi) {
    // Destroy existing ImageLists
    if (g_hTreeImageList) {
        ImageList_Destroy(g_hTreeImageList);
        g_hTreeImageList = nullptr;
    }
    if (g_hListImageList) {
        ImageList_Destroy(g_hListImageList);
        g_hListImageList = nullptr;
    }
    
    // Calculate scaled icon size (base: 16px at 96 DPI, max: 32px)
    int iconSize = MulDiv(16, dpi, 96);
    if (iconSize > 32) iconSize = 32;  // Cap at 32px
    
    // Determine if we should use large icons (for high DPI)
    bool useLargeIcons = (iconSize > 16);
    
    // Create TreeView ImageList with scaled size
    g_hTreeImageList = ImageList_Create(iconSize, iconSize, ILC_COLOR32 | ILC_MASK, 2, 2);
    
    // Get system folder icons using shell API
    SHSTOCKICONINFO sii{};
    sii.cbSize = sizeof(sii);
    UINT iconFlags = SHGSI_ICON | (useLargeIcons ? SHGSI_LARGEICON : SHGSI_SMALLICON);
    
    // Closed folder icon
    if (SUCCEEDED(SHGetStockIconInfo(SIID_FOLDER, iconFlags, &sii))) {
        ImageList_AddIcon(g_hTreeImageList, sii.hIcon);
        DestroyIcon(sii.hIcon);
    }
    
    // Open folder icon
    if (SUCCEEDED(SHGetStockIconInfo(SIID_FOLDEROPEN, iconFlags, &sii))) {
        ImageList_AddIcon(g_hTreeImageList, sii.hIcon);
        DestroyIcon(sii.hIcon);
    }
    
    // Create ListView ImageList with scaled size
    g_hListImageList = ImageList_Create(iconSize, iconSize, ILC_COLOR32 | ILC_MASK, 3, 1);
    
    // Load custom value type icons from resources with specific size
    HICON hIconString = static_cast<HICON>(LoadImageW(
        g_hInstance, MAKEINTRESOURCEW(IDI_STRING), IMAGE_ICON,
        iconSize, iconSize, LR_DEFAULTCOLOR));
    HICON hIconNum = static_cast<HICON>(LoadImageW(
        g_hInstance, MAKEINTRESOURCEW(IDI_NUM), IMAGE_ICON,
        iconSize, iconSize, LR_DEFAULTCOLOR));
    HICON hIconBin = static_cast<HICON>(LoadImageW(
        g_hInstance, MAKEINTRESOURCEW(IDI_BIN), IMAGE_ICON,
        iconSize, iconSize, LR_DEFAULTCOLOR));
    
    if (hIconString) {
        ImageList_AddIcon(g_hListImageList, hIconString);
        DestroyIcon(hIconString);
    }
    if (hIconNum) {
        ImageList_AddIcon(g_hListImageList, hIconNum);
        DestroyIcon(hIconNum);
    }
    if (hIconBin) {
        ImageList_AddIcon(g_hListImageList, hIconBin);
        DestroyIcon(hIconBin);
    }
    
    // Reassign ImageLists to controls if they exist
    if (g_hwndLeftPane && g_hTreeImageList) {
        TreeView_SetImageList(g_hwndLeftPane, g_hTreeImageList, TVSIL_NORMAL);
    }
    if (g_hwndRightPane && g_hListImageList) {
        ListView_SetImageList(g_hwndRightPane, g_hListImageList, LVSIL_SMALL);
    }
}

// Get icon index for a registry value type
int GetValueTypeIconIndex(DWORD dwType) {
    switch (dwType) {
        case REG_SZ:
        case REG_EXPAND_SZ:
        case REG_MULTI_SZ:
            return ICON_STRING;
        case REG_DWORD:
        case REG_DWORD_BIG_ENDIAN:
        case REG_QWORD:
            return ICON_NUM;
        case REG_BINARY:
        default:
            return ICON_BIN;
    }
}

// Refresh the current view (reload values for selected key)
void RefreshCurrentView() {
    if (!g_hwndLeftPane) return;
    
    HTREEITEM hSelected = TreeView_GetSelection(g_hwndLeftPane);
    if (!hSelected) return;
    
    // Get the current key path
    HKEY hRootKey = nullptr;
    std::wstring subKeyPath = GetItemPath(g_hwndLeftPane, hSelected, hRootKey);
    
    // Reload values
    PopulateValues(hRootKey, subKeyPath);
    
    // Update status bar
    wchar_t rootName[64]{};
    HTREEITEM hRoot = hSelected;
    HTREEITEM hParent;
    while ((hParent = TreeView_GetParent(g_hwndLeftPane, hRoot)) != nullptr) {
        hRoot = hParent;
    }
    TVITEMW tvi{};
    tvi.mask = TVIF_TEXT;
    tvi.hItem = hRoot;
    tvi.pszText = rootName;
    tvi.cchTextMax = 64;
    TreeView_GetItem(g_hwndLeftPane, &tvi);
    
    std::wstring fullPath = rootName;
    if (!subKeyPath.empty()) {
        fullPath += L"\\" + subKeyPath;
    }
    
    int valueCount = ListView_GetItemCount(g_hwndRightPane);
    UpdateStatusBar(fullPath, valueCount);
}

// Show context menu for TreeView (registry keys)
void ShowTreeViewContextMenu(HWND hwnd, int x, int y) {
    HMENU hMenu = CreatePopupMenu();
    
    AppendMenuW(hMenu, MF_STRING, IDM_KEY_NEW, L"&New Key");
    AppendMenuW(hMenu, MF_SEPARATOR, 0, nullptr);
    AppendMenuW(hMenu, MF_STRING, IDM_KEY_DELETE, L"&Delete");
    AppendMenuW(hMenu, MF_STRING, IDM_KEY_RENAME, L"&Rename");
    AppendMenuW(hMenu, MF_SEPARATOR, 0, nullptr);
    AppendMenuW(hMenu, MF_STRING, IDM_KEY_COPY_PATH, L"Copy &Path");
    AppendMenuW(hMenu, MF_STRING, IDM_KEY_EXPORT, L"&Export...");
    
    TrackPopupMenu(hMenu, TPM_RIGHTBUTTON, x, y, 0, hwnd, nullptr);
    DestroyMenu(hMenu);
}

// Show context menu for ListView (registry values)
void ShowListViewContextMenu(HWND hwnd, int x, int y) {
    HMENU hMenu = CreatePopupMenu();
    
    // Check if an item is selected
    int selectedIndex = ListView_GetNextItem(g_hwndRightPane, -1, LVNI_SELECTED);
    bool hasSelection = (selectedIndex >= 0);
    
    AppendMenuW(hMenu, hasSelection ? MF_STRING : MF_GRAYED, IDM_VALUE_MODIFY, L"&Modify...");
    AppendMenuW(hMenu, MF_SEPARATOR, 0, nullptr);
    
    // New submenu
    HMENU hNewMenu = CreatePopupMenu();
    AppendMenuW(hNewMenu, MF_STRING, IDM_VALUE_NEW_STRING, L"&String Value");
    AppendMenuW(hNewMenu, MF_STRING, IDM_VALUE_NEW_DWORD, L"&DWORD (32-bit) Value");
    AppendMenuW(hNewMenu, MF_STRING, IDM_VALUE_NEW_BINARY, L"&Binary Value");
    AppendMenuW(hMenu, MF_POPUP, reinterpret_cast<UINT_PTR>(hNewMenu), L"&New");
    
    AppendMenuW(hMenu, MF_SEPARATOR, 0, nullptr);
    AppendMenuW(hMenu, hasSelection ? MF_STRING : MF_GRAYED, IDM_VALUE_DELETE, L"&Delete");
    AppendMenuW(hMenu, hasSelection ? MF_STRING : MF_GRAYED, IDM_VALUE_RENAME, L"&Rename");
    AppendMenuW(hMenu, MF_SEPARATOR, 0, nullptr);
    AppendMenuW(hMenu, hasSelection ? MF_STRING : MF_GRAYED, IDM_VALUE_COPY_NAME, L"Copy &Name");
    AppendMenuW(hMenu, hasSelection ? MF_STRING : MF_GRAYED, IDM_VALUE_COPY_DATA, L"Copy &Data");
    
    TrackPopupMenu(hMenu, TPM_RIGHTBUTTON, x, y, 0, hwnd, nullptr);
    DestroyMenu(hMenu);
}


// Get the full registry path for a TreeView item
std::wstring GetItemPath(HWND hwndTree, HTREEITEM hItem, HKEY& hRootKey) {
    std::vector<std::wstring> pathParts;
    HTREEITEM hCurrent = hItem;
    wchar_t buffer[256];
    
    while (hCurrent) {
        TVITEMW tvi{};
        tvi.mask = TVIF_TEXT | TVIF_PARAM;
        tvi.hItem = hCurrent;
        tvi.pszText = buffer;
        tvi.cchTextMax = 256;
        TreeView_GetItem(hwndTree, &tvi);
        
        HTREEITEM hParent = TreeView_GetParent(hwndTree, hCurrent);
        if (!hParent) {
            // This is a root hive
            hRootKey = reinterpret_cast<HKEY>(tvi.lParam);
        } else {
            pathParts.push_back(buffer);
        }
        hCurrent = hParent;
    }
    
    // Build path from parts (in reverse order)
    std::wstring path;
    for (auto it = pathParts.rbegin(); it != pathParts.rend(); ++it) {
        if (!path.empty()) path += L"\\";
        path += *it;
    }
    return path;
}

// Handle TVN_ITEMEXPANDING - enumerate subkeys
void OnTreeItemExpanding(HWND hwndTree, NMTREEVIEWW* pnmtv) {
    if (pnmtv->action != TVE_EXPAND) return;
    
    HTREEITEM hItem = pnmtv->itemNew.hItem;
    
    // Check if already populated (has real children, not just placeholder)
    HTREEITEM hChild = TreeView_GetChild(hwndTree, hItem);
    if (hChild) {
        // Check if it's a placeholder (empty text)
        wchar_t buffer[2];
        TVITEMW tvi{};
        tvi.mask = TVIF_TEXT;
        tvi.hItem = hChild;
        tvi.pszText = buffer;
        tvi.cchTextMax = 2;
        TreeView_GetItem(hwndTree, &tvi);
        if (buffer[0] != L'\0') return;  // Already populated
        
        // Remove placeholder
        TreeView_DeleteItem(hwndTree, hChild);
    }
    
    // Get the registry path for this item
    HKEY hRootKey = nullptr;
    std::wstring subKeyPath = GetItemPath(hwndTree, hItem, hRootKey);
    
    PopulateSubKeys(hwndTree, hItem, hRootKey, subKeyPath);
}

// Populate subkeys for a TreeView item
void PopulateSubKeys(HWND hwndTree, HTREEITEM hParent, HKEY hRootKey, const std::wstring& subKeyPath) {
    HKEY hKey = nullptr;
    LONG result;
    
    if (subKeyPath.empty()) {
        hKey = hRootKey;
    } else {
        result = RegOpenKeyExW(hRootKey, subKeyPath.c_str(), 0, KEY_READ, &hKey);
        if (result != ERROR_SUCCESS) return;
    }
    
    wchar_t keyName[256];
    DWORD keyNameLen;
    DWORD index = 0;
    
    while (true) {
        keyNameLen = 256;
        result = RegEnumKeyExW(hKey, index++, keyName, &keyNameLen, nullptr, nullptr, nullptr, nullptr);
        if (result != ERROR_SUCCESS) break;
        
        // Check if this subkey has children
        HKEY hSubKey = nullptr;
        std::wstring fullPath = subKeyPath.empty() ? keyName : subKeyPath + L"\\" + keyName;
        int hasChildren = 0;
        
        if (RegOpenKeyExW(hRootKey, fullPath.c_str(), 0, KEY_READ, &hSubKey) == ERROR_SUCCESS) {
            DWORD subKeyCount = 0;
            RegQueryInfoKeyW(hSubKey, nullptr, nullptr, nullptr, &subKeyCount, 
                           nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr);
            hasChildren = (subKeyCount > 0) ? 1 : 0;
            RegCloseKey(hSubKey);
        }
        
        // Insert the item with folder icons
        TVINSERTSTRUCTW tvis{};
        tvis.hParent = hParent;
        tvis.hInsertAfter = TVI_LAST;
        tvis.item.mask = TVIF_TEXT | TVIF_CHILDREN | TVIF_IMAGE | TVIF_SELECTEDIMAGE;
        tvis.item.pszText = keyName;
        tvis.item.cChildren = hasChildren;
        tvis.item.iImage = ICON_FOLDER_CLOSED;
        tvis.item.iSelectedImage = ICON_FOLDER_OPEN;
        TreeView_InsertItem(hwndTree, &tvis);
    }
    
    if (hKey != hRootKey) {
        RegCloseKey(hKey);
    }
}

// Handle TVN_SELCHANGED - populate ListView with values
void OnTreeSelectionChanged(HWND hwndTree, NMTREEVIEWW* pnmtv) {
    HTREEITEM hItem = pnmtv->itemNew.hItem;
    if (!hItem) return;
    
    HKEY hRootKey = nullptr;
    std::wstring subKeyPath = GetItemPath(hwndTree, hItem, hRootKey);
    
    PopulateValues(hRootKey, subKeyPath);
    
    // Update status bar with current path and value count
    // Get the root key name
    wchar_t rootName[64]{};
    HTREEITEM hRoot = hItem;
    HTREEITEM hParent;
    while ((hParent = TreeView_GetParent(hwndTree, hRoot)) != nullptr) {
        hRoot = hParent;
    }
    TVITEMW tvi{};
    tvi.mask = TVIF_TEXT;
    tvi.hItem = hRoot;
    tvi.pszText = rootName;
    tvi.cchTextMax = 64;
    TreeView_GetItem(hwndTree, &tvi);
    
    std::wstring fullPath = rootName;
    if (!subKeyPath.empty()) {
        fullPath += L"\\" + subKeyPath;
    }
    
    int valueCount = ListView_GetItemCount(g_hwndRightPane);
    UpdateStatusBar(fullPath, valueCount);
}

// Populate ListView with registry values (virtual mode - populates cache)
void PopulateValues(HKEY hRootKey, const std::wstring& subKeyPath) {
    // Clear cache
    g_valueCache.clear();
    
    HKEY hKey = nullptr;
    if (subKeyPath.empty()) {
        hKey = hRootKey;
    } else {
        if (RegOpenKeyExW(hRootKey, subKeyPath.c_str(), 0, KEY_READ, &hKey) != ERROR_SUCCESS) {
            ListView_SetItemCountEx(g_hwndRightPane, 0, 0);
            return;
        }
    }
    
    // Add default value entry
    RegistryValueInfo defaultValue;
    defaultValue.name = L"(Default)";
    
    DWORD dataSize = 0;
    DWORD dwType = REG_SZ;
    RegQueryValueExW(hKey, nullptr, nullptr, &dwType, nullptr, &dataSize);
    
    defaultValue.type = dwType;
    defaultValue.iconIndex = GetValueTypeIconIndex(dwType);
    
    if (dataSize > 0) {
        std::vector<BYTE> data(dataSize);
        RegQueryValueExW(hKey, nullptr, nullptr, &dwType, data.data(), &dataSize);
        defaultValue.typeName = GetRegistryTypeName(dwType);
        defaultValue.data = FormatRegistryData(dwType, data.data(), dataSize);
    } else {
        defaultValue.typeName = L"REG_SZ";
        defaultValue.data = L"(value not set)";
    }
    g_valueCache.push_back(std::move(defaultValue));
    
    // Enumerate other values
    wchar_t valueName[16383];
    DWORD valueNameLen;
    DWORD index = 0;
    
    while (true) {
        valueNameLen = 16383;
        dataSize = 0;
        
        LONG result = RegEnumValueW(hKey, index++, valueName, &valueNameLen, 
                                    nullptr, &dwType, nullptr, &dataSize);
        if (result != ERROR_SUCCESS) break;
        if (valueNameLen == 0) continue;  // Skip default value (already added)
        
        // Get the data
        std::vector<BYTE> data(dataSize > 0 ? dataSize : 1);
        valueNameLen = 16383;
        RegEnumValueW(hKey, index - 1, valueName, &valueNameLen, 
                     nullptr, &dwType, data.data(), &dataSize);
        
        // Add to cache
        RegistryValueInfo valueInfo;
        valueInfo.name = valueName;
        valueInfo.type = dwType;
        valueInfo.typeName = GetRegistryTypeName(dwType);
        valueInfo.data = FormatRegistryData(dwType, data.data(), dataSize);
        valueInfo.iconIndex = GetValueTypeIconIndex(dwType);
        g_valueCache.push_back(std::move(valueInfo));
    }
    
    if (hKey != hRootKey) {
        RegCloseKey(hKey);
    }
    
    // Set item count for virtual ListView
    ListView_SetItemCountEx(g_hwndRightPane, static_cast<int>(g_valueCache.size()), 
                            LVSICF_NOINVALIDATEALL);
}

// Convert registry type to display name
std::wstring GetRegistryTypeName(DWORD dwType) {
    switch (dwType) {
        case REG_SZ: return L"REG_SZ";
        case REG_EXPAND_SZ: return L"REG_EXPAND_SZ";
        case REG_BINARY: return L"REG_BINARY";
        case REG_DWORD: return L"REG_DWORD";
        case REG_DWORD_BIG_ENDIAN: return L"REG_DWORD_BE";
        case REG_LINK: return L"REG_LINK";
        case REG_MULTI_SZ: return L"REG_MULTI_SZ";
        case REG_RESOURCE_LIST: return L"REG_RESOURCE_LIST";
        case REG_FULL_RESOURCE_DESCRIPTOR: return L"REG_FULL_RES";
        case REG_RESOURCE_REQUIREMENTS_LIST: return L"REG_RES_REQ";
        case REG_QWORD: return L"REG_QWORD";
        default: return L"REG_UNKNOWN";
    }
}

// Format registry data for display
std::wstring FormatRegistryData(DWORD dwType, const BYTE* data, DWORD dataSize) {
    if (!data || dataSize == 0) return L"";
    
    switch (dwType) {
        case REG_SZ:
        case REG_EXPAND_SZ:
            return std::wstring(reinterpret_cast<const wchar_t*>(data));
            
        case REG_DWORD:
            if (dataSize >= 4) {
                DWORD value = *reinterpret_cast<const DWORD*>(data);
                wchar_t buf[32];
                swprintf_s(buf, L"0x%08X (%u)", value, value);
                return buf;
            }
            break;
            
        case REG_QWORD:
            if (dataSize >= 8) {
                ULONGLONG value = *reinterpret_cast<const ULONGLONG*>(data);
                wchar_t buf[64];
                swprintf_s(buf, L"0x%016llX (%llu)", value, value);
                return buf;
            }
            break;
            
        case REG_MULTI_SZ: {
            std::wstring result;
            const wchar_t* p = reinterpret_cast<const wchar_t*>(data);
            while (*p) {
                if (!result.empty()) result += L" ";
                result += p;
                p += wcslen(p) + 1;
            }
            return result;
        }
            
        case REG_BINARY:
        default: {
            std::wstring result;
            DWORD displayBytes = (dataSize > 16) ? 16 : dataSize;
            for (DWORD i = 0; i < displayBytes; i++) {
                wchar_t buf[4];
                swprintf_s(buf, L"%02X ", data[i]);
                result += buf;
            }
            if (dataSize > 16) result += L"...";
            return result;
        }
    }
    return L"";
}


// Update status bar with current path and value count
void UpdateStatusBar(const std::wstring& keyPath, int valueCount) {
    if (!g_hwndStatusBar) return;
    
    std::wstring statusText;
    if (keyPath.empty()) {
        statusText = L"Ready";
    } else {
        wchar_t countStr[32];
        swprintf_s(countStr, L" (%d value%s)", valueCount, valueCount == 1 ? L"" : L"s");
        statusText = keyPath + countStr;
    }
    
    SendMessageW(g_hwndStatusBar, SB_SETTEXTW, 0, reinterpret_cast<LPARAM>(statusText.c_str()));
}

void ResizePanes(HWND hwnd, int width, int height) {
    if (!g_hwndLeftPane || !g_hwndRightPane) return;

    // Get status bar height
    int statusBarHeight = 0;
    if (g_hwndStatusBar) {
        RECT sbRect;
        GetWindowRect(g_hwndStatusBar, &sbRect);
        statusBarHeight = sbRect.bottom - sbRect.top;
        // Resize status bar to fit width
        SendMessageW(g_hwndStatusBar, WM_SIZE, 0, 0);
    }
    
    // Adjust height for status bar
    int paneHeight = height - statusBarHeight;

    // Calculate left pane width based on stored ratio
    int leftWidth = static_cast<int>(width * g_splitRatio);
    
    // Enforce minimum pane widths
    if (leftWidth < MIN_PANE_WIDTH) leftWidth = MIN_PANE_WIDTH;
    if (width - leftWidth - SPLITTER_WIDTH < MIN_PANE_WIDTH) {
        leftWidth = width - MIN_PANE_WIDTH - SPLITTER_WIDTH;
    }

    // Position left pane
    SetWindowPos(g_hwndLeftPane, nullptr,
        0, 0,
        leftWidth, paneHeight,
        SWP_NOZORDER);

    // Position right pane (after splitter gap)
    int rightX = leftWidth + SPLITTER_WIDTH;
    int rightWidth = width - rightX;
    SetWindowPos(g_hwndRightPane, nullptr,
        rightX, 0,
        rightWidth, paneHeight,
        SWP_NOZORDER);

    // Invalidate splitter area to redraw
    RECT splitterRect = { leftWidth, 0, rightX, paneHeight };
    InvalidateRect(hwnd, &splitterRect, TRUE);
}

// Check if point is on splitter
bool IsOnSplitter(HWND hwnd, int x) {
    RECT rc;
    GetClientRect(hwnd, &rc);
    int leftWidth = static_cast<int>(rc.right * g_splitRatio);
    return (x >= leftWidth && x <= leftWidth + SPLITTER_WIDTH);
}

LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    switch (uMsg) {
        case WM_COMMAND:
            switch (LOWORD(wParam)) {
                case IDM_FILE_EXIT:
                    PostMessageW(hwnd, WM_CLOSE, 0, 0);
                    return 0;
                    
                case IDM_HELP_ABOUT:
                    MessageBoxW(hwnd, 
                        L"RegStudio v1.0.0\n\n"
                        L"A modern Windows Registry Editor\n\n"
                        L"Copyright © 2026 Rizonesoft",
                        L"About RegStudio",
                        MB_OK | MB_ICONINFORMATION);
                    return 0;
                    
                case IDM_VIEW_REFRESH:
                    RefreshCurrentView();
                    return 0;
            }
            break;

        case WM_NOTIFY: {
            NMHDR* pnmhdr = reinterpret_cast<NMHDR*>(lParam);
            if (pnmhdr->hwndFrom == g_hwndLeftPane) {
                switch (pnmhdr->code) {
                    case TVN_ITEMEXPANDINGW:
                        OnTreeItemExpanding(g_hwndLeftPane, reinterpret_cast<NMTREEVIEWW*>(lParam));
                        break;
                    case TVN_SELCHANGEDW:
                        OnTreeSelectionChanged(g_hwndLeftPane, reinterpret_cast<NMTREEVIEWW*>(lParam));
                        break;
                    case NM_RCLICK: {
                        POINT pt;
                        GetCursorPos(&pt);
                        ShowTreeViewContextMenu(hwnd, pt.x, pt.y);
                        return TRUE;
                    }
                }
            } else if (pnmhdr->hwndFrom == g_hwndRightPane) {
                switch (pnmhdr->code) {
                    case LVN_GETDISPINFOW: {
                        NMLVDISPINFOW* plvdi = reinterpret_cast<NMLVDISPINFOW*>(lParam);
                        int itemIndex = plvdi->item.iItem;
                        
                        if (itemIndex >= 0 && itemIndex < static_cast<int>(g_valueCache.size())) {
                            const RegistryValueInfo& info = g_valueCache[itemIndex];
                            
                            if (plvdi->item.mask & LVIF_TEXT) {
                                switch (plvdi->item.iSubItem) {
                                    case 0:  // Name
                                        wcsncpy_s(plvdi->item.pszText, plvdi->item.cchTextMax, 
                                                  info.name.c_str(), _TRUNCATE);
                                        break;
                                    case 1:  // Type
                                        wcsncpy_s(plvdi->item.pszText, plvdi->item.cchTextMax, 
                                                  info.typeName.c_str(), _TRUNCATE);
                                        break;
                                    case 2:  // Data
                                        wcsncpy_s(plvdi->item.pszText, plvdi->item.cchTextMax, 
                                                  info.data.c_str(), _TRUNCATE);
                                        break;
                                }
                            }
                            if (plvdi->item.mask & LVIF_IMAGE) {
                                plvdi->item.iImage = info.iconIndex;
                            }
                        }
                        return 0;
                    }
                    case NM_RCLICK: {
                        POINT pt;
                        GetCursorPos(&pt);
                        ShowListViewContextMenu(hwnd, pt.x, pt.y);
                        return TRUE;
                    }
                }
            }
            break;
        }

        case WM_SIZE: {
            int width = LOWORD(lParam);
            int height = HIWORD(lParam);
            ResizePanes(hwnd, width, height);
            return 0;
        }

        case WM_SETCURSOR: {
            // Change cursor to resize arrow when over splitter
            POINT pt;
            GetCursorPos(&pt);
            ScreenToClient(hwnd, &pt);
            if (IsOnSplitter(hwnd, pt.x)) {
                SetCursor(LoadCursorW(nullptr, IDC_SIZEWE));
                return TRUE;
            }
            break;
        }

        case WM_LBUTTONDOWN: {
            int x = LOWORD(lParam);
            if (IsOnSplitter(hwnd, x)) {
                g_isDragging = true;
                SetCapture(hwnd);
                return 0;
            }
            break;
        }

        case WM_MOUSEMOVE: {
            if (g_isDragging) {
                int x = LOWORD(lParam);
                RECT rc;
                GetClientRect(hwnd, &rc);
                
                // Calculate new ratio
                double newRatio = static_cast<double>(x) / rc.right;
                
                // Clamp ratio to valid range
                double minRatio = static_cast<double>(MIN_PANE_WIDTH) / rc.right;
                double maxRatio = static_cast<double>(rc.right - MIN_PANE_WIDTH - SPLITTER_WIDTH) / rc.right;
                
                if (newRatio < minRatio) newRatio = minRatio;
                if (newRatio > maxRatio) newRatio = maxRatio;
                
                g_splitRatio = newRatio;
                ResizePanes(hwnd, rc.right, rc.bottom);
                return 0;
            }
            break;
        }

        case WM_LBUTTONUP: {
            if (g_isDragging) {
                g_isDragging = false;
                ReleaseCapture();
                return 0;
            }
            break;
        }

        case WM_PAINT: {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hwnd, &ps);
            
            // Draw splitter bar
            RECT rc;
            GetClientRect(hwnd, &rc);
            int leftWidth = static_cast<int>(rc.right * g_splitRatio);
            
            RECT splitterRect = { leftWidth, 0, leftWidth + SPLITTER_WIDTH, rc.bottom };
            FillRect(hdc, &splitterRect, reinterpret_cast<HBRUSH>(COLOR_3DFACE + 1));
            
            EndPaint(hwnd, &ps);
            return 0;
        }

        case WM_DESTROY:
            // Cleanup ImageLists
            if (g_hTreeImageList) ImageList_Destroy(g_hTreeImageList);
            if (g_hListImageList) ImageList_Destroy(g_hListImageList);
            PostQuitMessage(0);
            return 0;

        case WM_DPICHANGED: {
            // Per-monitor DPI change - reinitialize icons with new DPI
            int newDpi = HIWORD(wParam);
            ReinitializeImageLists(newDpi);
            
            // Resize window to suggested size
            RECT* pRect = reinterpret_cast<RECT*>(lParam);
            SetWindowPos(hwnd, nullptr, 
                pRect->left, pRect->top,
                pRect->right - pRect->left, pRect->bottom - pRect->top,
                SWP_NOZORDER | SWP_NOACTIVATE);
            return 0;
        }

        default:
            return DefWindowProcW(hwnd, uMsg, wParam, lParam);
    }
    return DefWindowProcW(hwnd, uMsg, wParam, lParam);
}
