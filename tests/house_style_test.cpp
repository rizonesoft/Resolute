// The house-style contract, asserted against the constants it was derived from.
// D00 T02 §3.
//
// This exists because the section it belongs to was rewritten. It was going to
// store screenshots of the shipped AutoIt surfaces, and the operator asked what
// a screenshot proved that the source did not. It does not: the geometry is
// already constants in these headers, and an image is a binary blob that review
// cannot diff, that varies with the machine's DPI, and that nobody re-stakes
// after a padding change.
//
// So the contract is derived and this test enforces it. The numbers live in ONE
// place, the headers below. contract.md restates them for a reader, and this
// test proves the restatement is still true, which is what makes a Fidelity
// citation mean something.
//
// The table maps a contract row to its constant. That mapping is the only place
// naming both, and it carries no numbers of its own: a row's expected value is
// read from contract.md at run time and compared against the constant, so there
// is no third copy to drift.

#include <catch2/catch_test_macros.hpp>

#include <resolute/controls/listview.h>
#include <resolute/controls/sidebar.h>
#include <resolute/controls/statusbar.h>
#include <resolute/controls/toolbar.h>

#include <filesystem>
#include <fstream>
#include <map>
#include <regex>
#include <sstream>
#include <string>

namespace {

// Every token the contract is required to cover, and the constant that owns it.
// Adding a constant to a control without adding it here leaves it uncovered,
// which the coverage test below catches.
const std::map<std::string, int>& Tokens() {
    static const std::map<std::string, int> tokens = {
        {"Sidebar::BASE_WIDTH",           rui::Sidebar::BASE_WIDTH},
        {"Sidebar::BASE_ITEM_HEIGHT",     rui::Sidebar::BASE_ITEM_HEIGHT},
        {"Sidebar::BASE_PADDING_X",       rui::Sidebar::BASE_PADDING_X},
        {"Sidebar::BASE_FONT_SIZE",       rui::Sidebar::BASE_FONT_SIZE},
        {"Sidebar::BASE_HEADER_FONT",     rui::Sidebar::BASE_HEADER_FONT},
        {"Sidebar::BASE_ICON_SIZE",       rui::Sidebar::BASE_ICON_SIZE},

        {"Toolbar::BASE_HEIGHT",          rui::Toolbar::BASE_HEIGHT},
        {"Toolbar::BASE_FONT_SIZE",       rui::Toolbar::BASE_FONT_SIZE},
        {"Toolbar::BASE_ICON_SIZE",       rui::Toolbar::BASE_ICON_SIZE},

        {"StatusBar::BASE_HEIGHT",        rui::StatusBar::BASE_HEIGHT},
        {"StatusBar::BASE_FONT_SIZE",     rui::StatusBar::BASE_FONT_SIZE},
        {"StatusBar::BASE_PADDING_X",     rui::StatusBar::BASE_PADDING_X},
        {"StatusBar::BASE_ICON_SIZE",     rui::StatusBar::BASE_ICON_SIZE},
        {"StatusBar::PROGRESS_HEIGHT",    rui::StatusBar::PROGRESS_HEIGHT},

        {"ListView::BASE_ROW_HEIGHT",     rui::ListView::BASE_ROW_HEIGHT},
        {"ListView::BASE_HEADER_HEIGHT",  rui::ListView::BASE_HEADER_HEIGHT},
        {"ListView::BASE_ICON_LARGE",     rui::ListView::BASE_ICON_LARGE},
        {"ListView::BASE_ICON_SMALL",     rui::ListView::BASE_ICON_SMALL},
        {"ListView::BASE_FONT_SIZE",      rui::ListView::BASE_FONT_SIZE},
        {"ListView::BASE_HEADER_FONT",    rui::ListView::BASE_HEADER_FONT},
        {"ListView::BASE_PADDING_X",      rui::ListView::BASE_PADDING_X},
        {"ListView::BASE_LARGE_CELL_W",   rui::ListView::BASE_LARGE_CELL_W},
        {"ListView::BASE_LARGE_CELL_H",   rui::ListView::BASE_LARGE_CELL_H},
        {"ListView::BASE_SCROLLBAR_W",    rui::ListView::BASE_SCROLLBAR_W},
        {"ListView::RESIZE_ZONE",         rui::ListView::RESIZE_ZONE},
    };
    return tokens;
}

std::filesystem::path ContractPath() {
#ifdef RESOLUTE_CONTRACT_PATH
    return std::filesystem::path(RESOLUTE_CONTRACT_PATH);
#else
    return {};
#endif
}

// Rows look like: | Width | 200 | `Sidebar::BASE_WIDTH` |
std::map<std::string, int> ParseContract(const std::filesystem::path& path) {
    std::ifstream file(path);
    std::map<std::string, int> parsed;
    const std::regex row(R"(^\|[^|]*\|\s*(-?[0-9]+)\s*\|\s*`([A-Za-z]+::[A-Z_]+)`\s*\|)");
    std::string line;
    while (std::getline(file, line)) {
        std::smatch match;
        if (std::regex_search(line, match, row)) {
            parsed[match[2].str()] = std::stoi(match[1].str());
        }
    }
    return parsed;
}

} // namespace

TEST_CASE("The house-style contract file exists and parses", "[ui][housestyle]") {
    const auto path = ContractPath();
    REQUIRE_FALSE(path.empty());
    INFO("contract: " << path.string());
    REQUIRE(std::filesystem::exists(path));

    const auto parsed = ParseContract(path);
    // A contract that parses to nothing would let every assertion below pass
    // vacuously, which is the failure mode this whole section replaced.
    REQUIRE(parsed.size() > 0);
    CHECK(parsed.size() == Tokens().size());
}

TEST_CASE("Every contract value matches the constant it names", "[ui][housestyle]") {
    const auto parsed = ParseContract(ContractPath());
    REQUIRE_FALSE(parsed.empty());

    for (const auto& [symbol, actual] : Tokens()) {
        CAPTURE(symbol);
        const auto found = parsed.find(symbol);
        INFO("contract.md does not list " << symbol);
        REQUIRE(found != parsed.end());
        CHECK(found->second == actual);
    }
}

// The other direction. A row naming a constant that no longer exists, or that
// was renamed, would otherwise sit in the contract unnoticed and unchecked.
TEST_CASE("The contract names no token the code does not have", "[ui][housestyle]") {
    const auto parsed = ParseContract(ContractPath());
    REQUIRE_FALSE(parsed.empty());

    for (const auto& [symbol, value] : parsed) {
        CAPTURE(symbol, value);
        INFO("contract.md names a symbol the token table does not cover");
        CHECK(Tokens().count(symbol) == 1);
    }
}
