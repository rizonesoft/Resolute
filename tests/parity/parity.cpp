#include "parity.h"

#include <aclapi.h>
#include <sddl.h>

#include <algorithm>
#include <fstream>
#include <iomanip>
#include <set>
#include <sstream>

namespace resolute::parity {
namespace {

std::string Narrow(const std::wstring& text) {
    if (text.empty()) return {};
    int needed = WideCharToMultiByte(CP_UTF8, 0, text.c_str(),
                                     static_cast<int>(text.size()),
                                     nullptr, 0, nullptr, nullptr);
    std::string out(static_cast<size_t>(needed), '\0');
    WideCharToMultiByte(CP_UTF8, 0, text.c_str(), static_cast<int>(text.size()),
                        out.data(), needed, nullptr, nullptr);
    return out;
}

// A field separator that cannot appear in a registry path, a value name, or a
// SID, so the format stays line-oriented and unambiguous without quoting.
constexpr char kSep = '\t';

// The one string both file readers return when they could not see the
// object. It is ALSO recorded as an observation failure, because two
// unreadable objects otherwise carry the same value and compare equal.
constexpr const char* kUnreadable = "unreadable";
constexpr char BS = '\\';
constexpr wchar_t WBS = L'\\';

std::string Escape(const std::string& text) {
    std::string out;
    for (char c : text) {
        if (c == '\t') out += "\\t";
        else if (c == '\n') out += "\\n";
        else if (c == '\\') out += "\\\\";
        else out += c;
    }
    return out;
}

std::string Unescape(const std::string& text) {
    std::string out;
    for (size_t i = 0; i < text.size(); ++i) {
        if (text[i] == '\\' && i + 1 < text.size()) {
            char n = text[++i];
            if (n == 't') out += '\t';
            else if (n == 'n') out += '\n';
            else if (n == BS) { out += BS; }
            else {
                // An UNRECOGNISED escape keeps the backslash it was
                // written with. Dropping it turned a hand-written target
                // of C:\fixture\a.txt into C:fixturea.txt, which
                // names a different file than the run touched. Escape()
                // emits only the three forms above, so nothing this
                // library writes reaches here and the round trip stays
                // exact; this is for records a human typed, which is how
                // the AutoIt side will emit them.
                out += BS;
                out += n;
            }
        }
        else {
            out += text[i];
        }
    }
    return out;
}

// Scanned rather than getline'd, because getline DROPS A TRAILING EMPTY
// FIELD: "a	b	" yields two parts, not three. That is not academic here.
// Ownership writes HasLUAShield and NoWorkingDirectory as EMPTY registry
// strings, so a parser that loses a trailing empty value would drop two of the
// values the tool actually sets, and a parity comparison would then pass two
// implementations that wrote different things. Found by the hand-written
// record test in D00 T02 §4, which is why that test uses an empty value.
std::vector<std::string> Split(const std::string& line, char sep) {
    std::vector<std::string> parts;
    std::string current;
    for (char c : line) {
        if (c == sep) {
            parts.push_back(current);
            current.clear();
        }
        else {
            current += c;
        }
    }
    parts.push_back(current);
    return parts;
}

std::string TypeName(DWORD type) {
    switch (type) {
        case REG_SZ:        return "REG_SZ";
        case REG_EXPAND_SZ: return "REG_EXPAND_SZ";
        case REG_DWORD:     return "REG_DWORD";
        case REG_QWORD:     return "REG_QWORD";
        case REG_BINARY:    return "REG_BINARY";
        case REG_MULTI_SZ:  return "REG_MULTI_SZ";
        default:            return "REG_" + std::to_string(type);
    }
}

// ITERATIVE, not recursive. A registry subtree has no depth bound the caller
// controls, and this instrument is pointed at whatever scope a section
// declares, so a recursive walk puts an unbounded frame count on the stack of
// a test process for a tree it did not create. The worklist also makes the
// child paths cheap to build with += rather than a chain of temporaries.
void WalkRegistry(HKEY root, const std::wstring& subKey,
                  const std::wstring& displayPrefix,
                  std::map<std::string, Entry>& into,
                  std::vector<std::string>& failures) {
    struct Pending {
        std::wstring path;
        std::wstring display;
    };
    std::vector<Pending> work;
    work.push_back({subKey, displayPrefix});

    while (!work.empty()) {
        const Pending current = work.back();
        work.pop_back();

        HKEY key{};
        const LSTATUS opened =
            RegOpenKeyExW(root, current.path.c_str(), 0, KEY_READ, &key);
        if (opened != ERROR_SUCCESS) {
            // ABSENCE IS AN OBSERVATION; REFUSAL IS NOT. A key that is not
            // there has been seen not to be there, and the record says so by
            // carrying no entry for it. Any other error means this snapshot
            // did not see part of its own scope, and a record built from it
            // must never be able to report parity.
            if (opened != ERROR_FILE_NOT_FOUND) {
                failures.push_back("registry key unreadable: "
                                   + Narrow(current.display) + " (error "
                                   + std::to_string(opened) + ")");
            }
            continue;
        }

        // THE KEY ITSELF IS A FACT. Recording only values made creating or
        // deleting an empty key invisible, so an undo that removed values and
        // left the key trees behind compared equal to a complete removal.
        // D04 T01 §1 compares Ownership's four HKCR trees key by key, which
        // that hole would have defeated. Found by the independent review.
        Entry keyEntry;
        keyEntry.kind = "registry";
        keyEntry.target = Narrow(current.display);
        keyEntry.field = "(key)";
        keyEntry.type = "key";
        keyEntry.value = "present";
        into[keyEntry.Key()] = keyEntry;

        DWORD valueCount = 0, maxNameLen = 0, subKeyCount = 0, maxSubKeyLen = 0;
        const LSTATUS queried =
            RegQueryInfoKeyW(key, nullptr, nullptr, nullptr, &subKeyCount,
                             &maxSubKeyLen, nullptr, &valueCount, &maxNameLen,
                             nullptr, nullptr, nullptr);
        if (queried != ERROR_SUCCESS) {
            failures.push_back("registry key not enumerable: "
                               + Narrow(current.display) + " (error "
                               + std::to_string(queried) + ")");
            RegCloseKey(key);
            continue;
        }

        for (DWORD i = 0; i < valueCount; ++i) {
            std::vector<wchar_t> name(maxNameLen + 2, L'\0');
            DWORD nameLen = static_cast<DWORD>(name.size());
            DWORD type = 0;
            DWORD dataLen = 0;
            const LSTATUS sized =
                RegEnumValueW(key, i, name.data(), &nameLen, nullptr, &type,
                              nullptr, &dataLen);
            if (sized != ERROR_SUCCESS) {
                failures.push_back("registry value unreadable under "
                                   + Narrow(current.display) + " (index "
                                   + std::to_string(i) + ", error "
                                   + std::to_string(sized) + ")");
                continue;
            }
            std::vector<BYTE> data(dataLen + sizeof(wchar_t), 0);
            nameLen = static_cast<DWORD>(name.size());
            DWORD size = dataLen;
            const LSTATUS read =
                RegEnumValueW(key, i, name.data(), &nameLen, nullptr, &type,
                              data.data(), &size);
            if (read != ERROR_SUCCESS) {
                failures.push_back("registry value unreadable under "
                                   + Narrow(current.display) + " (index "
                                   + std::to_string(i) + ", error "
                                   + std::to_string(read) + ")");
                continue;
            }

            Entry entry;
            entry.kind = "registry";
            entry.target = Narrow(current.display);
            entry.field = name[0] ? Narrow(std::wstring(name.data()))
                                  : "(default)";
            entry.type = TypeName(type);

            if (type == REG_SZ || type == REG_EXPAND_SZ) {
                entry.value = Narrow(
                    std::wstring(reinterpret_cast<wchar_t*>(data.data())));
            }
            else if (type == REG_DWORD) {
                entry.value = std::to_string(*reinterpret_cast<DWORD*>(data.data()));
            }
            else {
                // TWO DIGITS PER BYTE, always. Without the padding,
                // {0x01,0x23} and {0x12,0x03} both encode as "123", so a
                // change between them recorded NO change at all. Found by the
                // independent review of this section with a compiled probe.
                std::ostringstream hex;
                hex << std::hex << std::setfill('0');
                for (DWORD b = 0; b < size; ++b) {
                    hex << std::setw(2) << static_cast<unsigned>(data[b]);
                }
                entry.value = hex.str();
            }
            into[entry.Key()] = entry;
        }

        for (DWORD i = 0; i < subKeyCount; ++i) {
            std::vector<wchar_t> name(maxSubKeyLen + 2, L'\0');
            DWORD nameLen = static_cast<DWORD>(name.size());
            const LSTATUS enumerated =
                RegEnumKeyExW(key, i, name.data(), &nameLen, nullptr, nullptr,
                              nullptr, nullptr);
            if (enumerated != ERROR_SUCCESS) {
                failures.push_back("registry subkey unreadable under "
                                   + Narrow(current.display) + " (index "
                                   + std::to_string(i) + ", error "
                                   + std::to_string(enumerated) + ")");
                continue;
            }
            const std::wstring child(name.data());

            Pending next;
            next.path = current.path;
            next.path += WBS;
            next.path += child;
            next.display = current.display;
            next.display += WBS;
            next.display += child;
            work.push_back(std::move(next));
        }

        RegCloseKey(key);
    }
}

std::string OwnerSidOf(const std::filesystem::path& path) {
    PSID owner = nullptr;
    PSECURITY_DESCRIPTOR descriptor = nullptr;
    if (GetNamedSecurityInfoW(path.c_str(), SE_FILE_OBJECT,
                              OWNER_SECURITY_INFORMATION, &owner, nullptr,
                              nullptr, nullptr, &descriptor) != ERROR_SUCCESS) {
        return kUnreadable;
    }
    LPWSTR text = nullptr;
    std::string result = kUnreadable;
    if (ConvertSidToStringSidW(owner, &text)) {
        result = Narrow(text);
        LocalFree(text);
    }
    LocalFree(descriptor);
    return result;
}

// Content is recorded as size plus a cheap checksum rather than the bytes.
// A parity record is compared field by field and committed as evidence, so it
// must stay readable; what matters is whether the content changed, not what it
// became.
std::string ContentDigest(const std::filesystem::path& path) {
    std::ifstream file(path, std::ios::binary);
    if (!file) return kUnreadable;
    unsigned long long sum = 1469598103934665603ULL;
    size_t bytes = 0;
    char buffer[4096];
    while (file.read(buffer, sizeof(buffer)) || file.gcount() > 0) {
        for (std::streamsize i = 0; i < file.gcount(); ++i) {
            sum ^= static_cast<unsigned char>(buffer[i]);
            sum *= 1099511628211ULL;
        }
        bytes += static_cast<size_t>(file.gcount());
    }
    std::ostringstream out;
    out << bytes << ":" << std::hex << sum;
    return out.str();
}

} // namespace

bool Entry::operator==(const Entry& other) const {
    return kind == other.kind && target == other.target && field == other.field
        && type == other.type && value == other.value;
}

std::string Change::Describe() const {
    switch (kind) {
        case Kind::Added:
            return "added    " + after.Key() + " = " + after.value + " (" + after.type + ")";
        case Kind::Removed:
            return "removed  " + before.Key() + " was " + before.value;
        default:
            return "changed  " + after.Key() + ": " + before.value + " -> " + after.value;
    }
}

Snapshot Snapshot::OfRegistry(const std::wstring& subKeyUnderHkcu) {
    Snapshot snapshot;
    WalkRegistry(HKEY_CURRENT_USER, subKeyUnderHkcu, L"HKCU\\" + subKeyUnderHkcu,
                 snapshot.m_entries, snapshot.m_failures);
    return snapshot;
}

Snapshot Snapshot::OfFileTree(const std::filesystem::path& root) {
    Snapshot snapshot;
    std::error_code ec;
    if (!std::filesystem::exists(root, ec)) return snapshot;

    if (ec) {
        snapshot.m_failures.push_back("file tree unreadable: " + root.string()
                                      + " (" + ec.message() + ")");
        return snapshot;
    }

    for (auto it = std::filesystem::recursive_directory_iterator(root, ec);
         it != std::filesystem::recursive_directory_iterator(); it.increment(ec)) {
        if (ec) {
            // A walk that stopped early has NOT seen the rest of the tree.
            // Breaking silently returned a partial snapshot that compared
            // equal to another partial one.
            snapshot.m_failures.push_back("file tree walk stopped under "
                                          + root.string() + " (" + ec.message() + ")");
            break;
        }
        const auto& path = it->path();
        const std::string target = path.string();

        Entry owner;
        owner.kind = "file";
        owner.target = target;
        owner.field = "owner";
        owner.type = "sid";
        owner.value = OwnerSidOf(path);
        if (owner.value == kUnreadable) {
            snapshot.m_failures.push_back("file owner unreadable: " + target);
        }
        snapshot.m_entries[owner.Key()] = owner;

        if (it->is_regular_file(ec)) {
            Entry content;
            content.kind = "file";
            content.target = target;
            content.field = "content";
            content.type = "bytes";
            content.value = ContentDigest(path);
            if (content.value == kUnreadable) {
                snapshot.m_failures.push_back("file content unreadable: " + target);
            }
            snapshot.m_entries[content.Key()] = content;
        }
    }
    return snapshot;
}

Record Record::Between(const Snapshot& before, const Snapshot& after) {
    Record record;
    // Either snapshot failing to see part of its scope makes the RECORD
    // incomplete, not just that snapshot. The difference between a complete
    // observation and a partial one is exactly what a parity claim rests on.
    for (const auto& failure : before.Failures()) {
        record.m_failures.push_back("before: " + failure);
    }
    for (const auto& failure : after.Failures()) {
        record.m_failures.push_back("after: " + failure);
    }
    const auto& b = before.Entries();
    const auto& a = after.Entries();

    for (const auto& [key, entry] : a) {
        auto prior = b.find(key);
        if (prior == b.end()) {
            record.m_changes.push_back({Change::Kind::Added, {}, entry});
        }
        else if (!(prior->second == entry)) {
            record.m_changes.push_back({Change::Kind::Changed, prior->second, entry});
        }
    }
    for (const auto& [key, entry] : b) {
        if (a.find(key) == a.end()) {
            record.m_changes.push_back({Change::Kind::Removed, entry, {}});
        }
    }
    // Sorted so two records of the same effect serialise identically, whatever
    // order the walk happened to visit things in. A record that depended on
    // enumeration order would report differences that are not differences.
    std::sort(record.m_changes.begin(), record.m_changes.end(),
              [](const Change& x, const Change& y) {
                  const std::string kx = x.kind == Change::Kind::Removed ? x.before.Key() : x.after.Key();
                  const std::string ky = y.kind == Change::Kind::Removed ? y.before.Key() : y.after.Key();
                  return kx < ky;
              });
    return record;
}

// The serialised form carries the failures, so a record committed as evidence
// cannot be re-read as a clean one.
std::string Record::Serialise() const {
    std::ostringstream out;
    out << "# parity-record v1\n";
    for (const auto& [name, value] : m_header) {
        out << "# " << name << ": " << value << "\n";
    }
    for (const auto& failure : m_failures) {
        out << "# incomplete: " << Escape(failure) << "\n";
    }
    for (const auto& change : m_changes) {
        const Entry& e = (change.kind == Change::Kind::Removed) ? change.before : change.after;
        const char* op = change.kind == Change::Kind::Added   ? "+"
                       : change.kind == Change::Kind::Removed ? "-"
                                                              : "~";
        out << op << kSep << Escape(e.kind) << kSep << Escape(e.target) << kSep
            << Escape(e.field) << kSep << Escape(e.type) << kSep << Escape(e.value);
        if (change.kind == Change::Kind::Changed) {
            out << kSep << Escape(change.before.value);
        }
        out << "\n";
    }
    return out.str();
}

Record Record::Parse(const std::string& text) {
    Record record;
    std::istringstream stream(text);
    std::string line;
    size_t lineNumber = 0;
    while (std::getline(stream, line)) {
        ++lineNumber;
        if (!line.empty() && line.back() == '\r') line.pop_back();
        if (line.empty()) continue;
        if (line[0] == '#') {
            auto colon = line.find(':');
            if (colon != std::string::npos && line.size() > 2) {
                std::string name = line.substr(2, colon - 2);
                std::string value = line.substr(colon + 1);
                while (!value.empty() && value.front() == ' ') value.erase(0, 1);
                // A list, not a map entry: several failures are normal and a
                // map keyed by name would keep only the last one.
                if (name == "incomplete") {
                    record.m_failures.push_back(Unescape(value));
                }
                else {
                    record.m_header[name] = value;
                }
            }
            continue;
        }

        // STRICT. A row that cannot be read is a defect in the evidence, not a
        // row to skip. Silently dropping a short row let a record compare EQUAL
        // to one that did not contain the change the row described. An unknown
        // operation character was worse: it fell through to "changed" and was
        // counted as a real observation. Both found by the independent review.
        const auto parts = Split(line, kSep);
        const std::string& op = parts[0];
        if (op != "+" && op != "-" && op != "~") {
            throw ParityError("parity record line " + std::to_string(lineNumber)
                              + ": unknown operation, expected one of + - ~");
        }
        const size_t expected = (op == "~") ? 7 : 6;
        if (parts.size() != expected) {
            throw ParityError("parity record line " + std::to_string(lineNumber)
                              + ": operation " + op + " needs "
                              + std::to_string(expected) + " fields, found "
                              + std::to_string(parts.size()));
        }

        Entry entry;
        entry.kind = Unescape(parts[1]);
        entry.target = Unescape(parts[2]);
        entry.field = Unescape(parts[3]);
        entry.type = Unescape(parts[4]);
        entry.value = Unescape(parts[5]);

        Change change{};
        if (parts[0] == "+") {
            change.kind = Change::Kind::Added;
            change.after = entry;
        }
        else if (parts[0] == "-") {
            change.kind = Change::Kind::Removed;
            change.before = entry;
        }
        else {
            change.kind = Change::Kind::Changed;
            change.after = entry;
            change.before = entry;
            change.before.value = Unescape(parts[6]);
        }
        record.m_changes.push_back(change);
    }
    return record;
}

std::string Record::Header(const std::string& name) const {
    auto found = m_header.find(name);
    return found == m_header.end() ? std::string{} : found->second;
}

std::string Difference::Describe() const {
    return key + ": A=" + inA + "  B=" + inB;
}

std::vector<Difference> Compare(const Record& a, const Record& b) {
    auto index = [](const Record& record) {
        std::map<std::string, std::string> out;
        for (const auto& change : record.Changes()) {
            const Entry& e = (change.kind == Change::Kind::Removed) ? change.before : change.after;
            const char* op = change.kind == Change::Kind::Added   ? "+"
                           : change.kind == Change::Kind::Removed ? "-"
                                                                  : "~";
            out[e.Key()] = std::string(op) + " " + e.type + " " + e.value;
        }
        return out;
    };

    const auto ia = index(a);
    const auto ib = index(b);

    std::set<std::string> keys;
    for (const auto& [k, v] : ia) keys.insert(k);
    for (const auto& [k, v] : ib) keys.insert(k);

    std::vector<Difference> differences;

    // AN UNOBSERVED SCOPE IS NOT AN IDENTICAL ONE. Each failure becomes a
    // difference of its own, so a record that could not see part of its scope
    // can never return an empty comparison and can never be reported as
    // parity. Two runs that both failed to read the same key would otherwise
    // have produced two empty snapshots and compared equal.
    std::map<std::string, std::pair<bool, bool>> failed;
    differences.reserve(a.Failures().size() + b.Failures().size());
    for (const auto& failure : a.Failures()) failed[failure].first = true;
    for (const auto& failure : b.Failures()) failed[failure].second = true;
    for (const auto& [reason, sides] : failed) {
        // One row per distinct failure, each side labelled with what it
        // actually did. Two rows for a failure BOTH sides hit would read as a
        // disagreement between them, which is not what happened.
        differences.push_back({"incomplete|" + reason,
                               sides.first ? "observation failed" : "observed",
                               sides.second ? "observation failed" : "observed"});
    }

    for (const auto& key : keys) {
        auto fa = ia.find(key);
        auto fb = ib.find(key);
        const std::string va = fa == ia.end() ? "absent" : fa->second;
        const std::string vb = fb == ib.end() ? "absent" : fb->second;
        if (va != vb) differences.push_back({key, va, vb});
    }
    return differences;
}

std::string Report(const Record& a, const Record& b,
                   const std::string& labelA, const std::string& labelB) {
    const auto differences = Compare(a, b);
    std::ostringstream out;
    out << "parity: " << labelA << " vs " << labelB << "\n";

    // Said first and said plainly. A reader skimming for the verdict must
    // not have to notice that the differing fields happen to be failures.
    // The word PARITY is deliberately absent from this branch.
    if (!a.Complete() || !b.Complete()) {
        out << "  NOT COMPARABLE. The observation was incomplete, so no\n";
        out << "  claim about equivalence can be made from it.\n";
        for (const auto& failure : a.Failures()) {
            out << "    " << labelA << ": " << failure << "\n";
        }
        for (const auto& failure : b.Failures()) {
            out << "    " << labelB << ": " << failure << "\n";
        }
    }

    if (differences.empty()) {
        out << "  PARITY. " << a.Size() << " change(s) each, no differing fields.\n";
        return out.str();
    }
    out << "  " << differences.size() << " differing field(s):\n";
    for (const auto& difference : differences) {
        out << "    " << difference.key << "\n";
        out << "      " << labelA << ": " << difference.inA << "\n";
        out << "      " << labelB << ": " << difference.inB << "\n";
    }
    return out.str();
}

} // namespace resolute::parity
