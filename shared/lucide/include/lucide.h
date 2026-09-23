#pragma once
// ── Lucide Icon Library — Public API ────────────────────────
// Renders Lucide SVG icons at any size and color.

#ifdef __cplusplus
extern "C" {
#endif

#if defined(LUCIDE_STATIC)
    // Linked into the caller. No import or export decoration: the symbols are
    // ordinary ones, which is what lets the launcher ship as a single file.
    #define LUCIDE_API
#elif defined(LUCIDE_BUILD)
    #define LUCIDE_API __declspec(dllexport)
#else
    #define LUCIDE_API __declspec(dllimport)
#endif

#include <stdint.h>

/// Get the number of available icons.
LUCIDE_API int LucideGetIconCount(void);

/// Get the name of an icon by index (0-based).
/// Returns nullptr if index is out of range.
LUCIDE_API const char* LucideGetIconName(int index);

/// Render an icon to an RGBA8888 bitmap.
/// @param name   Icon name (e.g. "refresh", "settings")
/// @param size   Output bitmap width and height in pixels
/// @param color  Icon stroke color as 0xRRGGBB (alpha is always 255)
/// @return       Pointer to size*size*4 bytes of RGBA data, or nullptr on failure.
///               Caller must free with LucideFree().
LUCIDE_API uint8_t* LucideRenderIcon(const char* name, int size, uint32_t color);

/// Free memory returned by LucideRenderIcon.
LUCIDE_API void LucideFree(void* ptr);

/// Get raw SVG XML data for an icon (with currentColor intact).
/// @param name   Icon name
/// @return       Pointer to null-terminated SVG string, or nullptr if not found.
///               The pointer is valid for the lifetime of the DLL. Do NOT free.
LUCIDE_API const char* LucideGetSvgData(const char* name);

/// Render an icon and create a Win32 HBITMAP (premultiplied alpha, top-down DIB).
/// @param name   Icon name
/// @param size   Bitmap width and height in pixels
/// @param color  Icon stroke color as 0xRRGGBB
/// @return       HBITMAP handle, or NULL on failure. Caller must DeleteObject().
LUCIDE_API void* LucideCreateHBitmap(const char* name, int size, uint32_t color);

#ifdef __cplusplus
}
#endif
