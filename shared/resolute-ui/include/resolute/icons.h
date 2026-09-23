#pragma once
// ── Lucide Icon Loader ──────────────────────────────────────

#include <windows.h>
#include <cstdint>
#include "export.h"

namespace rui {

class RESUI_API LucideIcons {
public:
    static bool Load();
    static int GetCount();
    static const char* GetName(int idx);
    static uint8_t* Render(const char* name, int size, uint32_t color);
    static void Free(void* ptr);
    static HBITMAP CreateBitmap(const char* name, int size, uint32_t color);
    static const char* GetSvgData(const char* name);

private:
    using FnGetCount  = int(*)();
    using FnGetName   = const char*(*)(int);
    using FnRender    = uint8_t*(*)(const char*, int, uint32_t);
    using FnFree      = void(*)(void*);
    using FnCreateBmp = void*(*)(const char*, int, uint32_t);
    using FnGetSvg    = const char*(*)(const char*);

    static HMODULE s_dll;
    static FnGetCount  s_getCount;
    static FnGetName   s_getName;
    static FnRender    s_render;
    static FnFree      s_free;
    static FnCreateBmp s_createBmp;
    static FnGetSvg    s_getSvg;
};

} // namespace rui
