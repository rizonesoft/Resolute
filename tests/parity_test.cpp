// Tests for the parity instrument. D00 T02 §4.
//
// These use D00 T02 §2's disposable fixtures, so every assertion is against
// real registry and filesystem state rather than a mock. The record is taken
// from OUTSIDE the change, which is the property that will let it compare an
// uninstrumentable AutoIt binary against a C++ tool when D04 T01 §1 ports one.

#include <catch2/catch_test_macros.hpp>

#include <fixtures/fixtures.h>
#include <parity/parity.h>

#include <string>

using resolute::fixtures::FileTreeFixture;
using resolute::fixtures::RegistryFixture;
using resolute::parity::Compare;
using resolute::parity::Record;
using resolute::parity::Report;
using resolute::parity::Snapshot;

namespace {
// A pointer rather than a std::wstring: a namespace-scope wstring allocates
// during static initialisation, where a throw cannot be caught.
constexpr const wchar_t* kScope = L"Software\\ResoluteTestFixtures";
}

// ── A hand-written record parses ─────────────────────────────

TEST_CASE("A hand-written parity record parses", "[parity]") {
    const std::string text =
        "# parity-record v1\n"
        "# tool: Ownership\n"
        "# impl: autoit\n"
        "+\tregistry\tHKCR\\Directory\\shell\\runas\t(default)\tREG_SZ\tTake Ownership\n"
        "~\tfile\tC:\\fixture\\a.txt\towner\tsid\tS-1-5-21-2\tS-1-5-21-1\n"
        "-\tregistry\tHKCR\\Drive\\shell\\runas\tHasLUAShield\tREG_SZ\t\n";

    const Record record = Record::Parse(text);
    CHECK(record.Header("tool") == "Ownership");
    CHECK(record.Header("impl") == "autoit");
    REQUIRE(record.Size() == 3);

    // A changed entry carries BOTH values, which is what makes the diff a
    // report rather than a flag.
    // A Windows path in a hand-written record survives unescaping. An
    // unrecognised escape that dropped its backslash turned this target
    // into C:fixturea.txt, naming a different file than the run touched.
    CHECK(record.Changes()[1].after.target == "C:\\fixture\\a.txt");

    const auto& changed = record.Changes()[1];
    CHECK(changed.before.value == "S-1-5-21-1");
    CHECK(changed.after.value == "S-1-5-21-2");
}

TEST_CASE("A record round-trips through serialise and parse", "[parity]") {
    RegistryFixture fixture(L"parity-roundtrip");
    const Snapshot before = Snapshot::OfRegistry(kScope);
    fixture.SetString(L"Product", L"Resolute");
    fixture.SetDword(L"Build", 1994);
    const Snapshot after = Snapshot::OfRegistry(kScope);

    Record record = Record::Between(before, after);
    record.SetHeader("tool", "roundtrip");
    REQUIRE(record.Size() >= 2);

    const Record reparsed = Record::Parse(record.Serialise());
    CHECK(reparsed.Size() == record.Size());
    CHECK(reparsed.Header("tool") == "roundtrip");
    // The serialised form is the comparison unit, so a round trip that lost
    // anything would make a committed record mean less than the run it came
    // from.
    CHECK(Compare(record, reparsed).empty());
}

// ── The record names what a run changed ──────────────────────

TEST_CASE("A registry change between snapshots appears in the record", "[parity]") {
    RegistryFixture fixture(L"parity-registry");
    const Snapshot before = Snapshot::OfRegistry(kScope);

    fixture.SetString(L"Installed", L"yes");
    fixture.SetDword(L"Version", 11);

    const Snapshot after = Snapshot::OfRegistry(kScope);
    const Record record = Record::Between(before, after);

    const std::string text = record.Serialise();
    INFO(text);
    CHECK(text.find("Installed") != std::string::npos);
    CHECK(text.find("yes") != std::string::npos);
    CHECK(text.find("Version") != std::string::npos);
    CHECK(text.find("REG_DWORD") != std::string::npos);
}

TEST_CASE("A changed registry value records both sides", "[parity]") {
    RegistryFixture fixture(L"parity-changed");
    fixture.SetString(L"Mode", L"before");
    const Snapshot before = Snapshot::OfRegistry(kScope);

    fixture.SetString(L"Mode", L"after");
    const Snapshot snapshotAfter = Snapshot::OfRegistry(kScope);

    const Record record = Record::Between(before, snapshotAfter);
    REQUIRE(record.Size() == 1);

    const auto& change = record.Changes()[0];
    CHECK(change.kind == resolute::parity::Change::Kind::Changed);
    CHECK(change.before.value == "before");
    CHECK(change.after.value == "after");
}

TEST_CASE("A removed registry value is recorded as removed", "[parity]") {
    RegistryFixture fixture(L"parity-removed");
    fixture.SetString(L"Temporary", L"here");
    const Snapshot before = Snapshot::OfRegistry(kScope);

    fixture.Remove();          // the whole fixture key goes
    const Snapshot after = Snapshot::OfRegistry(kScope);

    const Record record = Record::Between(before, after);
    REQUIRE(record.Size() >= 1);
    CHECK(record.Serialise().find("-\tregistry") != std::string::npos);
    CHECK(record.Serialise().find("Temporary") != std::string::npos);
}

TEST_CASE("A filesystem change between snapshots appears in the record", "[parity]") {
    FileTreeFixture tree(L"parity-files");
    tree.WriteFile(L"existing.txt", "original");
    const Snapshot before = Snapshot::OfFileTree(tree.Root());

    tree.WriteFile(L"added.txt", "new file");
    tree.WriteFile(L"existing.txt", "modified content");

    const Snapshot after = Snapshot::OfFileTree(tree.Root());
    const Record record = Record::Between(before, after);

    const std::string text = record.Serialise();
    INFO(text);
    CHECK(text.find("added.txt") != std::string::npos);
    CHECK(text.find("existing.txt") != std::string::npos);
    // The owner is recorded for every path, because that is the field the
    // tools that DO touch ACLs are compared on.
    CHECK(text.find("sid") != std::string::npos);
}

// ── The comparison is a field list, never a boolean ──────────

TEST_CASE("Two identical records report parity", "[parity]") {
    RegistryFixture fixture(L"parity-identical");
    const Snapshot before = Snapshot::OfRegistry(kScope);
    fixture.SetString(L"Same", L"value");
    const Snapshot after = Snapshot::OfRegistry(kScope);

    const Record a = Record::Between(before, after);
    const Record b = Record::Parse(a.Serialise());

    CHECK(Compare(a, b).empty());
    const std::string report = Report(a, b, "cpp", "autoit");
    INFO(report);
    CHECK(report.find("PARITY") != std::string::npos);
}

TEST_CASE("Two different records name every differing field", "[parity]") {
    // Two runs that touched the same targets differently. This is the case
    // comparing exit codes cannot see: both runs "succeeded".
    const Record a = Record::Parse(
        "# impl: cpp\n"
        "+\tregistry\tHKCR\\Directory\\shell\\runas\t(default)\tREG_SZ\tTake Ownership\n"
        "+\tregistry\tHKCR\\Directory\\shell\\runas\\command\t(default)\tREG_SZ\tcmd.exe /c takeown\n");
    const Record b = Record::Parse(
        "# impl: autoit\n"
        "+\tregistry\tHKCR\\Directory\\shell\\runas\t(default)\tREG_SZ\tTake Ownership\n"
        "+\tregistry\tHKCR\\Directory\\shell\\runas\\command\t(default)\tREG_SZ\tcmd.exe /c DIFFERENT\n");

    const auto differences = Compare(a, b);
    REQUIRE(differences.size() == 1);
    CHECK(differences[0].key.find("command") != std::string::npos);
    CHECK(differences[0].inA.find("takeown") != std::string::npos);
    CHECK(differences[0].inB.find("DIFFERENT") != std::string::npos);

    const std::string report = Report(a, b, "cpp", "autoit");
    INFO(report);
    CHECK(report.find("1 differing field") != std::string::npos);
    CHECK(report.find("PARITY") == std::string::npos);
}

TEST_CASE("A field present on one side only is named, not ignored", "[parity]") {
    const Record a = Record::Parse(
        "+\tregistry\tHKCU\\Software\\X\tOnlyInA\tREG_SZ\tvalue\n");
    const Record b = Record::Parse("");

    const auto differences = Compare(a, b);
    REQUIRE(differences.size() == 1);
    CHECK(differences[0].inB == "absent");
    // A comparison that silently ignored a field one side never wrote would
    // pass two tools that did different amounts of work.
    CHECK(Report(a, b, "cpp", "autoit").find("absent") != std::string::npos);
}
