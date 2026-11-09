// Shared helpers for the visual pair cases: PNG loading through WIC, the
// region spec parser, and measuring every spec region in an image.
// D00 T02 section 12.

#pragma once

#include <wincodec.h>
#include <wrl/client.h>

#include <filesystem>
#include <fstream>
#include <sstream>
#include <cmath>
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
    std::vector<std::string> errors;  // file:line diagnostics; empty only when usable
};

// Parses one spec stream, validating semantically: field counts, finite
// numbers, bounds inside [0,1] and ordered, known kinds, unique names,
// non-negative floors. Every rejection names the source and line, so an
// authoring error fails loudly instead of silently dropping a check.
inline Spec ParseSpec(std::istream& in, const std::string& source) {
    Spec out;
    auto fail = [&](int line, const std::string& what) {
        out.errors.push_back(source + ":" + std::to_string(line) + ": " + what);
    };
    std::string line;
    int lineno = 0;
    while (std::getline(in, line)) {
        ++lineno;
        if (line.empty() || line[0] == '#') continue;
        std::vector<std::string> f;
        std::stringstream ss(line);
        std::string cell;
        while (std::getline(ss, cell, '|')) f.push_back(cell);
        if (f.empty()) continue;
        if (f[0] == "equiv") {
            if (f.size() != 3) {
                fail(lineno, "equiv needs exactly 3 fields");
            } else if (f[1].empty() || f[2].empty()) {
                fail(lineno, "equiv label and region must not be empty");
            } else {
                out.equivalents[f[1]] = f[2];
            }
            continue;
        }
        if (f[0] != "region") {
            fail(lineno, "unknown line kind '" + f[0] + "'");
            continue;
        }
        if (f.size() != 14) {
            fail(lineno, "region needs exactly 14 fields, found " + std::to_string(f.size()));
            continue;
        }
        RegionSpec r;
        r.name = f[1];
        r.label = f[2];
        r.value = f[3];
        double nums[6] = {};
        bool badNumber = false;
        for (int i = 0; i < 6; ++i) {
            try {
                size_t used = 0;
                nums[i] = std::stod(f[4 + i], &used);
                if (used != f[4 + i].size() || !std::isfinite(nums[i])) badNumber = true;
            } catch (...) {
                badNumber = true;
            }
        }
        if (badNumber) {
            fail(lineno, "region '" + r.name + "' has an unparsable or non-finite number");
            continue;
        }
        r.x0 = nums[0];
        r.y0 = nums[1];
        r.x1 = nums[2];
        r.y1 = nums[3];
        r.minPainted = nums[4];
        r.minDetail = nums[5];
        if (r.x0 < 0 || r.y0 < 0 || r.x1 > 1 || r.y1 > 1 || r.x0 >= r.x1 || r.y0 >= r.y1) {
            fail(lineno, "region '" + r.name + "' bounds are outside [0,1] or reversed");
            continue;
        }
        if (r.minPainted < 0 || r.minDetail < 0) {
            fail(lineno, "region '" + r.name + "' has a negative floor");
            continue;
        }
        if (f[10] != "text" && f[10] != "element") {
            fail(lineno, "region '" + r.name + "' kind must be text or element");
            continue;
        }
        r.text = f[10] == "text";
        {
            bool badTolerance = false;
            for (int i = 0; i < 2 && !badTolerance; ++i) {
                try {
                    size_t used = 0;
                    const double v = std::stod(f[11 + i], &used);
                    if (used != f[11 + i].size() || !std::isfinite(v) || v < 0) badTolerance = true;
                    else if (i == 0) r.maxEdge = v;
                    else r.maxMoved = v;
                } catch (...) {
                    badTolerance = true;
                }
            }
            if (badTolerance) {
                fail(lineno, "region '" + r.name + "' has an unparsable, non-finite, or negative tolerance");
                continue;
            }
        }
        if (f[13] != "check" && f[13] != "skip" && f[13] != "both" && f[13] != "border") {
            fail(lineno, "region '" + r.name + "' contrast must be check, border, both, or skip");
            continue;
        }
        r.checkContrast = f[13] == "check" || f[13] == "both";
        r.borderCheck = f[13] == "border" || f[13] == "both";
        if (r.name.empty()) {
            fail(lineno, "region name must not be empty");
            continue;
        }
        bool duplicate = false;
        for (const RegionSpec& other : out.regions)
            if (other.name == r.name) duplicate = true;
        if (duplicate) {
            fail(lineno, "duplicate region '" + r.name + "'");
            continue;
        }
        out.regions.push_back(r);
    }
    if (out.regions.empty() && out.errors.empty()) fail(0, "spec has no regions");
    return out;
}

inline Spec LoadSpecFrom(const std::filesystem::path& path) {
    std::ifstream in(path);
    if (!in) {
        Spec out;
        out.errors.push_back(path.string() + ":0: spec file is unreadable");
        return out;
    }
    return ParseSpec(in, path.string());
}

inline Spec LoadSpec() {
    return LoadSpecFrom(std::filesystem::path(RESOLUTE_SOURCE_ROOT) / "tests" / "visual_pair_spec.txt");
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
