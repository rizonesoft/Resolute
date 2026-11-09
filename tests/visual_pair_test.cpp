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
    for (int y = 10; y < 30; ++y)
        for (int x = 10; x < 90; ++x)
            if ((x + y) % 3 == 0) img.px[static_cast<size_t>(y) * 200 + x] = fg;
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
    CHECK(spec.regions.size() == 5);
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
    const auto failures = Compare(spec.regions, observed, spec.equivalents, {});
    INFO("failures: " << failures.size());
    for (const auto& f : failures) INFO(f);
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
