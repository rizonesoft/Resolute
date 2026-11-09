// Shared helpers for the visual pair cases: PNG loading through WIC, the
// region spec parser, and measuring every spec region in an image.
// D00 T02 section 12.

#pragma once

#include <wincodec.h>
#include <wrl/client.h>

#include <filesystem>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>

#include "visual_pair.h"

namespace visualpair {

inline IWICImagingFactory* WicFactory() {
    static Microsoft::WRL::ComPtr<IWICImagingFactory> factory = [] {
        CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
        Microsoft::WRL::ComPtr<IWICImagingFactory> f;
        CoCreateInstance(CLSID_WICImagingFactory, nullptr, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&f));
        return f;
    }();
    return factory.Get();
}

inline bool LoadPng(const std::filesystem::path& path, Image& img) {
    Microsoft::WRL::ComPtr<IWICBitmapDecoder> dec;
    Microsoft::WRL::ComPtr<IWICBitmapFrameDecode> frame;
    Microsoft::WRL::ComPtr<IWICFormatConverter> conv;
    if (FAILED(WicFactory()->CreateDecoderFromFilename(path.c_str(), nullptr, GENERIC_READ,
                                                       WICDecodeMetadataCacheOnDemand, &dec)) ||
        FAILED(dec->GetFrame(0, &frame)) || FAILED(WicFactory()->CreateFormatConverter(&conv)) ||
        FAILED(conv->Initialize(frame.Get(), GUID_WICPixelFormat32bppBGRA, WICBitmapDitherTypeNone, nullptr, 0.0,
                                WICBitmapPaletteTypeCustom)))
        return false;
    UINT w = 0, h = 0;
    conv->GetSize(&w, &h);
    img.w = static_cast<int>(w);
    img.h = static_cast<int>(h);
    img.px.assign(static_cast<size_t>(w) * h, 0);
    return SUCCEEDED(conv->CopyPixels(nullptr, w * 4, w * h * 4, reinterpret_cast<BYTE*>(img.px.data())));
}

struct Spec {
    std::vector<RegionSpec> regions;
    EquivalenceMap equivalents;
};

inline Spec LoadSpec() {
    Spec out;
    std::ifstream in(std::filesystem::path(RESOLUTE_SOURCE_ROOT) / "tests" / "visual_pair_spec.txt");
    std::string line;
    while (std::getline(in, line)) {
        if (line.empty() || line[0] == '#') continue;
        std::vector<std::string> f;
        std::stringstream ss(line);
        std::string cell;
        while (std::getline(ss, cell, '|')) f.push_back(cell);
        if (f.size() >= 2 && f[0] == "equiv") {
            out.equivalents[f[1]] = f[2];
        } else if (f.size() >= 11 && f[0] == "region") {
            RegionSpec r;
            r.name = f[1];
            r.label = f[2];
            r.value = f[3];
            r.x0 = std::stod(f[4]);
            r.y0 = std::stod(f[5]);
            r.x1 = std::stod(f[6]);
            r.y1 = std::stod(f[7]);
            r.minPainted = std::stod(f[8]);
            r.minDetail = std::stod(f[9]);
            r.text = f[10] == "text";
            out.regions.push_back(r);
        }
    }
    return out;
}

inline std::vector<Observed> MeasureAll(const Image& img, const std::vector<RegionSpec>& regions) {
    std::vector<Observed> out;
    for (const RegionSpec& r : regions) {
        Observed o;
        MeasureRegion(img, r, o);
        if (!r.label.empty()) o.label = r.label;  // labels come from the spec record
        out.push_back(o);
    }
    return out;
}

inline std::filesystem::path Baseline150() {
    return std::filesystem::path(RESOLUTE_SOURCE_ROOT) / "docs" / "captures" / "runs" /
           "2026-11-09-D00-T02-s10-launcher-light-150.png";
}

}  // namespace visualpair
