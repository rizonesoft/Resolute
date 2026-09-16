#include "lucide.h"
#include "icons_data.h"

#include <lunasvg.h>
#include <cstring>
#include <string>
#include <unordered_map>
#include <mutex>
#include <memory>

#include <windows.h>

// ── Icon Registry ───────────────────────────────────────────
static std::unordered_map<std::string, int>& GetNameIndex() {
    static std::unordered_map<std::string, int> map = []() {
        std::unordered_map<std::string, int> m;
        for (int i = 0; i < kIconCount; i++)
            m[kIcons[i].name] = i;
        return m;
    }();
    return map;
}

// ── Color injection ─────────────────────────────────────────
// Lucide SVGs use stroke="currentColor". We replace it with the requested color.
static std::string InjectColor(const char* svg, uint32_t color) {
    char hex[8];
    snprintf(hex, sizeof(hex), "#%02X%02X%02X",
        (color >> 16) & 0xFF,
        (color >>  8) & 0xFF,
        (color      ) & 0xFF
    );

    std::string result(svg);
    const std::string target = "currentColor";
    size_t pos = 0;
    while ((pos = result.find(target, pos)) != std::string::npos) {
        result.replace(pos, target.length(), hex);
        pos += 7;
    }
    return result;
}

// ── Public API ──────────────────────────────────────────────

extern "C" {

LUCIDE_API int LucideGetIconCount(void) {
    return kIconCount;
}

LUCIDE_API const char* LucideGetIconName(int index) {
    if (index < 0 || index >= kIconCount) return nullptr;
    return kIcons[index].name;
}

LUCIDE_API uint8_t* LucideRenderIcon(const char* name, int size, uint32_t color) {
    if (!name || size <= 0) return nullptr;

    auto& idx = GetNameIndex();
    auto it = idx.find(name);
    if (it == idx.end()) return nullptr;

    std::string colored = InjectColor(kIcons[it->second].svg, color);

    auto doc = lunasvg::Document::loadFromData(colored);
    if (!doc) return nullptr;

    auto bitmap = doc->renderToBitmap(size, size);
    if (!bitmap.valid()) return nullptr;

    size_t bytes = static_cast<size_t>(size) * size * 4;
    auto* out = static_cast<uint8_t*>(malloc(bytes));
    if (!out) return nullptr;

    // lunasvg renders BGRA premultiplied — convert to RGBA
    const auto* src = bitmap.data();
    for (size_t i = 0; i < bytes; i += 4) {
        out[i + 0] = src[i + 2]; // R (from B)
        out[i + 1] = src[i + 1]; // G
        out[i + 2] = src[i + 0]; // B (from R)
        out[i + 3] = src[i + 3]; // A
    }

    return out;
}

LUCIDE_API void LucideFree(void* ptr) {
    free(ptr);
}

LUCIDE_API const char* LucideGetSvgData(const char* name) {
    if (!name) return nullptr;
    auto& idx = GetNameIndex();
    auto it = idx.find(name);
    if (it == idx.end()) return nullptr;
    return kIcons[it->second].svg;
}

LUCIDE_API void* LucideCreateHBitmap(const char* name, int size, uint32_t color) {
    if (!name || size <= 0) return nullptr;

    auto& idx = GetNameIndex();
    auto it = idx.find(name);
    if (it == idx.end()) return nullptr;

    std::string colored = InjectColor(kIcons[it->second].svg, color);

    auto doc = lunasvg::Document::loadFromData(colored);
    if (!doc) return nullptr;

    auto bitmap = doc->renderToBitmap(size, size);
    if (!bitmap.valid()) return nullptr;

    // Create a top-down 32-bit DIB section
    BITMAPINFO bmi{};
    bmi.bmiHeader.biSize        = sizeof(BITMAPINFOHEADER);
    bmi.bmiHeader.biWidth       = size;
    bmi.bmiHeader.biHeight      = -size; // top-down
    bmi.bmiHeader.biPlanes      = 1;
    bmi.bmiHeader.biBitCount    = 32;
    bmi.bmiHeader.biCompression = BI_RGB;

    void* bits = nullptr;
    HBITMAP hbm = CreateDIBSection(nullptr, &bmi, DIB_RGB_COLORS, &bits, nullptr, 0);
    if (!hbm || !bits) return nullptr;

    // lunasvg outputs BGRA premultiplied — perfect for Win32 AlphaBlend
    memcpy(bits, bitmap.data(), static_cast<size_t>(size) * size * 4);

    return hbm;
}

} // extern "C"
