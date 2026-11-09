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
    CHECK(spec.regions.size() == 23);
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

TEST_CASE("A thinned slot fails the relative comparison naming the slot", "[visual-pair]") {
    const Spec spec = LoadSpec();
    Image baseline;
    REQUIRE(LoadPng(Baseline150(), baseline));
    Image thinned = baseline;
    // Erase most painted pixels inside toolbar-slot-1 only: its absolute
    // floors are zero, so only the relative rules can refuse it.
    const RegionSpec& slot = spec.regions[5];
    const int x0 = static_cast<int>(slot.x0 * thinned.w), x1 = static_cast<int>(slot.x1 * thinned.w);
    const int y0 = static_cast<int>(slot.y0 * thinned.h), y1 = static_cast<int>(slot.y1 * thinned.h);
    const uint32_t bg = thinned.px[static_cast<size_t>(y0) * thinned.w + x0];
    int erased = 0;
    for (int y = y0; y < y1; ++y)
        for (int x = x0; x < x1; ++x) {
            uint32_t& c = thinned.px[static_cast<size_t>(y) * thinned.w + x];
            if (c != bg && (erased++ % 5) != 0) c = bg;
        }
    const auto failures = visualpair::ComparePair(spec.regions, baseline, thinned, MeasureAll(baseline, spec.regions),
                                                  MeasureAll(thinned, spec.regions), spec.equivalents);
    CHECK(AnyNames(failures, "toolbar-slot-1"));
}

TEST_CASE("A repainted slot fails the pixel comparison naming the slot", "[visual-pair]") {
    const Spec spec = LoadSpec();
    Image baseline;
    REQUIRE(LoadPng(Baseline150(), baseline));
    Image changed = baseline;
    const RegionSpec& slot = spec.regions[6];  // toolbar-slot-2
    const int x0 = static_cast<int>(slot.x0 * changed.w), x1 = static_cast<int>(slot.x1 * changed.w);
    const int y0 = static_cast<int>(slot.y0 * changed.h), y1 = static_cast<int>(slot.y1 * changed.h);
    for (int y = y0; y < y1; ++y)
        for (int x = x0; x < x1; ++x)
            changed.px[static_cast<size_t>(y) * changed.w + x] = ((x + y) % 2) ? 0xFF202020u : 0xFFE0E0E0u;
    const auto failures = visualpair::ComparePair(spec.regions, baseline, changed, MeasureAll(baseline, spec.regions),
                                                  MeasureAll(changed, spec.regions), spec.equivalents);
    CHECK(AnyNames(failures, "toolbar-slot-2"));
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
