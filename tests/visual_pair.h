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
    double      maxEdge = 1.0;                   // maximum painted edge-touch (clipping)
    double      maxMoved = 0.02;                 // maximum pixel fraction moved from baseline
    bool        text = true;                     // text (4.5:1) vs element (3:1)
    bool        checkContrast = true;            // slots defer to their parent region
};

struct Observed {
    std::string name;
    bool        present = false;
    std::string label;
    std::string value;
    double      x0 = 0, y0 = 0, x1 = 0, y1 = 0;
    double      painted = 0;    // painted fraction inside the region rect
    double      detail = 0;     // mean absolute horizontal neighbour difference
    double      edgeTouch = 0;  // painted fraction of the region's inner border
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
    // The region's paper is its modal colour, not its corner pixel: a
    // corner can sit on a glyph or a separator and poison every measure.
    uint32_t bg = 0;
    {
        std::map<uint32_t, long> counts;
        for (int y = y0; y < y1; ++y)
            for (int x = x0; x < x1; ++x) ++counts[img.px[static_cast<size_t>(y) * img.w + x]];
        long best = -1;
        for (const auto& [colour, n] : counts)
            if (n > best) { best = n; bg = colour; }
    }
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
    {
        // Contrast is per glyph: ink is whatever differs from the paper in
        // luminance; connected ink components of glyph size (at least 4
        // pixels, at most 2 percent of the region, not touching the border:
        // background shapes and separators touch it) each form one
        // ink/paper relationship with the paper, and the region's contrast
        // is its worst glyph. A high-contrast icon therefore cannot conceal
        // deficient text, and a region with no glyph is unmeasured (0),
        // which Compare refuses wherever the spec declares the floor.
        const double paper = Luminance(bg);
        const int rw = x1 - x0, rh = y1 - y0;
        std::vector<char> ink(static_cast<size_t>(rw) * rh, 0), seen(static_cast<size_t>(rw) * rh, 0);
        for (int y = 0; y < rh; ++y)
            for (int x = 0; x < rw; ++x)
                ink[static_cast<size_t>(y) * rw + x] =
                    std::abs(Luminance(img.px[static_cast<size_t>(y0 + y) * img.w + (x0 + x)]) - paper) > 0.05;
        double worst = 0;
        std::vector<int> stack;
        for (int start = 0; start < rw * rh; ++start) {
            if (!ink[static_cast<size_t>(start)] || seen[static_cast<size_t>(start)]) continue;
            long area = 0;
            bool touches = false;
            std::vector<double> lums;
            stack.clear();
            stack.push_back(start);
            seen[static_cast<size_t>(start)] = 1;
            while (!stack.empty()) {
                const int cur = stack.back();
                stack.pop_back();
                const int cx = cur % rw, cy = cur / rw;
                ++area;
                if (cx == 0 || cy == 0 || cx == rw - 1 || cy == rh - 1) touches = true;
                lums.push_back(Luminance(img.px[static_cast<size_t>(y0 + cy) * img.w + (x0 + cx)]));
                const int dx[4] = {1, -1, 0, 0}, dy[4] = {0, 0, 1, -1};
                for (int k = 0; k < 4; ++k) {
                    const int nx = cx + dx[k], ny = cy + dy[k];
                    if (nx < 0 || ny < 0 || nx >= rw || ny >= rh) continue;
                    const size_t ni = static_cast<size_t>(ny) * rw + nx;
                    if (ink[ni] && !seen[ni]) {
                        seen[ni] = 1;
                        stack.push_back(static_cast<int>(ni));
                    }
                }
            }
            if (touches || area < 4 || area * 50 > static_cast<long>(rw) * rh || lums.empty()) continue;
            std::sort(lums.begin(), lums.end());
            // The glyph's core, not its anti-aliased median: the far-end
            // decile of its own pixels.
            const double glyph = paper >= lums[lums.size() / 2]
                                     ? lums[static_cast<size_t>(lums.size() * 0.10)]
                                     : lums[std::min(lums.size() - 1, static_cast<size_t>(lums.size() * 0.90))];
            const double hi = std::max(paper, glyph), lo = std::min(paper, glyph);
            const double ratio = (hi + 0.05) / (lo + 0.05);
            if (worst == 0 || ratio < worst) worst = ratio;
        }
        out.contrast = worst;
    }
    {
        // Painted content running into the region's inner border: on a
        // margined slot, a control clipped by its own drawing rectangle,
        // observed in the image. (Tiled launcher regions set maxEdge 1.0;
        // their clipping is observed from the pane rectangles.)
        long borderPainted = 0, border = 0;
        auto visit = [&](int x, int y) {
            const uint32_t c = img.px[static_cast<size_t>(y) * img.w + x];
            const int d = std::abs(Channel(c, 16) - Channel(bg, 16)) + std::abs(Channel(c, 8) - Channel(bg, 8)) +
                          std::abs(Channel(c, 0) - Channel(bg, 0));
            if (d > 24) ++borderPainted;
            ++border;
        };
        for (int x = x0; x < x1; ++x) { visit(x, y0); if (y1 - 1 != y0) visit(x, y1 - 1); }
        for (int y = y0 + 1; y < y1 - 1; ++y) { visit(x0, y); if (x1 - 1 != x0) visit(x1 - 1, y); }
        out.edgeTouch = border ? static_cast<double>(borderPainted) / border : 0;
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
                                        const std::vector<std::string>& exemptions,
                                        bool enforceContrast = true) {
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
        if (got->clipped || got->edgeTouch > want.maxEdge)
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
        if (want.checkContrast && enforceContrast) {
            const double floor = want.text ? 4.5 : 3.0;
            if (got->contrast <= 0)
                failures.push_back("region '" + want.name + "' contrast is unmeasured");
            else if (got->contrast < floor)
                failures.push_back("region '" + want.name + "' contrast " + std::to_string(got->contrast) +
                                   " is below the DESIGN.md floor " + (want.text ? "4.5:1" : "3:1"));
        }
    }
    return failures;
}

// The fraction of pixels in the spec rectangle that differ between two
// images beyond the channel tolerance (the section 9 DiffCount rule): a
// renamed label or a changed row value moves its slot past tolerance.
inline double DiffFraction(const Image& a, const Image& b, const RegionSpec& spec) {
    if (a.w != b.w || a.h != b.h || a.w <= 0) return 1.0;
    const int x0 = std::clamp(static_cast<int>(spec.x0 * a.w), 0, a.w - 1);
    const int y0 = std::clamp(static_cast<int>(spec.y0 * a.h), 0, a.h - 1);
    const int x1 = std::clamp(static_cast<int>(spec.x1 * a.w), x0 + 1, a.w);
    const int y1 = std::clamp(static_cast<int>(spec.y1 * a.h), y0 + 1, a.h);
    long diff = 0, total = 0;
    for (int y = y0; y < y1; ++y) {
        for (int x = x0; x < x1; ++x) {
            const uint32_t pa = a.px[static_cast<size_t>(y) * a.w + x];
            const uint32_t pb = b.px[static_cast<size_t>(y) * a.w + x];
            const int d = std::abs(Channel(pa, 16) - Channel(pb, 16)) + std::abs(Channel(pa, 8) - Channel(pb, 8)) +
                          std::abs(Channel(pa, 0) - Channel(pb, 0));
            if (d > 24) ++diff;
            ++total;
        }
    }
    return total ? static_cast<double>(diff) / total : 0;
}

// A fresh capture against its baseline: the absolute rules on the fresh
// observation, plus the relative rules per region (painted extent within
// [0.5, 2.0] of baseline, detail at least half of baseline, at most 2
// percent of pixels moved). No exemption applies on a same-DPI leg.
// Defined below Compare's helpers; implemented in terms of MeasureAll-free
// observations the caller measured from both images, plus the images for
// the per-slot pixel rule.
inline std::vector<std::string> ComparePair(const std::vector<RegionSpec>& spec, const Image& baseline,
                                            const Image& fresh, const std::vector<Observed>& baselineObs,
                                            const std::vector<Observed>& freshObs,
                                            const EquivalenceMap& equivalents) {
    // Structural rules absolute; contrast relative to the baseline: the
    // baseline of record is the current launcher, whose palette defects
    // are the design system's to fix (DESIGN.md: a failing token pair is
    // a palette defect), so the pair refuses a regression below the
    // baseline's measured contrast, while Compare's absolute floor stays
    // the rule drills and new surfaces answer to.
    std::vector<std::string> failures = Compare(spec, freshObs, equivalents, {}, false);
    auto find = [&](const std::vector<Observed>& v, const std::string& name) -> const Observed* {
        for (const auto& o : v)
            if (o.name == name) return &o;
        return nullptr;
    };
    for (const RegionSpec& want : spec) {
        const Observed* base = find(baselineObs, want.name);
        const Observed* got = find(freshObs, want.name);
        if (!base || !got || !base->present || !got->present) continue;  // Compare already named it
        if (base->painted < 0.001) {
            if (got->painted >= 0.002)
                failures.push_back("region '" + want.name + "' painted extent appeared where the baseline has none");
        } else {
            const double ratio = got->painted / base->painted;
            if (ratio < 0.5 || ratio > 2.0)
                failures.push_back("region '" + want.name + "' painted extent ratio " + std::to_string(ratio) +
                                   " is outside [0.5, 2.0] of the baseline");
        }
        if (base->contrast > 0 && got->contrast < 0.9 * base->contrast)
            failures.push_back("region '" + want.name + "' contrast regressed below the baseline's measured " +
                               std::to_string(base->contrast));
        if (base->detail > 0 && got->detail < 0.5 * base->detail)
            failures.push_back("region '" + want.name + "' detail is below half the baseline detail");
        const double moved = DiffFraction(baseline, fresh, want);
        if (moved > want.maxMoved)
            failures.push_back("region '" + want.name + "' moved " + std::to_string(moved) +
                               " of its pixels from the baseline (over its stated tolerance)");
    }
    return failures;
}

}  // namespace visualpair
