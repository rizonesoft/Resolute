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
#include <filesystem>
#include <fstream>
#include <map>
#include <regex>
#include <set>
#include <sstream>
#include <string>
#include <vector>

namespace {

struct ManifestEntry {
    std::string              name;
    std::vector<std::string> referrers;
    bool                     icon = true;  // false: a declared non-icon literal
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
        e.icon = fields[0][0] != '!';
        e.name = e.icon ? fields[0] : fields[0].substr(1);
        e.referrers.assign(fields.begin() + 1, fields.end());
        entries.push_back(std::move(e));
    }
    return entries;
}

// The whole file `path` names, from the source root; empty when unreadable.
std::string ReferrerText(const std::string& path) {
    std::ifstream in(std::string(RESOLUTE_SOURCE_ROOT) + "/" + path, std::ios::binary);
    std::ostringstream text;
    text << in.rdbuf();
    return text.str();
}

}  // namespace

TEST_CASE("Every referenced icon name resolves to SVG and to a bitmap", "[ui][icons]") {
    REQUIRE(rui::LucideIcons::Load());
    const auto entries = ReadManifest();
    CAPTURE(RESOLUTE_ICON_MANIFEST);
    REQUIRE(entries.size() >= 20);

    for (const auto& e : entries) {
        if (!e.icon) continue;
        const std::string& name = e.name;
        CAPTURE(name);
        REQUIRE_FALSE(e.referrers.empty());

        const char* svg = rui::LucideIcons::GetSvgData(name.c_str());
        CHECK(svg != nullptr);
        if (svg) CHECK(std::strncmp(svg, "<svg", 4) == 0);

        HBITMAP bmp = rui::LucideIcons::CreateBitmap(name.c_str(), 16, 0xFFFFFFu);
        CHECK(bmp != nullptr);
        if (bmp) DeleteObject(bmp);

        // Each listed file still quotes the name, so a reference that left
        // its file cannot leave a stale entry behind.
        const std::string quoted = "\"" + name + "\"";
        for (const auto& referrer : e.referrers) {
            if (referrer == "dead") continue;
            CAPTURE(referrer);
            CHECK(ReferrerText(referrer).find(quoted) != std::string::npos);
        }
    }
}

TEST_CASE("Every icon-shaped literal in the sources is in the manifest", "[ui][icons]") {
    // The other direction (panel round 1 of the D00 T02 §8 review): every
    // quoted kebab-case literal in the scoped sources is listed for its file,
    // either as an icon referrer or as a declared non-icon, so a new or
    // misspelled icon reference fails here by name.
    std::map<std::string, std::set<std::string>> listed;  // literal -> files
    for (const auto& e : ReadManifest())
        for (const auto& r : e.referrers) listed[e.name].insert(r);

    namespace fs = std::filesystem;
    const fs::path root = RESOLUTE_SOURCE_ROOT;
    std::vector<fs::path> dirs = {root / "shared/resolute-ui/include", root / "shared/resolute-ui/src", root / "src"};
    for (const auto& ext : fs::directory_iterator(root / "extensions"))
        if (fs::is_directory(ext.path() / "src")) dirs.push_back(ext.path() / "src");

    const std::regex literal(R"re("([a-z][a-z0-9]*(?:-[a-z0-9]+)*)")re");
    int scanned = 0;
    for (const auto& dir : dirs) {
        for (const auto& f : fs::recursive_directory_iterator(dir)) {
            const auto ext = f.path().extension().string();
            if (!f.is_regular_file() || (ext != ".h" && ext != ".hpp" && ext != ".cpp")) continue;
            const std::string rel = fs::relative(f.path(), root).generic_string();
            std::ifstream in(f.path());
            std::string line;
            for (int n = 1; std::getline(in, line); ++n) {
                for (std::sregex_iterator it(line.begin(), line.end(), literal), end; it != end; ++it) {
                    ++scanned;
                    const std::string lit = (*it)[1];
                    const std::string at  = rel + ":" + std::to_string(n);
                    CAPTURE(lit, at);
                    CHECK(listed[lit].count(rel) == 1);
                }
            }
        }
    }
    CHECK(scanned >= 40);
}
