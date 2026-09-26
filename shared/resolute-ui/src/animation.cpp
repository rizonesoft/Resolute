#include <resolute/animation.h>

namespace rui {

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

    // Tick a moved-out copy: animations added by callbacks land in
    // m_animations and join after the frame; cancellations are recorded
    // and skip every later callback of the frame.
    std::vector<Animation> ticking;
    ticking.swap(m_animations);
    m_ticking   = true;
    m_cancelAll = false;
    m_cancelledIds.clear();
    m_deadOwners.clear();

    std::vector<Animation> kept;
    kept.reserve(ticking.size());
    for (auto& anim : ticking) {
        if (Dropped(anim)) continue;
        if (anim.Tick(dt) && !Dropped(anim)) kept.push_back(std::move(anim));
    }
    m_ticking = false;

    for (auto& added : m_animations) kept.push_back(std::move(added));
    m_animations.swap(kept);
    m_cancelledIds.clear();
    m_deadOwners.clear();
    m_cancelAll = false;
}

bool AnimationManager::Dropped(const Animation& a) const {
    if (m_cancelAll) return true;
    if (std::find(m_cancelledIds.begin(), m_cancelledIds.end(), a.id) != m_cancelledIds.end()) return true;
    return a.owner && std::find(m_deadOwners.begin(), m_deadOwners.end(), a.owner) != m_deadOwners.end();
}

// ── Add / Animate ───────────────────────────────────────────
uint32_t AnimationManager::Add(Animation anim) {
    const uint32_t id = m_nextId++;
    anim.id      = id;
    anim.current = anim.from;
    m_animations.push_back(std::move(anim));
    return id;
}

uint32_t AnimationManager::Animate(
    float from, float to, float durationMs,
    EaseFn easing,
    std::function<void(float, const Animation&)> onUpdate,
    std::function<void()> onComplete,
    float delayMs)
{
    return AnimateFor(nullptr, from, to, durationMs, easing, std::move(onUpdate), std::move(onComplete), delayMs);
}

uint32_t AnimationManager::AnimateFor(
    const void* owner,
    float from, float to, float durationMs,
    EaseFn easing,
    std::function<void(float, const Animation&)> onUpdate,
    std::function<void()> onComplete,
    float delayMs)
{
    Animation a;
    a.owner      = owner;
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
    const std::function<void(int index, float value)>& onUpdate,
    const std::function<void()>& onAllComplete)
{
    AnimateStaggeredFor(nullptr, count, from, to, durationMs, staggerMs, easing, onUpdate, onAllComplete);
}

void AnimationManager::AnimateStaggeredFor(
    const void* owner,
    int count, float from, float to,
    float durationMs, float staggerMs,
    EaseFn easing,
    const std::function<void(int index, float value)>& onUpdate,
    const std::function<void()>& onAllComplete)
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

        AnimateFor(owner, from, to, durationMs, easing,
                   std::move(updateFn), std::move(completeFn), delay);
    }
}

// ── Cancel ──────────────────────────────────────────────────
void AnimationManager::Cancel(uint32_t id) {
    if (m_ticking) m_cancelledIds.push_back(id);
    m_animations.erase(
        std::remove_if(m_animations.begin(), m_animations.end(),
            [id](const Animation& a) { return a.id == id; }),
        m_animations.end()
    );
}

void AnimationManager::CancelAll() {
    if (m_ticking) m_cancelAll = true;
    m_animations.clear();
}

void AnimationManager::CancelOwner(const void* owner) {
    if (!owner) return;
    if (m_ticking) m_deadOwners.push_back(owner);
    m_animations.erase(
        std::remove_if(m_animations.begin(), m_animations.end(),
            [owner](const Animation& a) { return a.owner == owner; }),
        m_animations.end()
    );
}

// ── Queries ─────────────────────────────────────────────────
bool AnimationManager::IsAnimating() const {
    return !m_animations.empty();
}

int AnimationManager::Count() const {
    return static_cast<int>(m_animations.size());
}

} // namespace rui
