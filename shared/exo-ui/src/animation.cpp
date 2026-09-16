#include <exo/animation.h>

namespace exo {

// ── Singleton ───────────────────────────────────────────────
AnimationManager& AnimationManager::Instance() {
    static AnimationManager instance;
    return instance;
}

// ── Timer ───────────────────────────────────────────────────
void AnimationManager::Start(HWND hostWindow) {
    if (m_running) return;
    m_hostWindow = hostWindow;
    m_lastTick   = GetTickCount();
    m_timerId    = SetTimer(hostWindow, 0xEA01, kFrameInterval, TimerCallback);
    m_running    = true;
}

void AnimationManager::Stop() {
    if (!m_running) return;
    KillTimer(m_hostWindow, m_timerId);
    m_timerId = 0;
    m_running = false;
    m_animations.clear();
}

void CALLBACK AnimationManager::TimerCallback(HWND, UINT, UINT_PTR, DWORD) {
    Instance().OnTick();
}

void AnimationManager::OnTick() {
    if (m_animations.empty()) return;

    DWORD now = GetTickCount();
    float dt  = static_cast<float>(now - m_lastTick);
    m_lastTick = now;

    // Clamp deltatime to avoid huge jumps (e.g., after sleep/breakpoint)
    if (dt > 100.0f) dt = 16.0f;

    // Tick all animations, remove finished ones
    m_animations.erase(
        std::remove_if(m_animations.begin(), m_animations.end(),
            [dt](Animation& anim) { return !anim.Tick(dt); }),
        m_animations.end()
    );
}

// ── Add / Animate ───────────────────────────────────────────
uint32_t AnimationManager::Add(Animation anim) {
    anim.id      = m_nextId++;
    anim.current = anim.from;
    m_animations.push_back(std::move(anim));
    return anim.id;
}

uint32_t AnimationManager::Animate(
    float from, float to, float durationMs,
    EaseFn easing,
    std::function<void(float, const Animation&)> onUpdate,
    std::function<void()> onComplete,
    float delayMs)
{
    Animation a;
    a.from       = from;
    a.to         = to;
    a.current    = from;
    a.duration   = durationMs;
    a.delay      = delayMs;
    a.easing     = easing;
    a.onUpdate   = std::move(onUpdate);
    a.onComplete = std::move(onComplete);
    return Add(std::move(a));
}

void AnimationManager::AnimateStaggered(
    int count, float from, float to,
    float durationMs, float staggerMs,
    EaseFn easing,
    std::function<void(int index, float value)> onUpdate,
    std::function<void()> onAllComplete)
{
    auto completed = std::make_shared<int>(0);

    for (int i = 0; i < count; i++) {
        float delay = static_cast<float>(i) * staggerMs;

        // Capture index by value
        auto updateFn = [i, onUpdate](float val, const Animation&) {
            if (onUpdate) onUpdate(i, val);
        };

        auto completeFn = [completed, count, onAllComplete]() {
            (*completed)++;
            if (*completed >= count && onAllComplete) {
                onAllComplete();
            }
        };

        Animate(from, to, durationMs, easing,
                std::move(updateFn), std::move(completeFn), delay);
    }
}

// ── Cancel ──────────────────────────────────────────────────
void AnimationManager::Cancel(uint32_t id) {
    m_animations.erase(
        std::remove_if(m_animations.begin(), m_animations.end(),
            [id](const Animation& a) { return a.id == id; }),
        m_animations.end()
    );
}

void AnimationManager::CancelAll() {
    m_animations.clear();
}

// ── Queries ─────────────────────────────────────────────────
bool AnimationManager::IsAnimating() const {
    return !m_animations.empty();
}

int AnimationManager::Count() const {
    return static_cast<int>(m_animations.size());
}

} // namespace exo
