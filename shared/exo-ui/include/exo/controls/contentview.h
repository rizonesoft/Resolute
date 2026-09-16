#pragma once
// ── ExoUI Content View Overlay ──────────────────────────────
// D2D overlay for state feedback: empty state, error banner,
// success flash. Sits on top of the main content area.

#include <windows.h>
#include <wrl/client.h>
#include <d2d1.h>
#include <string>
#include "../export.h"
#include "../dpi.h"
#include "../theme.h"
#include "../render.h"
#include "../icons.h"
#include "../animation.h"

using Microsoft::WRL::ComPtr;

namespace exo {

class EXOUI_API ContentView {
public:
    void Create(HWND parent, HINSTANCE hInst, int id);
    HWND Handle() const;
    void Resize(int x, int y, int w, int h);
    void Repaint();
    void UpdateDpi(int dpi);

    // ── Empty State ─────────────────────────────────────────
    void ShowEmpty(const wchar_t* title = L"No items",
                   const wchar_t* subtitle = L"Select a category or add items to get started",
                   const char* iconName = "folder-open");
    void HideEmpty();
    bool IsEmpty() const;

    // ── Error Banner ────────────────────────────────────────
    void ShowError(const wchar_t* message, float durationSec = 5.0f);
    void DismissError();

    // ── Success Flash ───────────────────────────────────────
    void ShowSuccess(const wchar_t* message, float durationSec = 2.0f);

private:
    HWND m_hwnd   = nullptr;
    HWND m_parent = nullptr;
    int  m_dpi    = 96;
    ComPtr<ID2D1HwndRenderTarget> m_rt;

    // ── Empty State ─────────────────────────────────────────
    bool         m_emptyVisible = false;
    std::wstring m_emptyTitle;
    std::wstring m_emptySubtitle;
    std::string  m_emptyIcon;
    float        m_emptyAlpha   = 0.0f;
    uint32_t     m_emptyAnimId  = 0;

    // ── Error Banner ────────────────────────────────────────
    std::wstring m_errorText;
    float        m_errorAlpha   = 0.0f;
    float        m_errorSlideY  = -1.0f;   // negative = hidden above
    uint32_t     m_errorAnimId  = 0;
    UINT_PTR     m_errorTimer   = 0;

    // ── Success Flash ───────────────────────────────────────
    std::wstring m_successText;
    float        m_successAlpha = 0.0f;
    uint32_t     m_successAnimId = 0;

    void OnPaint();
    void CreateRenderTarget();
    static LRESULT CALLBACK ContentProc(HWND, UINT, WPARAM, LPARAM);
};

} // namespace exo
