// Embedded reference data. D00 T06 §2.
//
// The test executable names two fixture datasets through
// resolute_embed_refdata (tests/CMakeLists.txt): `probe`, a real export of the
// database made by the authoring tool's self-test, and `bulk`, a generated
// dataset of the beep data's size. These cases read them back
// from the executable's own resources at run time: a dataset decompresses to
// exactly its committed export, its version reads back from the header, a
// stamp that disagrees with the data is refused naming the dataset, the
// embedded form is smaller than the export for a dataset of realistic size,
// and the executable carries the datasets it names and no other.

#include <catch2/catch_test_macros.hpp>

#include "helpers/refdata_blob.h"

#include <filesystem>
#include <fstream>
#include <sstream>
#include <string>

namespace {

std::string ReadFixture(const char* name) {
    std::ifstream in(std::filesystem::path(RESOLUTE_REFDATA_FIXTURE_DIR) / name, std::ios::binary);
    std::ostringstream text;
    text << in.rdbuf();
    return text.str();
}

}  // namespace

TEST_CASE("refdata: an embedded dataset decompresses to its committed export", "[refdata]") {
    const auto blob = refdata_test::Resource(L"REFDATA_PROBE");
    REQUIRE_FALSE(blob.empty());
    const auto opened = refdata_test::Open(blob);
    INFO(opened.error);
    REQUIRE(opened.error.empty());
    const std::string committed = ReadFixture("probe.refdata");
    REQUIRE_FALSE(committed.empty());
    CHECK(opened.exportText == committed);
    CHECK(opened.dataset == "probe");
}

TEST_CASE("refdata: an embedded dataset's version reads back at run time", "[refdata]") {
    const auto opened = refdata_test::Open(refdata_test::Resource(L"REFDATA_PROBE"));
    REQUIRE(opened.error.empty());
    const std::string committed = ReadFixture("probe.refdata");
    CHECK(std::to_string(opened.version) == refdata_test::HeaderValue("\n" + committed, "version"));
    CHECK(opened.digest == refdata_test::HeaderValue("\n" + committed, "digest"));
    CHECK(opened.version > 0);
}

TEST_CASE("refdata: a stamp that disagrees with the data is refused naming the dataset", "[refdata]") {
    auto blob = refdata_test::Resource(L"REFDATA_PROBE");
    REQUIRE_FALSE(blob.empty());
    blob[12] = static_cast<std::uint8_t>(blob[12] + 1);  // the header's version, low byte
    const auto opened = refdata_test::Open(blob);
    CHECK(opened.exportText.empty());
    CHECK(opened.error.find("dataset probe") != std::string::npos);
    CHECK(opened.error.find("disagree") != std::string::npos);
}

TEST_CASE("refdata: damaged embedded bytes are refused, never read as data", "[refdata]") {
    auto blob = refdata_test::Resource(L"REFDATA_BULK");
    REQUIRE(blob.size() > 200);
    for (std::size_t i = blob.size() - 64; i < blob.size(); ++i) blob[i] = 0;
    const auto opened = refdata_test::Open(blob);
    CHECK(opened.exportText.empty());
    CHECK_FALSE(opened.error.empty());

    blob = refdata_test::Resource(L"REFDATA_BULK");
    blob.resize(blob.size() - 9);
    CHECK_FALSE(refdata_test::Open(blob).error.empty());
}

TEST_CASE("refdata: a dataset of realistic size is smaller embedded than exported", "[refdata]") {
    const auto blob = refdata_test::Resource(L"REFDATA_BULK");
    const auto opened = refdata_test::Open(blob);
    INFO(opened.error);
    REQUIRE(opened.error.empty());
    const std::string committed = ReadFixture("bulk.refdata");
    CHECK(opened.exportText == committed);
    INFO("exported " << committed.size() << " bytes, embedded " << blob.size());
    CHECK(blob.size() * 2 < committed.size());
}

TEST_CASE("refdata: the executable carries the datasets it names and no other", "[refdata]") {
    const auto names = refdata_test::ResourceNames();
    CHECK(names == std::set<std::wstring>{L"REFDATA_BULK", L"REFDATA_PROBE"});
}
