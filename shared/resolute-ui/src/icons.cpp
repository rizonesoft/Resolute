#include <resolute/icons.h>

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
    s_createBmp = reinterpret_cast<FnCreateBmp>(&LucideCreateHBitmap);
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

uint8_t* LucideIcons::Render(const char* name, int size, uint32_t color) {
    return s_render ? s_render(name, size, color) : nullptr;
}

void LucideIcons::Free(void* ptr) { if (s_free) s_free(ptr); }

HBITMAP LucideIcons::CreateBitmap(const char* name, int size, uint32_t color) {
    return s_createBmp ? static_cast<HBITMAP>(s_createBmp(name, size, color)) : nullptr;
}

const char* LucideIcons::GetSvgData(const char* name) {
    return s_getSvg ? s_getSvg(name) : nullptr;
}

} // namespace rui
