#include <resolute/render.h>
#include <resolute/typography.h>
#include <resolute/icons.h>
#include <objbase.h>  // CreateStreamOnHGlobal
#include <string>
#include <cstdio>
#include <cstring>

namespace rui {

ComPtr<ID2D1Factory> RenderContext::s_d2dFactory;
ComPtr<IDWriteFactory> RenderContext::s_dwriteFactory;
bool RenderContext::s_svgChecked = false;
bool RenderContext::s_svgSupported = false;
std::unordered_map<std::string, ComPtr<ID2D1SvgDocument>> RenderContext::s_svgCache;

bool RenderContext::Init() {
    HRESULT hr = D2D1CreateFactory(
        D2D1_FACTORY_TYPE_SINGLE_THREADED,
        s_d2dFactory.GetAddressOf()
    );
    if (FAILED(hr)) return false;

    hr = DWriteCreateFactory(
        DWRITE_FACTORY_TYPE_SHARED,
        __uuidof(IDWriteFactory),
        reinterpret_cast<IUnknown**>(s_dwriteFactory.GetAddressOf())
    );
    return SUCCEEDED(hr);
}

ID2D1Factory* RenderContext::D2D() { return s_d2dFactory.Get(); }
IDWriteFactory* RenderContext::DWrite() { return s_dwriteFactory.Get(); }

ComPtr<ID2D1HwndRenderTarget> RenderContext::CreateHwndTarget(HWND hwnd) {
    RECT rc;
    GetClientRect(hwnd, &rc);
    D2D1_SIZE_U size = D2D1::SizeU(rc.right - rc.left, rc.bottom - rc.top);

    ComPtr<ID2D1HwndRenderTarget> target;
    auto props = D2D1::RenderTargetProperties();
    props.dpiX = 96.0f;
    props.dpiY = 96.0f;
    auto hwndProps = D2D1::HwndRenderTargetProperties(hwnd, size);

    s_d2dFactory->CreateHwndRenderTarget(props, hwndProps, &target);
    if (target) Typography::ApplyRendering(target.Get());
    return target;
}

ComPtr<ID2D1Bitmap> RenderContext::CreateBitmapFromRGBA(
    ID2D1RenderTarget* rt, const uint8_t* rgba, int width, int height)
{
    if (!rt || !rgba || width <= 0 || height <= 0) return nullptr;

    ComPtr<ID2D1Bitmap> bitmap;
    D2D1_BITMAP_PROPERTIES bmpProps = D2D1::BitmapProperties(
        D2D1::PixelFormat(DXGI_FORMAT_R8G8B8A8_UNORM, D2D1_ALPHA_MODE_PREMULTIPLIED)
    );
    bmpProps.dpiX = 96.0f;
    bmpProps.dpiY = 96.0f;

    rt->CreateBitmap(
        D2D1::SizeU(width, height),
        rgba, width * 4,
        bmpProps, &bitmap
    );
    return bitmap;
}

ComPtr<IDWriteTextFormat> RenderContext::CreateTextFormat(
    const wchar_t* fontFamily, float size, DWRITE_FONT_WEIGHT weight)
{
    ComPtr<IDWriteTextFormat> fmt;
    s_dwriteFactory->CreateTextFormat(
        fontFamily, nullptr, weight,
        DWRITE_FONT_STYLE_NORMAL, DWRITE_FONT_STRETCH_NORMAL,
        size, L"", &fmt
    );
    if (fmt) {
        fmt->SetTextAlignment(DWRITE_TEXT_ALIGNMENT_LEADING);
        fmt->SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_CENTER);
    }
    return fmt;
}

// ── D2D SVG Icon Rendering ──────────────────────────────────

bool RenderContext::SvgSupported() {
    return s_svgSupported;
}

void RenderContext::ClearSvgCache() {
    s_svgCache.clear();
}

bool RenderContext::DrawSvgIcon(ID2D1RenderTarget* rt, const char* name,
                                 const D2D1_RECT_F& rect, uint32_t color,
                                 float opacity)
{
    if (!rt || !name) return false;

    // One-time check: can we QI for ID2D1DeviceContext5?
    if (!s_svgChecked) {
        s_svgChecked = true;
        ComPtr<ID2D1DeviceContext5> dc5;
        HRESULT hr = rt->QueryInterface(IID_PPV_ARGS(&dc5));
        s_svgSupported = SUCCEEDED(hr) && dc5;
    }
    if (!s_svgSupported) return false;

    // Get device context 5
    ComPtr<ID2D1DeviceContext5> dc5;
    if (FAILED(rt->QueryInterface(IID_PPV_ARGS(&dc5)))) return false;

    // Build cache key: rt pointer + name + color
    // SVG documents are device-dependent — each RT needs its own
    char keyBuf[128];
    snprintf(keyBuf, sizeof(keyBuf), "%p:%s:#%02X%02X%02X",
        static_cast<void*>(rt), name,
        (color >> 16) & 0xFF, (color >> 8) & 0xFF, color & 0xFF);
    std::string cacheKey(keyBuf);

    char colorHex[16];
    snprintf(colorHex, sizeof(colorHex), "#%02X%02X%02X",
        (color >> 16) & 0xFF, (color >> 8) & 0xFF, color & 0xFF);

    // Check cache
    auto it = s_svgCache.find(cacheKey);
    ComPtr<ID2D1SvgDocument> svgDoc;

    if (it != s_svgCache.end()) {
        svgDoc = it->second;
    } else {
        // Get raw SVG data
        const char* svgData = LucideIcons::GetSvgData(name);
        if (!svgData) return false;

        // Inject color: replace "currentColor" with hex
        std::string svgStr(svgData);
        const std::string target = "currentColor";
        size_t pos = 0;
        while ((pos = svgStr.find(target, pos)) != std::string::npos) {
            svgStr.replace(pos, target.length(), colorHex);
            pos += 7;
        }

        // Strip width="..." and height="..." from root <svg> so D2D uses
        // the viewport size we supply (24×24) instead of embedded dimensions
        auto stripAttr = [&](const char* attr) {
            std::string pattern = std::string(attr) + "=\"";
            size_t start = svgStr.find(pattern);
            if (start != std::string::npos && start < svgStr.find('>')) {
                size_t end = svgStr.find('"', start + pattern.length());
                if (end != std::string::npos) {
                    // Remove attribute and any trailing space
                    size_t removeEnd = end + 1;
                    if (removeEnd < svgStr.size() && svgStr[removeEnd] == ' ')
                        removeEnd++;
                    svgStr.erase(start, removeEnd - start);
                }
            }
        };
        stripAttr("width");
        stripAttr("height");

        // Create IStream from SVG data using HGLOBAL
        size_t svgLen = svgStr.size();
        HGLOBAL hMem = GlobalAlloc(GMEM_MOVEABLE, svgLen);
        if (!hMem) return false;
        void* pMem = GlobalLock(hMem);
        memcpy(pMem, svgStr.c_str(), svgLen);
        GlobalUnlock(hMem);

        IStream* stream = nullptr;
        HRESULT hr = CreateStreamOnHGlobal(hMem, TRUE, &stream);
        if (FAILED(hr) || !stream) {
            GlobalFree(hMem);
            return false;
        }

        // Lucide icons have a 24x24 viewBox
        D2D1_SIZE_F viewBox = D2D1::SizeF(24.0f, 24.0f);
        hr = dc5->CreateSvgDocument(stream, viewBox, &svgDoc);
        stream->Release();

        if (FAILED(hr) || !svgDoc) return false;

        // Cache it
        s_svgCache[cacheKey] = svgDoc;
    }

    // Calculate target size and scale
    float targetW = rect.right - rect.left;
    float targetH = rect.bottom - rect.top;
    float scaleX = targetW / 24.0f;
    float scaleY = targetH / 24.0f;

    // Save transform, apply scale + translate
    D2D1_MATRIX_3X2_F oldTransform;
    dc5->GetTransform(&oldTransform);

    D2D1_MATRIX_3X2_F iconTransform =
        D2D1::Matrix3x2F::Scale(scaleX, scaleY) *
        D2D1::Matrix3x2F::Translation(rect.left, rect.top) *
        oldTransform;
    dc5->SetTransform(iconTransform);

    // Draw with opacity layer if needed
    if (opacity < 0.999f) {
        dc5->PushLayer(
            D2D1::LayerParameters(D2D1::InfiniteRect(),
                nullptr, D2D1_ANTIALIAS_MODE_PER_PRIMITIVE,
                D2D1::IdentityMatrix(), opacity),
            nullptr
        );
    }

    dc5->DrawSvgDocument(svgDoc.Get());

    if (opacity < 0.999f) {
        dc5->PopLayer();
    }

    // Restore transform
    dc5->SetTransform(oldTransform);

    return true;
}

} // namespace rui
