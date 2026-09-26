#pragma once
// ── ResoluteUI Enhanced Status Bar Control ───────────────────────
// Multi-part status bar with left/center/right segments,
// thin accent progress bar, clickable segments with hover
// feedback, and animated notification icons.

#include <windows.h>
#include <wrl/client.h>
#include <d2d1.h>
#include <string>
#include <vector>
#include "../export.h"
#include "../dpi.h"
#include "../theme.h"
#include "../render.h"
#include "../animation.h"

using Microsoft::WRL::ComPtr;

namespace rui {

// ── Segment Identifiers ────────────────────────────────────
enum class Segment : int { Left = 0, Center = 1, Right = 2, Count = 3 };

// ── Notification Icon Kinds ────────────────────────────────
enum class NotifyIconKind { Spinner, Success, Warning };

// ── Command IDs for default segment clicks ─────────────────
inline constexpr int IDC_SB_LEFT   = 2001;
inline constexpr int IDC_SB_CENTER = 2002;
inline constexpr int IDC_SB_RIGHT  = 2003;

class RESUI_API StatusBar {
public:
    // Cancels every animation whose callbacks reach this control, so
    // none runs against it after teardown (D00 T02 §7).
    ~StatusBar();
    static constexpr int BASE_HEIGHT    = 26;
    static constexpr int BASE_FONT_SIZE = 12;
    static constexpr int BASE_PADDING_X = 10;
    static constexpr int BASE_ICON_SIZE = 14;
    static constexpr int PROGRESS_HEIGHT = 2;

    int  ScaledHeight() const;
    void Create(HWND parent, HINSTANCE hInst, int id);
    HWND Handle() const;
    void Resize(int x, int y, int w, int h);
    void Repaint();
    // Paints the control's current state into `target` (an offscreen
    // bitmap target, say) instead of its window, sized by the target;
    // the window's own target is untouched. False when drawing failed.
    bool RenderTo(ID2D1RenderTarget* target);
    void UpdateDpi(int dpi);

    // ── Segment Text ───────────────────────────────────────
    void SetText(const wchar_t* text);              // alias for SetLeftText
    void SetLeftText(const wchar_t* text);
    void SetCenterText(const wchar_t* text);
    void SetRightText(const wchar_t* text);

    // ── Segment Click Commands ─────────────────────────────
    void SetSegmentCommand(Segment seg, int cmdId);

    // ── Progress Bar ───────────────────────────────────────
    // value 0..1  → determinate bar
    // value < 0   → indeterminate pulse
    void SetProgress(float value);
    void HideProgress();

    // Legacy shims
    void StartProgress();
    void StopProgress();

    // ── Notification Icons ─────────────────────────────────
    void AddNotifyIcon(int id, NotifyIconKind kind);
    void RemoveNotifyIcon(int id);
    void ClearNotifyIcons();

    // ── Notification Toast (slide-in from right) ───────────
    void ShowNotification(const wchar_t* text, COLORREF color = 0, float durationSec = 3.0f);

private:
    HWND m_hwnd     = nullptr;
    HWND m_parent   = nullptr;
    int  m_dpi      = 96;
    // The window's own target, and the one paint draws into: the window's,
    // or an offscreen target for the duration of RenderTo (D00 T02 §9).
    ComPtr<ID2D1HwndRenderTarget> m_hwndRt;
    ComPtr<ID2D1RenderTarget>     m_rt;
    void ReleaseDeviceResources();
    HRESULT m_paintHr = S_OK;  // the last paint's EndDraw result, for RenderTo

    // ── Segment State ──────────────────────────────────────
    struct SegmentState {
        std::wstring text;
        std::wstring oldText;
        float fadeIn      = 1.0f;
        float fadeOut     = 0.0f;
        uint32_t fadeAnim = 0;
        int   cmdId       = 0;       // WM_COMMAND id on click
        float hoverAlpha  = 0.0f;
        uint32_t hoverAnim = 0;
    };
    SegmentState m_segments[3];  // Left, Center, Right
    int m_hoveredSeg  = -1;
    int m_pressedSeg  = -1;

    // ── Progress Bar ───────────────────────────────────────
    float m_progressValue     = 0.0f;   // <0 = indeterminate, 0 = hidden, 0..1 = determinate
    bool  m_progressVisible   = false;
    float m_progressPhase     = 0.0f;   // indeterminate sweep position
    uint32_t m_progressAnimId = 0;

    // ── Notification Icons ─────────────────────────────────
    struct NotifyIcon {
        int           id;
        NotifyIconKind kind;
        float         angle    = 0.0f;   // spinner rotation
        float         alpha    = 1.0f;
        uint32_t      spinAnim = 0;
        uint32_t      fadeAnim = 0;
        UINT_PTR      timer    = 0;       // auto-dismiss for Success
    };
    std::vector<NotifyIcon> m_notifyIcons;

    // ── Notification Toast ─────────────────────────────────
    std::wstring m_notifyText;
    COLORREF m_notifyColor   = 0;
    float m_notifyOffset     = 0.0f;
    float m_notifyAlpha      = 0.0f;
    uint32_t m_notifySlideId = 0;
    uint32_t m_notifyFadeId  = 0;
    UINT_PTR m_notifyTimer   = 0;

    // ── Internal ───────────────────────────────────────────
    void OnPaint();
    void CreateRenderTarget();
    D2D1_RECT_F SegmentRect(Segment seg, float totalW, float totalH) const;
    int  HitTestSegment(int mx, int my) const;
    void AnimateSegmentText(int idx);
    void AnimateSegmentHover(int idx, bool entering);
    void StartIndeterminateLoop();

    static LRESULT CALLBACK StatusProc(HWND, UINT, WPARAM, LPARAM);
};

} // namespace rui
