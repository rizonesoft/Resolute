#pragma once
#include <string>
#include <vector>
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

    // The name to draw for `name`: itself when it resolves, else the
    // fallback glyph, so a missing icon is visible rather than blank. An
    // unknown name is logged once (OutputDebugString) and remembered for
    // UnknownNames, which the render suite asserts is empty (D00 T02 §9).
    static constexpr const char* kFallbackIcon = "square-dashed";
    static const char* Resolve(const char* name);
    static std::vector<std::string> UnknownNames();
    static void ClearUnknownNames();

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
