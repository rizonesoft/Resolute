// Tests for the disposable fixture store. D00 T02 §2.
//
// These test the thing that makes the destructive half of the suite testable,
// so they are written to the rule in tests/README.md: every assertion reads
// the effect back from the registry or the filesystem rather than trusting a
// helper's return value. This section is the first place that rule can be
// exercised, because D00 T02 §1's first tests were pure functions.

#include <catch2/catch_test_macros.hpp>

#include <fixtures/fixtures.h>

#include <filesystem>
#include <string>

using resolute::fixtures::FileTreeFixture;
using resolute::fixtures::FixtureError;
using resolute::fixtures::RegistryFixture;

// ── Registry: seeding and teardown ───────────────────────────

TEST_CASE("Registry fixture seeds a declared state, read back", "[fixtures][registry]") {
    RegistryFixture fixture(L"seed-readback");

    fixture.SetString(L"Product", L"Resolute");
    fixture.SetDword(L"Version", 11);
    fixture.CreateSubkey(L"Nested\\Deeper");

    // Read back from the registry, not from the setter.
    CHECK(fixture.GetString(L"Product") == L"Resolute");
    CHECK(fixture.GetDword(L"Version") == 11u);
    CHECK(fixture.ValueExists(L"Product"));
    CHECK_FALSE(fixture.ValueExists(L"NeverSet"));
}

TEST_CASE("Registry teardown leaves the key absent", "[fixtures][registry]") {
    REQUIRE_FALSE(RegistryFixture::Exists(L"teardown"));
    {
        RegistryFixture fixture(L"teardown");
        fixture.SetString(L"Anything", L"here");
        REQUIRE(RegistryFixture::Exists(L"teardown"));
    }
    // The destructor ran. Ask the registry, not the object.
    CHECK_FALSE(RegistryFixture::Exists(L"teardown"));
}

// ── Registry: cleanup on failure ─────────────────────────────

// The property that matters most. Residue is likeliest exactly when a test
// fails, which is when nobody is looking at the cleanup path.
TEST_CASE("Registry fixture leaves nothing behind when a test throws",
          "[fixtures][registry]") {
    REQUIRE_FALSE(RegistryFixture::Exists(L"aborted"));

    struct Deliberate : std::exception {};
    bool threw = false;
    try {
        RegistryFixture fixture(L"aborted");
        fixture.SetString(L"Half", L"written");
        fixture.CreateSubkey(L"WillNotSurvive");
        REQUIRE(RegistryFixture::Exists(L"aborted"));
        throw Deliberate{};             // mid-run, with state already seeded
    } catch (const Deliberate&) {
        threw = true;
    }

    REQUIRE(threw);
    CHECK_FALSE(RegistryFixture::Exists(L"aborted"));
}

// ── Registry: refusal outside the root ───────────────────────

TEST_CASE("Registry fixture refuses names outside its root", "[fixtures][registry]") {
    RegistryFixture fixture(L"refusal");

    // An absolute-looking key, a traversal, and a hive qualifier.
    CHECK_THROWS_AS(fixture.CreateSubkey(L"\\Software\\Rizonesoft"), FixtureError);
    CHECK_THROWS_AS(fixture.CreateSubkey(L"..\\..\\Rizonesoft"), FixtureError);
    CHECK_THROWS_AS(fixture.CreateSubkey(L"HKLM:\\Software"), FixtureError);
    CHECK_THROWS_AS(fixture.CreateSubkey(L""), FixtureError);

    // And the refusal is a refusal: nothing was created on the way out.
    CHECK_FALSE(fixture.ValueExists(L"Software"));
}

TEST_CASE("Registry refusal names what it refused", "[fixtures][registry]") {
    RegistryFixture fixture(L"refusal-message");
    try {
        fixture.CreateSubkey(L"..\\escape");
        FAIL("the traversal was not refused");
    } catch (const FixtureError& error) {
        const std::string message = error.what();
        // The message has to say what was refused and where the boundary is,
        // or a reader has to go and read the fixture source to find out.
        CHECK(message.find("refused") != std::string::npos);
        CHECK(message.find("..") != std::string::npos);
        CHECK(message.find("ResoluteTestFixtures") != std::string::npos);
    }
}

// ── Filesystem: a real tree with real ACLs ───────────────────

TEST_CASE("File tree fixture creates and reads back a tree", "[fixtures][files]") {
    FileTreeFixture tree(L"filetree");

    tree.MakeDir(L"sub");
    auto written = tree.WriteFile(L"sub\\payload.txt", "contents");

    CHECK(std::filesystem::exists(written));
    CHECK(tree.ReadFile(L"sub\\payload.txt") == "contents");
}

TEST_CASE("File tree fixture carries a declared owner and ACL", "[fixtures][files]") {
    FileTreeFixture tree(L"acl");
    tree.WriteFile(L"target.txt", "own me");

    // The owner is read back off the filesystem. The ownership port compares
    // exactly this before and after, so it has to be readable here first.
    const std::wstring owner = tree.OwnerSid(L"target.txt");
    CHECK_FALSE(owner.empty());
    CHECK(owner.rfind(L"S-1-", 0) == 0);

    const size_t before = tree.AccessEntryCount(L"target.txt");
    tree.GrantCurrentUser(L"target.txt", GENERIC_READ);
    const size_t after = tree.AccessEntryCount(L"target.txt");

    // Read the DACL back rather than trusting GrantCurrentUser's return.
    CHECK(after >= before);
    CHECK(after > 0);
}

// ── Filesystem: cleanup on failure ───────────────────────────

TEST_CASE("File tree leaves nothing behind when a test throws", "[fixtures][files]") {
    std::filesystem::path root;
    struct Deliberate : std::exception {};
    bool threw = false;

    try {
        FileTreeFixture tree(L"aborted-tree");
        root = tree.Root();
        tree.WriteFile(L"deep\\nested\\file.txt", "half done");
        REQUIRE(std::filesystem::exists(root));
        throw Deliberate{};
    } catch (const Deliberate&) {
        threw = true;
    }

    REQUIRE(threw);
    REQUIRE_FALSE(root.empty());
    CHECK_FALSE(std::filesystem::exists(root));
}

// ── Filesystem: refusal outside the root ─────────────────────

TEST_CASE("File tree refuses paths outside its root", "[fixtures][files]") {
    FileTreeFixture tree(L"refusal-tree");

    CHECK_THROWS_AS(tree.WriteFile(L"..\\escaped.txt", "no"), FixtureError);
    CHECK_THROWS_AS(tree.WriteFile(L"..\\..\\..\\escaped.txt", "no"), FixtureError);
    CHECK_THROWS_AS(tree.WriteFile(L"C:\\Windows\\escaped.txt", "no"), FixtureError);
    CHECK_THROWS_AS(tree.MakeDir(L""), FixtureError);

    // A traversal that stays inside is allowed, because refusing it would make
    // the guard a path-shape check rather than a boundary check.
    CHECK_NOTHROW(tree.MakeDir(L"a\\b\\..\\c"));
    CHECK(std::filesystem::exists(tree.Root() / L"a" / L"c"));
}

TEST_CASE("File tree refusal names the boundary", "[fixtures][files]") {
    FileTreeFixture tree(L"refusal-tree-message");
    try {
        tree.WriteFile(L"..\\escaped.txt", "no");
        FAIL("the escape was not refused");
    } catch (const FixtureError& error) {
        const std::string message = error.what();
        CHECK(message.find("refused") != std::string::npos);
        CHECK(message.find("outside its root") != std::string::npos);
    }
}
