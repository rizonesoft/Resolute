#include <resolute/icons.h>

namespace rui {

HMODULE LucideIcons::s_dll       = nullptr;
LucideIcons::FnGetCount  LucideIcons::s_getCount  = nullptr;
LucideIcons::FnGetName   LucideIcons::s_getName   = nullptr;
LucideIcons::FnRender    LucideIcons::s_render    = nullptr;
LucideIcons::FnFree      LucideIcons::s_free      = nullptr;
LucideIcons::FnCreateBmp LucideIcons::s_createBmp = nullptr;
LucideIcons::FnGetSvg    LucideIcons::s_getSvg    = nullptr;

bool LucideIcons::Load() {
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
