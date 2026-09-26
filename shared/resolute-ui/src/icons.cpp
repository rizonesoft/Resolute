#include <resolute/icons.h>

#include <set>

namespace rui {

HMODULE LucideIcons::s_dll       = nullptr;
LucideIcons::FnGetCount  LucideIcons::s_getCount  = nullptr;
LucideIcons::FnGetName   LucideIcons::s_getName   = nullptr;
LucideIcons::FnRender    LucideIcons::s_render    = nullptr;
LucideIcons::FnFree      LucideIcons::s_free      = nullptr;
LucideIcons::FnCreateBmp LucideIcons::s_createBmp = nullptr;
LucideIcons::FnGetSvg    LucideIcons::s_getSvg    = nullptr;

#if defined(LUCIDE_STATIC)
#include <lucide.h>
#endif

bool LucideIcons::Load() {
#if defined(LUCIDE_STATIC)
    // Lucide is linked in, so there is nothing to find and nothing to fail.
    // The function pointers are still populated, so every call site below and
    // in the tools is unchanged: only where the addresses come from differs.
    //
    // D00 T01 §2. The LoadLibraryW path below was the one thing keeping a DLL
    // beside the executable, and an import-table check could never see it.
    if (s_getCount) return true;
    s_getCount  = &LucideGetIconCount;
    s_getName   = &LucideGetIconName;
    s_render    = &LucideRenderIcon;
    s_free      = &LucideFree;
    // No cast. FnCreateBmp is void*(*)(const char*, int, uint32_t) and that is
    // exactly LucideCreateHBitmap's signature, so a plain assignment is
    // type-checked. A reinterpret_cast here would compile whatever the
    // signature became, which is the opposite of what direct binding is for.
    s_createBmp = &LucideCreateHBitmap;
    s_getSvg    = &LucideGetSvgData;
    return true;
#else
    if (s_dll) return true;
    s_dll = LoadLibraryW(L"System\\Lucide.dll");
    if (!s_dll) s_dll = LoadLibraryW(L"Lucide.dll");
    if (!s_dll) return false;

    s_getCount  = reinterpret_cast<FnGetCount>(GetProcAddress(s_dll, "LucideGetIconCount"));
    s_getName   = reinterpret_cast<FnGetName>(GetProcAddress(s_dll, "LucideGetIconName"));
    s_render    = reinterpret_cast<FnRender>(GetProcAddress(s_dll, "LucideRenderIcon"));
    s_free      = reinterpret_cast<FnFree>(GetProcAddress(s_dll, "LucideFree"));
    s_createBmp = reinterpret_cast<FnCreateBmp>(GetProcAddress(s_dll, "LucideCreateHBitmap"));
    s_getSvg    = reinterpret_cast<FnGetSvg>(GetProcAddress(s_dll, "LucideGetSvgData"));

    return s_getCount && s_getName && s_render && s_free && s_createBmp;
#endif
}

int LucideIcons::GetCount() { return s_getCount ? s_getCount() : 0; }
const char* LucideIcons::GetName(int idx) { return s_getName ? s_getName(idx) : nullptr; }

namespace {
std::set<std::string>& UnknownSet() {
    static std::set<std::string> names;
    return names;
}

// Logs a name that does not resolve, once, and remembers it for UnknownNames.
void NoteUnknown(const char* name) {
    const std::string shown = name ? name : "(null)";
    if (UnknownSet().insert(shown).second) {
        const std::string line = "ResoluteUI: unknown icon \"" + shown + "\"\n";
        OutputDebugStringA(line.c_str());
    }
}
}  // namespace

// The two draw calls resolve their name, so a computed or malformed name
// passed straight to them draws the fallback glyph and is reported like one
// passed through Resolve. GetSvgData stays a strict lookup: it returns null
// for an unknown name, which the icon manifest relies on, and reports it
// (D00 T02 §9, panel rounds 1 and 2 of its review).
uint8_t* LucideIcons::Render(const char* name, int size, uint32_t color) {
    if (!s_render || size <= 0) return nullptr;
    return s_render(Resolve(name), size, color);
}

void LucideIcons::Free(void* ptr) { if (s_free) s_free(ptr); }

HBITMAP LucideIcons::CreateBitmap(const char* name, int size, uint32_t color) {
    if (!s_createBmp || size <= 0) return nullptr;
    return static_cast<HBITMAP>(s_createBmp(Resolve(name), size, color));
}

const char* LucideIcons::GetSvgData(const char* name) {
    const char* svg = s_getSvg ? s_getSvg(name) : nullptr;
    if (!svg && name) NoteUnknown(name);
    return svg;
}

const char* LucideIcons::Resolve(const char* name) {
    if (name && s_getSvg && s_getSvg(name)) return name;
    NoteUnknown(name);
    return kFallbackIcon;
}

std::vector<std::string> LucideIcons::UnknownNames() {
    return {UnknownSet().begin(), UnknownSet().end()};
}

void LucideIcons::ClearUnknownNames() { UnknownSet().clear(); }

} // namespace rui
