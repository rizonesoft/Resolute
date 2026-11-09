// Port-vs-port visual comparison: the region engine. D00 T02 §12.
//
// Two implementations of one surface are compared by enumerated regions,
// never by raw pixels across implementations (todo/README.md refuses pixel
// parity: it would freeze the defects the rewrite exists to fix). Each
// region names how its label, value, presence, and painted extent are
// extracted and its own acceptance rule. A theme-only or DPI-only exemption
// may excuse a label or extent difference; it may never excuse a missing
// control, a clipped control, or a contrast below the DESIGN.md floor
// (4.5:1 text, 3:1 interactive elements and borders).
//
// This header is the focus-free half: the fenced tier extracts observed
// regions from real windows and captures and feeds them here, and the
// default suite drills the engine with synthetic observations.

#pragma once

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <map>
#include <string>
#include <vector>

namespace visualpair {

struct Image {
    int                 w = 0, h = 0;
    std::vector<uint32_t> px;  // 0xAARRGGBB, row-major
};

struct RegionSpec {
    std::string name;
    std::string label;        // expected label text ("" = not label-checked)
    std::string value;        // expected value text ("" = not value-checked)
    double      x0 = 0, y0 = 0, x1 = 1, y1 = 1;  // fractions of the window
    double      minPainted = 0.0;                // minimum painted fraction
    double      minDetail = 0.0;                 // minimum mean neighbour difference
    bool        text = true;                     // text (4.5:1) vs element (3:1)
};

struct Observed {
    std::string name;
    bool        present = false;
    std::string label;
    std::string value;
    double      x0 = 0, y0 = 0, x1 = 0, y1 = 0;
    double      painted = 0;    // painted fraction inside the region rect
    double      detail = 0;     // mean absolute horizontal neighbour difference
    double      contrast = 0;   // (L95 + .05) / (L5 + .05) inside the rect
    bool        clipped = false;
};

// The intended-redesign record: an observed label that is accepted in place
// of the spec label for the named region.
using EquivalenceMap = std::map<std::string, std::string>;

inline int Channel(uint32_t c, int shift) { return static_cast<int>((c >> shift) & 0xFFu); }

inline double Luminance(uint32_t c) {
    const double r = Channel(c, 16) / 255.0;
    const double g = Channel(c, 8) / 255.0;
    const double b = Channel(c, 0) / 255.0;
    auto lin = [](double v) { return v <= 0.03928 ? v / 12.92 : std::pow((v + 0.055) / 1.055, 2.4); };
    return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b);
}

// Painted fraction and contrast inside a fractional rect. A pixel counts as
// painted when it differs from the region's corner (background) colour.
inline void MeasureRegion(const Image& img, const RegionSpec& spec, Observed& out) {
    out.name = spec.name;
    out.x0 = spec.x0; out.y0 = spec.y0; out.x1 = spec.x1; out.y1 = spec.y1;
    if (img.w <= 0 || img.h <= 0 || img.px.empty()) { out.present = false; return; }
    const int x0 = std::clamp(static_cast<int>(spec.x0 * img.w), 0, img.w - 1);
    const int y0 = std::clamp(static_cast<int>(spec.y0 * img.h), 0, img.h - 1);
    const int x1 = std::clamp(static_cast<int>(spec.x1 * img.w), x0 + 1, img.w);
    const int y1 = std::clamp(static_cast<int>(spec.y1 * img.h), y0 + 1, img.h);
    const uint32_t bg = img.px[static_cast<size_t>(y0) * img.w + x0];
    std::vector<double> lum;
    lum.reserve(static_cast<size_t>(x1 - x0) * (y1 - y0));
    long painted = 0, total = 0;
    for (int y = y0; y < y1; ++y) {
        for (int x = x0; x < x1; ++x) {
            const uint32_t c = img.px[static_cast<size_t>(y) * img.w + x];
            ++total;
            const int dr = std::abs(Channel(c, 16) - Channel(bg, 16));
            const int dg = std::abs(Channel(c, 8) - Channel(bg, 8));
            const int db = std::abs(Channel(c, 0) - Channel(bg, 0));
            if (dr + dg + db > 24) ++painted;
            lum.push_back(Luminance(c));
        }
    }
    out.present = total > 0;
    out.painted = total ? static_cast<double>(painted) / total : 0;
    {
        double acc = 0;
        long n = 0;
        for (int y = y0; y < y1; ++y) {
            for (int x = x0 + 1; x < x1; ++x) {
                const uint32_t a = img.px[static_cast<size_t>(y) * img.w + x - 1];
                const uint32_t b = img.px[static_cast<size_t>(y) * img.w + x];
                acc += std::abs(Channel(b, 16) - Channel(a, 16)) + std::abs(Channel(b, 8) - Channel(a, 8)) +
                       std::abs(Channel(b, 0) - Channel(a, 0));
                ++n;
            }
        }
        out.detail = n ? acc / (3.0 * n) : 0;
    }
    std::sort(lum.begin(), lum.end());
    if (!lum.empty()) {
        // Text is sparse inside a region, so the floor compares the ink and
        // paper extremes (0.1 and 99.9 percentiles), not the bulk percentiles
        // a mostly-empty region would report as its own background.
        const double lo = lum[static_cast<size_t>(lum.size() * 0.001)];
        const double hi = lum[std::min(lum.size() - 1, static_cast<size_t>(lum.size() * 0.999))];
        out.contrast = (hi + 0.05) / (lo + 0.05);
    }
    // A region that ends exactly at the window edge on both axes while the
    // spec ends inside it is treated as clipped by the caller, which knows
    // the window size; here, a spec rect reaching outside [0,1] is clipped.
    out.clipped = spec.x0 < 0 || spec.y0 < 0 || spec.x1 > 1 || spec.y1 > 1;
}

// Compares the spec against one implementation's observed regions.
// `exemptions` names the active difference kinds ("theme", "dpi"); each
// failure line names the region or control that diverged.
inline std::vector<std::string> Compare(const std::vector<RegionSpec>& spec,
                                        const std::vector<Observed>& observed,
                                        const EquivalenceMap& equivalents,
                                        const std::vector<std::string>& exemptions) {
    std::vector<std::string> failures;
    const bool excused = !exemptions.empty();
    auto find = [&](const std::string& name) -> const Observed* {
        for (const auto& o : observed)
            if (o.name == name) return &o;
        return nullptr;
    };
    for (const RegionSpec& want : spec) {
        const Observed* got = find(want.name);
        if (!got || !got->present) {
            failures.push_back("region '" + want.name + "' is missing");
            continue;
        }
        if (got->clipped)
            failures.push_back("control '" + want.name + "' is clipped");
        if (!want.label.empty() && got->label != want.label) {
            auto it = equivalents.find(got->label);
            if (it == equivalents.end() || it->second != want.name)
                failures.push_back("control '" + want.name + "' label is '" + got->label + "', expected '" +
                                   want.label + "'");
        }
        if (!want.value.empty() && got->value != want.value)
            failures.push_back("region '" + want.name + "' value is '" + got->value + "', expected '" + want.value + "'");
        if (got->painted < want.minPainted) {
            if (!excused)
                failures.push_back("region '" + want.name + "' painted extent " + std::to_string(got->painted) +
                                   " is below " + std::to_string(want.minPainted));
        }
        if (want.minDetail > 0 && got->detail < want.minDetail)
            failures.push_back("region '" + want.name + "' detail " + std::to_string(got->detail) +
                               " is below " + std::to_string(want.minDetail) + " (blurred or unpainted)");
        const double floor = want.text ? 4.5 : 3.0;
        if (got->contrast > 0 && got->contrast < floor)
            failures.push_back("region '" + want.name + "' contrast " + std::to_string(got->contrast) +
                               " is below the DESIGN.md floor " + (want.text ? "4.5:1" : "3:1"));
    }
    return failures;
}

}  // namespace visualpair
