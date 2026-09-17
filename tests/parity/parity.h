#pragma once
// The parity instrument. D00 T02 §4.
//
// AGENTS.md's fifth proof type is that a C++ tool and its AutoIt counterpart
// run against the same fixture and produce the same effect, compared field by
// field. Without this, "1:1 with the AutoIt version" is an intention.
//
// THE RECORD IS TAKEN FROM OUTSIDE THE RUN. A snapshot of a declared scope
// before, a snapshot after, and the record is the difference. That is not a
// convenience: the AutoIt binaries cannot be instrumented, have no command
// line, and expose nothing to UI Automation, so anything requiring the tool to
// report on itself could never compare the two implementations at all. Taking
// the record from outside needs no cooperation from either side.
//
// A DIFF IS A LIST OF FIELDS, NEVER A BOOLEAN. Comparing exit codes is how two
// tools that did completely different things both report success. Every
// comparison here names the target, the field, and both values.
//
// WHAT PARITY DOES NOT COVER, stated here because a later section will be
// tempted to claim it does: the RENDERED SURFACE. Two tools can produce
// identical system state and look nothing alike, and two tools can look
// identical and do different things. Pixels are not effects. DESIGN.md and
// D00 T02 §3's contract own appearance; D01 T02 §5 owns whether a surface
// rendered what it specified. A pixel comparison is never parity evidence.
//
// FAILING TO OBSERVE IS NOT OBSERVING NO DIFFERENCE. Every way this library
// can fail to see the system is recorded as an observation failure, and a
// record carrying one can never report parity. The independent review of this
// section found four routes by which it could: an unreadable scope became an
// empty snapshot, an empty registry key left no trace at all, two different
// binary values collided into one string, and a malformed row was discarded.
// Each of those let two runs that did different things compare equal, which is
// the one failure a parity instrument must not have.

#include <windows.h>

#include <cstdint>
#include <filesystem>
#include <stdexcept>
#include <map>
#include <string>
#include <vector>

namespace resolute::parity {

// Thrown when a parity record is malformed. A record is evidence, so a row
// that cannot be read is a defect in the evidence rather than a row to skip:
// silently dropping it lets a record compare equal to one that does not contain
// the change the dropped row described.
struct ParityError : std::runtime_error {
    using std::runtime_error::runtime_error;
};

// One observed fact about the system: a target, a field on it, a type, and a
// value. Keyed by target plus field, which is what makes a field-by-field
// comparison possible rather than a whole-file one.
struct Entry {
    std::string kind;     // "registry" or "file"
    std::string target;   // the key path, or the file path
    std::string field;    // the value name, or "owner" / "content"
    std::string type;     // REG_SZ, REG_DWORD, sid, bytes
    std::string value;

    std::string Key() const { return kind + "|" + target + "|" + field; }
    bool operator==(const Entry& other) const;
};

// What a run did: entries added, removed, or changed between two snapshots.
struct Change {
    enum class Kind : std::uint8_t { Added, Removed, Changed };
    Kind kind;
    Entry before;   // empty for Added
    Entry after;    // empty for Removed

    std::string Describe() const;
};

// A snapshot of a declared scope at a moment. Not itself the record.
class Snapshot {
public:
    // Every value under an HKCU subtree. HKCU because a fixture must not need
    // elevation; the scope is whatever the caller declares.
    static Snapshot OfRegistry(const std::wstring& subKeyUnderHkcu);

    // Every file under a directory, with its owner SID and content hash.
    static Snapshot OfFileTree(const std::filesystem::path& root);

    const std::map<std::string, Entry>& Entries() const { return m_entries; }
    size_t Size() const { return m_entries.size(); }

    // Every place this snapshot could not see the system. A key it was refused,
    // a value it could not enumerate, a file whose owner or content it could
    // not read. NOT the same as finding nothing there: a scope that does not
    // exist is an observation of absence and is complete.
    const std::vector<std::string>& Failures() const { return m_failures; }
    bool Complete() const { return m_failures.empty(); }

private:
    std::map<std::string, Entry> m_entries;
    std::vector<std::string> m_failures;
};

// The parity record: what changed between two snapshots of the same scope.
class Record {
public:
    Record() = default;
    static Record Between(const Snapshot& before, const Snapshot& after);

    // The declarative file. Line-oriented on purpose: diffable in git,
    // greppable, and parseable by anything, including a future AutoIt-side
    // emitter that will not have this library.
    std::string Serialise() const;
    static Record Parse(const std::string& text);

    const std::vector<Change>& Changes() const { return m_changes; }
    size_t Size() const { return m_changes.size(); }

    void SetHeader(const std::string& name, const std::string& value) {
        m_header[name] = value;
    }
    std::string Header(const std::string& name) const;

    // Carried from both snapshots. A record that could not observe part of its
    // scope is not comparable, and Compare() will never return empty for one.
    const std::vector<std::string>& Failures() const { return m_failures; }
    bool Complete() const { return m_failures.empty(); }

private:
    std::vector<Change> m_changes;
    std::map<std::string, std::string> m_header;
    std::vector<std::string> m_failures;
};

// One difference between two records, for the field-by-field report.
struct Difference {
    std::string key;        // kind|target|field
    std::string inA;        // "absent" when the record does not have it
    std::string inB;
    std::string Describe() const;
};

// Compare two records. An empty result is parity; anything else names every
// field that differs and what each side said. An incomplete record on either
// side always yields at least one difference, so an unobserved scope cannot be
// mistaken for an identical one.
std::vector<Difference> Compare(const Record& a, const Record& b);

// The human-readable report. Names every differing field, or says parity.
std::string Report(const Record& a, const Record& b,
                   const std::string& labelA, const std::string& labelB);

} // namespace resolute::parity
