#include <resolute/typography.h>
#include <resolute/render.h>
#include <resolute/dpi.h>
#include <dwrite_3.h>

namespace rui {

ComPtr<IDWriteFontCollection> Typography::s_fontCollection;

// ── Format ──────────────────────────────────────────────────
ComPtr<IDWriteTextFormat> Typography::Format(
    TypeStyle style, FontWeight weight, int dpi)
{
    int idx = static_cast<int>(style);
    if (idx < 0 || idx >= kTypeStyleCount) idx = 1; // fallback to Body

    float basePx = kTypeSizes[idx];
    float scaled = Dpi::ScaleF(basePx, dpi);

    auto dw = static_cast<DWRITE_FONT_WEIGHT>(static_cast<int>(weight));

    ComPtr<IDWriteTextFormat> fmt;
    auto* factory = RenderContext::DWrite();
    if (!factory) return nullptr;

    factory->CreateTextFormat(
        L"Segoe UI",
        s_fontCollection.Get(),  // null = system collection
        dw,
        DWRITE_FONT_STYLE_NORMAL,
        DWRITE_FONT_STRETCH_NORMAL,
        scaled,
        L"",
        &fmt
    );

    if (fmt) {
        fmt->SetTextAlignment(DWRITE_TEXT_ALIGNMENT_LEADING);
        fmt->SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_CENTER);
    }
    return fmt;
}

// ── LoadFonts ───────────────────────────────────────────────
bool Typography::LoadFonts(const wchar_t* fontDir) {
    if (!fontDir) return false;

    auto* factory = RenderContext::DWrite();
    if (!factory) return false;

    // Try IDWriteFactory3 for custom font sets
    ComPtr<IDWriteFactory3> factory3;
    HRESULT hr = factory->QueryInterface(IID_PPV_ARGS(&factory3));
    if (FAILED(hr) || !factory3) return false;

    ComPtr<IDWriteFontSetBuilder1> builder;
    // Try IDWriteFactory5 for AddFontFile
    ComPtr<IDWriteFactory5> factory5;
    hr = factory->QueryInterface(IID_PPV_ARGS(&factory5));
    if (SUCCEEDED(hr) && factory5) {
        ComPtr<IDWriteFontSetBuilder1> builder1;
        hr = factory5->CreateFontSetBuilder(&builder1);
        if (FAILED(hr)) return false;

        // Enumerate font files in directory
        std::wstring searchPath = std::wstring(fontDir) + L"\\*";
        WIN32_FIND_DATAW findData;
        HANDLE hFind = FindFirstFileW(searchPath.c_str(), &findData);
        if (hFind == INVALID_HANDLE_VALUE) return false;

        bool anyLoaded = false;
        do {
            if (findData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
                continue;

            std::wstring name(findData.cFileName);
            // Only .ttf and .otf
            auto ext = name.substr(name.find_last_of(L'.') + 1);
            for (auto& ch : ext) ch = towlower(ch);
            if (ext != L"ttf" && ext != L"otf") continue;

            std::wstring fullPath = std::wstring(fontDir) + L"\\" + name;

            ComPtr<IDWriteFontFile> fontFile;
            hr = factory5->CreateFontFileReference(fullPath.c_str(),
                                                    nullptr, &fontFile);
            if (SUCCEEDED(hr) && fontFile) {
                hr = builder1->AddFontFile(fontFile.Get());
                if (SUCCEEDED(hr)) anyLoaded = true;
            }
        } while (FindNextFileW(hFind, &findData));
        FindClose(hFind);

        if (!anyLoaded) return false;

        ComPtr<IDWriteFontSet> fontSet;
        hr = builder1->CreateFontSet(&fontSet);
        if (FAILED(hr)) return false;

        ComPtr<IDWriteFontCollection1> coll1;
        hr = factory5->CreateFontCollectionFromFontSet(fontSet.Get(), &coll1);
        if (FAILED(hr) || !coll1) return false;
        hr = coll1.As(&s_fontCollection);
        return SUCCEEDED(hr);
    }

    return false;
}

// ── ApplyRendering ──────────────────────────────────────────
void Typography::ApplyRendering(ID2D1RenderTarget* rt) {
    if (!rt) return;

    // Set ClearType text antialiasing
    rt->SetTextAntialiasMode(D2D1_TEXT_ANTIALIAS_MODE_CLEARTYPE);

    // Create custom rendering params for crisp text
    auto* factory = RenderContext::DWrite();
    if (!factory) return;

    ComPtr<IDWriteRenderingParams> defaultParams;
    factory->CreateRenderingParams(&defaultParams);
    if (!defaultParams) return;

    ComPtr<IDWriteRenderingParams> customParams;
    factory->CreateCustomRenderingParams(
        defaultParams->GetGamma(),
        defaultParams->GetEnhancedContrast(),
        defaultParams->GetClearTypeLevel(),
        defaultParams->GetPixelGeometry(),
        DWRITE_RENDERING_MODE_NATURAL_SYMMETRIC,
        &customParams
    );

    if (customParams) {
        rt->SetTextRenderingParams(customParams.Get());
    }
}

// ── FontCollection ──────────────────────────────────────────
IDWriteFontCollection* Typography::FontCollection() {
    return s_fontCollection.Get();
}

// ── Layout ──────────────────────────────────────────────────
ComPtr<IDWriteTextLayout> Typography::Layout(
    const wchar_t* text, UINT32 len,
    TypeStyle style, FontWeight weight,
    float maxW, float maxH, int dpi)
{
    auto fmt = Format(style, weight, dpi);
    if (!fmt) return nullptr;

    auto* factory = RenderContext::DWrite();
    if (!factory) return nullptr;

    ComPtr<IDWriteTextLayout> layout;
    factory->CreateTextLayout(text, len, fmt.Get(), maxW, maxH, &layout);
    if (!layout) return nullptr;

    // Apply letter spacing
    int idx = static_cast<int>(style);
    if (idx >= 0 && idx < kTypeStyleCount) {
        float spacing = kTypeSpacing[idx] * Dpi::ScaleF(1.0f, dpi);

        ComPtr<IDWriteTextLayout1> layout1;
        if (SUCCEEDED(layout.As(&layout1))) {
            DWRITE_TEXT_RANGE range = { 0, len };
            layout1->SetCharacterSpacing(
                spacing * 0.5f,  // leading
                spacing * 0.5f,  // trailing
                0.0f,            // min advance width
                range
            );
        }
    }

    return layout;
}

} // namespace rui
