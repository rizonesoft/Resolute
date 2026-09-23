#pragma once
// ── ResoluteUI Animation System ──────────────────────────────────
// Centralized animation manager with easing functions, property
// animations, and staggered sequences. All controls subscribe
// to a shared 60fps timer.

#include <windows.h>
#include <cstdint>
#include <cmath>
#include <functional>
#include <vector>
#include <algorithm>
#include "export.h"

namespace rui {

// ── Easing Functions ────────────────────────────────────────
// All take t ∈ [0,1] and return a value (usually [0,1], but
// EaseOutBack and Spring may overshoot).

namespace ease {

inline float Linear(float t) { return t; }

inline float InQuad(float t) { return t * t; }
inline float OutQuad(float t) { return t * (2.0f - t); }
inline float InOutQuad(float t) {
    return t < 0.5f ? 2.0f * t * t : -1.0f + (4.0f - 2.0f * t) * t;
}

inline float InCubic(float t) { return t * t * t; }
inline float OutCubic(float t) {
    float u = t - 1.0f;
    return u * u * u + 1.0f;
}
inline float InOutCubic(float t) {
    return t < 0.5f
        ? 4.0f * t * t * t
        : (t - 1.0f) * (2.0f * t - 2.0f) * (2.0f * t - 2.0f) + 1.0f;
}

inline float InQuart(float t) { return t * t * t * t; }
inline float OutQuart(float t) {
    float u = t - 1.0f;
    return 1.0f - u * u * u * u;
}
inline float InOutQuart(float t) {
    float u = t - 1.0f;
    return t < 0.5f ? 8.0f * t * t * t * t : 1.0f - 8.0f * u * u * u * u;
}

inline float OutBack(float t) {
    constexpr float c1 = 1.70158f;
    constexpr float c3 = c1 + 1.0f;
    float u = t - 1.0f;
    return 1.0f + c3 * u * u * u + c1 * u * u;
}

inline float OutElastic(float t) {
    if (t <= 0.0f) return 0.0f;
    if (t >= 1.0f) return 1.0f;
    constexpr float c4 = 6.2831853f / 3.0f; // 2π/3
    return std::pow(2.0f, -10.0f * t) * std::sin((t * 10.0f - 0.75f) * c4) + 1.0f;
}

inline float Spring(float t) {
    // Damped spring oscillation — overshoots then settles
    constexpr float damping  = 6.0f;
    constexpr float stiffness = 14.0f;
    return 1.0f - std::exp(-damping * t) * std::cos(stiffness * t);
}

} // namespace ease

// ── Easing Function Type ────────────────────────────────────
using EaseFn = float(*)(float);

// ── Property Animation ──────────────────────────────────────
// Animates a single float from → to over a duration.

struct RESUI_API Animation {
    uint32_t id       = 0;       // unique identifier
    float    from     = 0.0f;
    float    to       = 1.0f;
    float    current  = 0.0f;    // current interpolated value
    float    progress = 0.0f;    // 0..1 time progress
    float    duration = 200.0f;  // milliseconds
    float    delay    = 0.0f;    // delay before start (ms)
    float    elapsed  = 0.0f;    // ms elapsed since creation
    EaseFn   easing   = ease::OutCubic;
    bool     finished = false;
    bool     started  = false;   // delay elapsed

    // Callback with (currentValue, animation)
    std::function<void(float, const Animation&)> onUpdate;
    std::function<void()> onComplete;

    // Advance by dt milliseconds, returns true if still active
    bool Tick(float dt) {
        if (finished) return false;
        elapsed += dt;

        // Handle delay
        if (elapsed < delay) return true;
        started = true;

        float t = (elapsed - delay) / duration;
        if (t >= 1.0f) {
            t = 1.0f;
            finished = true;
        }

        progress = t;
        float easedT = easing(t);
        current = from + (to - from) * easedT;

        if (onUpdate) onUpdate(current, *this);
        if (finished && onComplete) onComplete();

        return !finished;
    }
};

// ── Animation Manager ───────────────────────────────────────
// Centralized 60fps tick driving all active animations.
// Controls register animations; the manager calls Tick() each frame.

class RESUI_API AnimationManager {
public:
    static AnimationManager& Instance();

    // Start the global timer (call once at app init)
    void Start(HWND hostWindow);

    // Stop the timer (call at shutdown)
    void Stop();

    // Add an animation, returns its ID
    uint32_t Add(Animation anim);

    // Create a simple property animation
    uint32_t Animate(float from, float to, float durationMs,
                     EaseFn easing,
                     std::function<void(float, const Animation&)> onUpdate,
                     std::function<void()> onComplete = nullptr,
                     float delayMs = 0.0f);

    // Staggered: animate N items with increasing delay
    void AnimateStaggered(int count, float from, float to,
                          float durationMs, float staggerMs,
                          EaseFn easing,
                          std::function<void(int index, float value)> onUpdate,
                          std::function<void()> onAllComplete = nullptr);

    // Cancel an animation by ID
    void Cancel(uint32_t id);

    // Cancel all animations
    void CancelAll();

    // True if any animations are running
    bool IsAnimating() const;

    // Number of active animations
    int Count() const;

private:
    AnimationManager() = default;

    void OnTick();

    static void CALLBACK TimerCallback(HWND hwnd, UINT msg, UINT_PTR id, DWORD time);

    std::vector<Animation> m_animations;
    HWND       m_hostWindow = nullptr;
    UINT_PTR   m_timerId    = 0;
    uint32_t   m_nextId     = 1;
    DWORD      m_lastTick   = 0;
    bool       m_running    = false;

    static constexpr UINT kFrameInterval = 16; // ~60fps
};

// ── Convenience Helpers ─────────────────────────────────────

// Lerp between two COLORREF values
inline COLORREF LerpColor(COLORREF a, COLORREF b, float t) {
    return RGB(
        static_cast<BYTE>(GetRValue(a) + (GetRValue(b) - GetRValue(a)) * t),
        static_cast<BYTE>(GetGValue(a) + (GetGValue(b) - GetGValue(a)) * t),
        static_cast<BYTE>(GetBValue(a) + (GetBValue(b) - GetBValue(a)) * t)
    );
}

// Lerp between two floats
inline float Lerp(float a, float b, float t) {
    return a + (b - a) * t;
}

} // namespace rui
