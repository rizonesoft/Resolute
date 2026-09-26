// Icon manifest audit. D00 T02 §8.
//
// An unknown icon name resolves to null, which draws a control silently
// missing its glyph. tests/icon_manifest.txt lists every name the code
// references with its referrers; this case asserts each name resolves to SVG
// and to a bitmap, and that each referrer line still quotes it, so a typo, an
// icon removed from the set, or a moved reference fails by name.

#include <catch2/catch_test_macros.hpp>

#include <resolute/icons.h>

#include <windows.h>

#include <cstring>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>

namespace {

struct ManifestEntry {
    std::string              name;
    std::vector<std::string> referrers;
};

std::vector<std::string> SplitTabs(const std::string& line) {
    std::vector<std::string> out;
    std::string field;
    std::istringstream in(line);
    while (std::getline(in, field, '\t'))
        if (!field.empty()) out.push_back(field);
    return out;
}

std::vector<ManifestEntry> ReadManifest() {
    std::vector<ManifestEntry> entries;
    std::ifstream in(RESOLUTE_ICON_MANIFEST);
    std::string line;
    while (std::getline(in, line)) {
        if (!line.empty() && line.back() == '\r') line.pop_back();
        if (line.empty() || line[0] == '#') continue;
        auto fields = SplitTabs(line);
        if (fields.empty()) continue;
        ManifestEntry e;
        e.name = fields[0];
        e.referrers.assign(fields.begin() + 1, fields.end());
        entries.push_back(std::move(e));
    }
    return entries;
}

// The line `path:line` names, from the source root; empty when unreadable.
std::string ReferrerLine(const std::string& referrer) {
    const auto colon = referrer.rfind(':');
    if (colon == std::string::npos) return {};
    const std::string path = std::string(RESOLUTE_SOURCE_ROOT) + "/" + referrer.substr(0, colon);
    const int wanted       = std::stoi(referrer.substr(colon + 1));
    std::ifstream in(path);
    std::string line;
    for (int n = 1; std::getline(in, line); ++n)
        if (n == wanted) return line;
    return {};
}

}  // namespace

TEST_CASE("Every referenced icon name resolves to SVG and to a bitmap", "[ui][icons]") {
    REQUIRE(rui::LucideIcons::Load());
    const auto entries = ReadManifest();
    CAPTURE(RESOLUTE_ICON_MANIFEST);
    REQUIRE(entries.size() >= 20);

    for (const auto& e : entries) {
        const std::string& name = e.name;
        CAPTURE(name);
        REQUIRE_FALSE(e.referrers.empty());

        const char* svg = rui::LucideIcons::GetSvgData(name.c_str());
        CHECK(svg != nullptr);
        if (svg) CHECK(std::strncmp(svg, "<svg", 4) == 0);

        HBITMAP bmp = rui::LucideIcons::CreateBitmap(name.c_str(), 16, 0xFFFFFFu);
        CHECK(bmp != nullptr);
        if (bmp) DeleteObject(bmp);

        // Each referrer still quotes the name where the manifest says, so a
        // reference that moved or changed cannot leave a stale entry behind.
        const std::string quoted = "\"" + name + "\"";
        for (const auto& referrer : e.referrers) {
            if (referrer == "dead") continue;
            CAPTURE(referrer);
            CHECK(ReferrerLine(referrer).find(quoted) != std::string::npos);
        }
    }
}
