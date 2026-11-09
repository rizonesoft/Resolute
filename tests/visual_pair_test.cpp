// Port-vs-port visual comparison: engine drills and the fenced pair case.
// D00 T02 section 12. The drills are focus-free and run in the default
// suite; the pair case is [headful] and compares a fresh launcher capture
// against the composed baseline (the section 10 capture of record).

#include <catch2/catch_test_macros.hpp>
#include <algorithm>
#include <filesystem>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>

#include "visual_pair_util.h"

using visualpair::Compare;
using visualpair::EquivalenceMap;
using visualpair::Image;
using visualpair::MeasureRegion;
using visualpair::Observed;
using visualpair::RegionSpec;
using visualpair::Baseline150;
using visualpair::LoadPng;
using visualpair::LoadSpec;
using visualpair::MeasureAll;
using visualpair::Spec;

namespace {

Image Synthetic(bool dark) {
    Image img;
    img.w = 200;
    img.h = 100;
    const uint32_t bg = dark ? 0xFF101010u : 0xFFF0F0F0u;
    const uint32_t fg = dark ? 0xFFF0F0F0u : 0xFF101010u;
    img.px.assign(200 * 100, bg);
    for (int y = 10; y < 34; ++y)
        for (int x = 10; x < 94; ++x)
            if (((x / 6) + (y / 6)) % 2 == 0) img.px[static_cast<size_t>(y) * 200 + x] = fg;
    return img;
}

RegionSpec SyntheticSpec() {
    RegionSpec r;
    r.name = "tool-list";
    r.label = "Tools";
    r.x0 = 0.0;
    r.y0 = 0.0;
    r.x1 = 0.5;
    r.y1 = 0.5;
    r.minPainted = 0.05;
    r.minDetail = 0.5;
    r.text = true;
    return r;
}

bool AnyNames(const std::vector<std::string>& failures, const std::string& needle) {
    return std::any_of(failures.begin(), failures.end(),
                       [&](const std::string& f) { return f.find(needle) != std::string::npos; });
}

}  // namespace

TEST_CASE("Visual pair spec enumerates the launcher regions", "[visual-pair]") {
    const Spec spec = LoadSpec();
    CHECK(spec.errors.empty());
    CHECK(spec.regions.size() == 21);
    CHECK(AnyNames([&] {
              std::vector<std::string> names;
              for (const auto& r : spec.regions) names.push_back(r.name);
              return names;
          }(),
          "status-bar"));
    CHECK(spec.equivalents.count("Resolute") == 1);
}

TEST_CASE("A renamed label fails naming the control", "[visual-pair]") {
    const RegionSpec want = SyntheticSpec();
    Observed got;
    got.name = "tool-list";
    got.present = true;
    got.label = "Utilities";
    got.painted = 0.5;
    got.detail = 5;
    got.contrast = 10;
    const auto failures = Compare({want}, {got}, {}, {});
    CHECK(AnyNames(failures, "tool-list"));
    CHECK(AnyNames(failures, "label"));
}

TEST_CASE("A removed control fails naming the region", "[visual-pair]") {
    const RegionSpec want = SyntheticSpec();
    const auto failures = Compare({want}, {}, {}, {});
    CHECK(AnyNames(failures, "tool-list"));
    CHECK(AnyNames(failures, "missing"));
}

TEST_CASE("A clipped control fails under the theme exemption", "[visual-pair]") {
    const RegionSpec want = SyntheticSpec();
    Observed got;
    got.name = "tool-list";
    got.present = true;
    got.label = "Tools";
    got.painted = 0.5;
    got.detail = 5;
    got.contrast = 10;
    got.clipped = true;
    const auto failures = Compare({want}, {got}, {}, {"theme"});
    CHECK(AnyNames(failures, "clipped"));
}

TEST_CASE("A low-contrast region fails despite a theme exemption", "[visual-pair]") {
    const RegionSpec want = SyntheticSpec();
    Observed got;
    got.name = "tool-list";
    got.present = true;
    got.label = "Tools";
    got.painted = 0.5;
    got.detail = 5;
    got.contrast = 2.0;  // below the 4.5:1 text floor
    const auto failures = Compare({want}, {got}, {}, {"theme"});
    CHECK(AnyNames(failures, "contrast"));
}

TEST_CASE("Dark and light of the same layout pass with the theme exemption quoted", "[visual-pair]") {
    const std::vector<RegionSpec> spec{SyntheticSpec()};
    const auto light = MeasureAll(Synthetic(false), spec);
    const auto dark = MeasureAll(Synthetic(true), spec);
    const std::vector<std::string> exemptions{"theme"};
    std::string quoted;
    for (const auto& e : exemptions) quoted += (quoted.empty() ? "" : ",") + e;
    INFO("exemption quoted: " << quoted);
    CHECK(Compare(spec, light, {}, exemptions).empty());
    CHECK(Compare(spec, dark, {}, exemptions).empty());
}

TEST_CASE("The unmodified real 150 capture passes against the section 10 baseline", "[visual-pair]") {
    const Spec spec = LoadSpec();
    Image baseline;
    const auto path =
        std::filesystem::path(RESOLUTE_SOURCE_ROOT) / "docs" / "captures" / "runs" / "2026-11-09-D00-T02-s10-launcher-light-150.png";
    REQUIRE(LoadPng(path, baseline));
    const auto observed = MeasureAll(baseline, spec.regions);
    const auto failures = visualpair::ComparePair(spec.regions, baseline, baseline, observed, observed, spec.equivalents);
    INFO("failures: " << failures.size());
    for (const auto& f : failures) std::printf("visual-pair failure: %s\n", f.c_str());
    CHECK(failures.empty());
}

TEST_CASE("A blurred copy of the 150 capture fails", "[visual-pair]") {
    const Spec spec = LoadSpec();
    Image img;
    const auto path =
        std::filesystem::path(RESOLUTE_SOURCE_ROOT) / "docs" / "captures" / "runs" / "2026-11-09-D00-T02-s10-launcher-light-150.png";
    REQUIRE(LoadPng(path, img));
    // Box blur, radius 2, two passes: edges smear, detail collapses.
    Image blurred = img;
    for (int pass = 0; pass < 2; ++pass) {
        const Image srcPass = blurred;
    for (int y = 2; y < img.h - 2; ++y) {
        for (int x = 2; x < img.w - 2; ++x) {
            int r = 0, g = 0, b = 0;
            for (int dy = -2; dy <= 2; ++dy)
                for (int dx = -2; dx <= 2; ++dx) {
                    const uint32_t c = srcPass.px[static_cast<size_t>(y + dy) * img.w + (x + dx)];
                    r += static_cast<int>((c >> 16) & 0xFF);
                    g += static_cast<int>((c >> 8) & 0xFF);
                    b += static_cast<int>(c & 0xFF);
                }
            blurred.px[static_cast<size_t>(y) * img.w + x] =
                0xFF000000u | (static_cast<uint32_t>(r / 25) << 16) | (static_cast<uint32_t>(g / 25) << 8) |
                static_cast<uint32_t>(b / 25);
        }
    }
    }
    const auto failures = Compare(spec.regions, MeasureAll(blurred, spec.regions), spec.equivalents, {});
    CHECK(!failures.empty());
}

TEST_CASE("Malformed region specifications fail with file and line", "[visual-pair]") {
    auto parse = [](const std::string& text) {
        std::stringstream ss(text);
        return visualpair::ParseSpec(ss, "drill.txt");
    };
    CHECK(!parse("equiv|only-two\n").errors.empty());
    CHECK(!parse("region|a|||0|0|1|1|0|0|text\n").errors.empty());
    CHECK(!parse("region|a|||0|0|1|1|0|0|text|1|0.02|check|extra\n").errors.empty());
    CHECK(!parse("region|a|||x|0|1|1|0|0|text|1|0.02|check\n").errors.empty());
    CHECK(!parse("region|a|||0.5|0|0.4|1|0|0|text|1|0.02|check\n").errors.empty());
    CHECK(!parse("region|a|||0|0|1|1|0|0|gadget|1|0.02|check\n").errors.empty());
    CHECK(!parse("region|a|||0|0|1|1|0|0|text|1|0.02|check\nregion|a|||0|0|1|1|0|0|text|1|0.02|check\n").errors.empty());
    CHECK(!parse("region|a|||0|0|1|1|-1|0|text|1|0.02|check\n").errors.empty());
    CHECK(!parse("region|a|||0|0|1|1|0|0|text|nan|nan|check\n").errors.empty());
    CHECK(!parse("region|a|||0|0|1|1|0|0|text|1|0.02junk|check\n").errors.empty());
    const auto missing = visualpair::LoadSpecFrom("no-such-spec-file.txt");
    REQUIRE(!missing.errors.empty());
    CHECK(missing.errors[0].find("unreadable") != std::string::npos);
    const auto good = parse("region|a|||0|0|1|1|0|0|text|1|0.02|check\n");
    CHECK(good.errors.empty());
    CHECK(good.regions.size() == 1);
}

TEST_CASE("A control painted to its slot edge fails as clipped through measurement", "[visual-pair]") {
    Image img;
    img.w = 200;
    img.h = 100;
    img.px.assign(200 * 100, 0xFFF0F0F0u);
    RegionSpec slot;
    slot.name = "toolbar-slot-1";
    slot.x0 = 0.0;
    slot.y0 = 0.0;
    slot.x1 = 0.5;
    slot.y1 = 0.5;
    slot.maxEdge = 0.05;
    slot.checkContrast = false;
    // A glyph running into the slot's right inner edge, as a clipped label does.
    for (int y = 10; y < 40; ++y)
        for (int x = 90; x < 100; ++x) img.px[static_cast<size_t>(y) * 200 + x] = 0xFF101010u;
    Observed got;
    MeasureRegion(img, slot, got);
    CHECK(got.edgeTouch > slot.maxEdge);
    const auto failures = Compare({slot}, {got}, {}, {"theme"});
    CHECK(AnyNames(failures, "clipped"));
}

TEST_CASE("Low-contrast text beside a high-contrast icon fails by block", "[visual-pair]") {
    Image img;
    img.w = 240;
    img.h = 60;
    img.px.assign(240 * 60, 0xFFFFFFFFu);
    // High-contrast icon on the left.
    for (int y = 10; y < 50; ++y)
        for (int x = 10; x < 50; ++x) img.px[static_cast<size_t>(y) * 240 + x] = 0xFF000000u;
    // Low-contrast text strokes on the right: light grey on white.
    for (int y = 20; y < 40; ++y)
        for (int x = 150; x < 154; ++x) img.px[static_cast<size_t>(y) * 240 + x] = 0xFFD8D8D8u;
    RegionSpec region;
    region.name = "sidebar";
    region.x0 = 0.0;
    region.y0 = 0.0;
    region.x1 = 1.0;
    region.y1 = 1.0;
    region.text = true;
    Observed got;
    MeasureRegion(img, region, got);
    const auto failures = Compare({region}, {got}, {}, {"theme"});
    CHECK(AnyNames(failures, "contrast"));
}

TEST_CASE("An unmeasured contrast fails instead of passing", "[visual-pair]") {
    Image img;
    img.w = 100;
    img.h = 100;
    img.px.assign(100 * 100, 0xFF808080u);
    RegionSpec region;
    region.name = "sidebar";
    region.x0 = 0.0;
    region.y0 = 0.0;
    region.x1 = 1.0;
    region.y1 = 1.0;
    Observed got;
    MeasureRegion(img, region, got);
    CHECK(got.contrast == 0);
    const auto failures = Compare({region}, {got}, {}, {});
    CHECK(AnyNames(failures, "unmeasured"));
}

TEST_CASE("The dark 150 baseline passes with the theme exemption quoted", "[visual-pair]") {
    const Spec spec = LoadSpec();
    Image dark;
    const auto path = std::filesystem::path(RESOLUTE_SOURCE_ROOT) / "docs" / "captures" / "runs" /
                      "2026-11-09-D00-T02-s10-launcher-dark-150.png";
    REQUIRE(LoadPng(path, dark));
    const std::vector<std::string> exemptions{"theme"};
    INFO("exemption quoted: theme");
    const auto darkObserved = MeasureAll(dark, spec.regions);
    const auto failures = visualpair::ComparePair(spec.regions, dark, dark, darkObserved, darkObserved, spec.equivalents);
    for (const auto& f : failures) std::printf("visual-pair failure: %s\n", f.c_str());
    CHECK(failures.empty());
}

namespace {

// Erases the first glyph component inside `region` (flood-filled and
// painted over with the region's paper): a one-letter label edit.
void EraseFirstGlyph(Image& img, const RegionSpec& region) {
    const int x0 = static_cast<int>(region.x0 * img.w), x1 = static_cast<int>(region.x1 * img.w);
    const int y0 = static_cast<int>(region.y0 * img.h), y1 = static_cast<int>(region.y1 * img.h);
    std::map<uint32_t, long> counts;
    for (int y = y0; y < y1; ++y)
        for (int x = x0; x < x1; ++x) ++counts[img.px[static_cast<size_t>(y) * img.w + x]];
    uint32_t paper = 0;
    long best = -1;
    for (const auto& [colour, n] : counts)
        if (n > best) { best = n; paper = colour; }
    const double paperLum = visualpair::Luminance(paper);
    for (int y = y0; y < y1; ++y) {
        for (int x = x0; x < x1; ++x) {
            if (std::abs(visualpair::Luminance(img.px[static_cast<size_t>(y) * img.w + x]) - paperLum) <= 0.05) continue;
            // Flood this component and paint its bounding box with paper.
            std::vector<std::pair<int, int>> stack{{x, y}}, cells;
            img.px[static_cast<size_t>(y) * img.w + x] = paper;
            cells.emplace_back(x, y);
            int minX = x, maxX = x, minY = y, maxY = y;
            while (!stack.empty()) {
                auto [cx, cy] = stack.back();
                stack.pop_back();
                minX = std::min(minX, cx);
                maxX = std::max(maxX, cx);
                minY = std::min(minY, cy);
                maxY = std::max(maxY, cy);
                const int dx[4] = {1, -1, 0, 0}, dy[4] = {0, 0, 1, -1};
                for (int k = 0; k < 4; ++k) {
                    const int nx = cx + dx[k], ny = cy + dy[k];
                    if (nx < x0 || ny < y0 || nx >= x1 || ny >= y1) continue;
                    uint32_t& c = img.px[static_cast<size_t>(ny) * img.w + nx];
                    if (std::abs(visualpair::Luminance(c) - paperLum) <= 0.05) continue;
                    c = paper;
                    cells.emplace_back(nx, ny);
                    stack.emplace_back(nx, ny);
                }
            }
            // A hairline (a column divider) is not the glyph: keep looking.
            if (cells.size() >= 4 && maxX - minX >= 2 && maxY - minY >= 2) {
                for (int yy = minY; yy <= maxY; ++yy)
                    for (int xx = minX; xx <= maxX; ++xx) img.px[static_cast<size_t>(yy) * img.w + xx] = paper;
                return;
            }
        }
    }
}

const RegionSpec& ByName(const Spec& spec, const char* name) {
    for (const RegionSpec& r : spec.regions)
        if (r.name == name) return r;
    return spec.regions[0];
}

}  // namespace

TEST_CASE("Erasing one glyph of a real label fails naming the control", "[visual-pair]") {
    const Spec spec = LoadSpec();
    Image baseline;
    REQUIRE(LoadPng(Baseline150(), baseline));
    Image changed = baseline;
    EraseFirstGlyph(changed, ByName(spec, "sidebar-system"));
    const auto failures = visualpair::ComparePair(spec.regions, baseline, changed, MeasureAll(baseline, spec.regions),
                                                  MeasureAll(changed, spec.regions), spec.equivalents);
    CHECK(AnyNames(failures, "sidebar-system"));
}

TEST_CASE("Repainting one glyph of a real header fails naming the control", "[visual-pair]") {
    const Spec spec = LoadSpec();
    Image baseline;
    REQUIRE(LoadPng(Baseline150(), baseline));
    Image changed = baseline;
    EraseFirstGlyph(changed, ByName(spec, "list-header-name"));
    const auto failures = visualpair::ComparePair(spec.regions, baseline, changed, MeasureAll(baseline, spec.regions),
                                                  MeasureAll(changed, spec.regions), spec.equivalents);
    for (const auto& f : failures) std::printf("glyph drill failure: %s\n", f.c_str());
    CHECK(AnyNames(failures, "list-header-name"));
}

TEST_CASE("Extending a real label to its control edge fails as clipped naming the control", "[visual-pair]") {
    const Spec spec = LoadSpec();
    Image baseline;
    REQUIRE(LoadPng(Baseline150(), baseline));
    Image changed = baseline;
    const RegionSpec& control = ByName(spec, "sidebar-system");
    const int x0 = static_cast<int>(control.x0 * changed.w), x1 = static_cast<int>(control.x1 * changed.w);
    const int y0 = static_cast<int>(control.y0 * changed.h), y1 = static_cast<int>(control.y1 * changed.h);
    // Label text running into the control's right edge, as truncation paints it.
    for (int y = y0 + 4; y < y1 - 4; ++y)
        for (int x = x1 - 6; x < x1; ++x) changed.px[static_cast<size_t>(y) * changed.w + x] = 0xFF101010u;
    (void)x0;
    const auto failures = Compare({control}, MeasureAll(changed, {control}), spec.equivalents, {"theme"});
    CHECK(AnyNames(failures, "clipped"));
    CHECK(AnyNames(failures, "sidebar-system"));
}

TEST_CASE("The baseline compared with itself passes the pair comparison", "[visual-pair]") {
    const Spec spec = LoadSpec();
    Image baseline;
    REQUIRE(LoadPng(Baseline150(), baseline));
    const auto observed = MeasureAll(baseline, spec.regions);
    const auto failures =
        visualpair::ComparePair(spec.regions, baseline, baseline, observed, observed, spec.equivalents);
    for (const auto& f : failures) std::printf("visual-pair failure: %s\n", f.c_str());
    CHECK(failures.empty());
}

TEST_CASE("View text between the element and text floors fails naming the floor", "[visual-pair]") {
    auto render = [](bool dark) {
        Image img;
        img.w = 160;
        img.h = 60;
        const uint32_t paper = dark ? 0xFF282828u : 0xFFFFFFFFu;
        const uint32_t ink = dark ? 0xFF848484u : 0xFF828282u;  // between 3:1 and 4.5:1 on its paper
        img.px.assign(160 * 60, paper);
        for (int y = 20; y < 36; ++y)
            for (int x = 20; x < 60; ++x)
                if ((x % 12) < 7) img.px[static_cast<size_t>(y) * 160 + x] = ink;
        return img;
    };
    RegionSpec view;
    view.name = "toolbar-view";
    view.label = "View";
    view.x0 = 0.0;
    view.y0 = 0.0;
    view.x1 = 1.0;
    view.y1 = 1.0;
    view.text = true;
    view.checkContrast = true;
    for (bool dark : {false, true}) {
        Observed got;
        MeasureRegion(render(dark), view, got);
        INFO("measured contrast must sit between the floors, got " << got.contrast);
        CHECK(got.contrast > 3.0);
        CHECK(got.contrast < 4.5);
        const auto failures = Compare({view}, {got}, {}, {"theme"});
        CHECK(AnyNames(failures, "toolbar-view"));
        CHECK(AnyNames(failures, "4.5:1"));
    }
}

TEST_CASE("Truncating the selected All label fails as clipped naming the control", "[visual-pair]") {
    const Spec spec = LoadSpec();
    Image baseline;
    REQUIRE(LoadPng(Baseline150(), baseline));
    Image changed = baseline;
    const RegionSpec& control = ByName(spec, "sidebar-all");
    const int x1 = static_cast<int>(control.x1 * changed.w);
    const int y0 = static_cast<int>(control.y0 * changed.h), y1 = static_cast<int>(control.y1 * changed.h);
    for (int y = y0 + 4; y < y1 - 4; ++y)
        for (int x = x1 - 6; x < x1; ++x) changed.px[static_cast<size_t>(y) * changed.w + x] = 0xFF101010u;
    const auto observed = MeasureAll(changed, {control});
    CHECK(observed[0].edgeTouch > control.maxEdge);
    const auto failures = Compare({control}, observed, spec.equivalents, {"theme"});
    CHECK(AnyNames(failures, "clipped"));
    CHECK(AnyNames(failures, "sidebar-all"));
}

TEST_CASE("Truncating the Name header fails as clipped naming the control", "[visual-pair]") {
    const Spec spec = LoadSpec();
    Image baseline;
    REQUIRE(LoadPng(Baseline150(), baseline));
    Image changed = baseline;
    const RegionSpec& control = ByName(spec, "list-header-name");
    const int x1 = static_cast<int>(control.x1 * changed.w);
    const int y0 = static_cast<int>(control.y0 * changed.h), y1 = static_cast<int>(control.y1 * changed.h);
    for (int y = y0 + 4; y < y1 - 4; ++y)
        for (int x = x1 - 6; x < x1; ++x) changed.px[static_cast<size_t>(y) * changed.w + x] = 0xFF101010u;
    const auto observed = MeasureAll(changed, {control});
    CHECK(observed[0].edgeTouch > control.maxEdge);
    const auto failures = Compare({control}, observed, spec.equivalents, {"theme"});
    CHECK(AnyNames(failures, "clipped"));
    CHECK(AnyNames(failures, "list-header-name"));
}

namespace {

// Renders the control's own label truncated at its right boundary: the
// label's last glyph is cut there, its left half painted at the boundary
// and the rest beyond it, as clipped text renders.
void TruncateLabelAtEdge(Image& img, const RegionSpec& region) {
    const int x0 = static_cast<int>(region.x0 * img.w), x1 = static_cast<int>(region.x1 * img.w);
    const int y0 = static_cast<int>(region.y0 * img.h), y1 = static_cast<int>(region.y1 * img.h);
    std::map<uint32_t, long> counts;
    for (int y = y0; y < y1; ++y)
        for (int x = x0; x < x1; ++x) ++counts[img.px[static_cast<size_t>(y) * img.w + x]];
    uint32_t paper = 0;
    long best = -1;
    for (const auto& [colour, n] : counts)
        if (n > best) { best = n; paper = colour; }
    const double paperLum = visualpair::Luminance(paper);
    const int labelZone = x0 + (x1 - x0) / 2;
    // Find the label's last glyph component (rightmost in the label zone).
    std::vector<std::pair<int, int>> glyph;
    int glyphMinX = 0, glyphMaxX = -1, glyphMinY = 0;
    std::vector<char> seen(static_cast<size_t>(x1 - x0) * (y1 - y0), 0);
    for (int y = y0; y < y1; ++y) {
        for (int x = x0; x < labelZone; ++x) {
            const size_t idx = static_cast<size_t>(y - y0) * (x1 - x0) + (x - x0);
            if (seen[idx]) continue;
            if (std::abs(visualpair::Luminance(img.px[static_cast<size_t>(y) * img.w + x]) - paperLum) <= 0.05) continue;
            std::vector<std::pair<int, int>> stack{{x, y}}, cells;
            seen[idx] = 1;
            int minX = x, maxX = x, minY = y, maxY = y;
            while (!stack.empty()) {
                auto [cx, cy] = stack.back();
                stack.pop_back();
                cells.emplace_back(cx, cy);
                minX = std::min(minX, cx);
                maxX = std::max(maxX, cx);
                minY = std::min(minY, cy);
                maxY = std::max(maxY, cy);
                const int dx[4] = {1, -1, 0, 0}, dy[4] = {0, 0, 1, -1};
                for (int k = 0; k < 4; ++k) {
                    const int nx = cx + dx[k], ny = cy + dy[k];
                    if (nx < x0 || ny < y0 || nx >= labelZone || ny >= y1) continue;
                    const size_t ni = static_cast<size_t>(ny - y0) * (x1 - x0) + (nx - x0);
                    if (seen[ni]) continue;
                    if (std::abs(visualpair::Luminance(img.px[static_cast<size_t>(ny) * img.w + nx]) - paperLum) <= 0.05)
                        continue;
                    seen[ni] = 1;
                    stack.emplace_back(nx, ny);
                }
            }
            // A glyph, not the selected fill or a badge: bounded in both
            // dimensions and in area.
            if (cells.size() >= 4 && cells.size() <= 400 && maxX - minX <= 30 && maxY - minY <= 30 &&
                maxX > glyphMaxX) {
                glyph = cells;
                glyphMinX = minX;
                glyphMaxX = maxX;
                glyphMinY = minY;
            }
        }
    }
    if (glyph.empty()) return;
    // Save the glyph's colours, erase it, and repaint its left half cut at
    // the boundary.
    std::vector<uint32_t> colours;
    for (auto [x, y] : glyph) colours.push_back(img.px[static_cast<size_t>(y) * img.w + x]);
    for (auto [x, y] : glyph) img.px[static_cast<size_t>(y) * img.w + x] = paper;
    const int targetLeft = x1 - 4;
    for (size_t i = 0; i < glyph.size(); ++i) {
        const int nx = targetLeft + (glyph[i].first - glyphMinX);
        if (nx >= x0 && nx < x1) img.px[static_cast<size_t>(glyph[i].second) * img.w + nx] = colours[i];
    }
    (void)glyphMinY;
}

void CheckTruncated(const Spec& spec, Image baseline, const char* name) {
    const RegionSpec& control = ByName(spec, name);
    TruncateLabelAtEdge(baseline, control);
    const auto observed = MeasureAll(baseline, {control});
    std::printf("truncate %s edge %.3f max %.2f\n", name, observed[0].edgeTouch, control.maxEdge);
    CHECK(observed[0].edgeTouch > control.maxEdge);
    const auto failures = Compare({control}, observed, spec.equivalents, {"theme"});
    CHECK(AnyNames(failures, "clipped"));
    CHECK(AnyNames(failures, name));
}

}  // namespace

TEST_CASE("Partial-glyph truncation fails as clipped naming each control", "[visual-pair]") {
    const Spec spec = LoadSpec();
    Image light, dark;
    REQUIRE(LoadPng(Baseline150(), light));
    REQUIRE(LoadPng(std::filesystem::path(RESOLUTE_SOURCE_ROOT) / "docs" / "captures" / "runs" /
                        "2026-11-09-D00-T02-s10-launcher-dark-150.png",
                    dark));
    for (const Image& baseline : {light, dark}) {
        CheckTruncated(spec, baseline, "sidebar-all");
        CheckTruncated(spec, baseline, "list-header-name");
        CheckTruncated(spec, baseline, "list-header-description");
        CheckTruncated(spec, baseline, "list-header-version");
    }
}

TEST_CASE("The shipped spec keeps the enforcement configuration", "[visual-pair]") {
    const Spec spec = LoadSpec();
    REQUIRE(spec.errors.empty());
    const RegionSpec& view = ByName(spec, "toolbar-view");
    CHECK(view.text);
    CHECK(view.checkContrast);
    for (const char* name : {"sidebar-all", "list-header-name", "list-header-description", "list-header-version"})
        CHECK(ByName(spec, name).maxEdge < 1.0);
    for (const RegionSpec& r : spec.regions)
        if (r.name == "toolbar" || r.name == "sidebar" || r.name == "tool-list" || r.name == "status-bar")
            CHECK(r.checkContrast);
}
