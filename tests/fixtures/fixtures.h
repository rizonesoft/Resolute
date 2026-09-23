#pragma once
// Disposable targets for destructive code. D00 T02 §2.
//
// The AutoIt tools went years without a test on their most dangerous paths for
// one reason: there was nothing safe to point them at. This is that thing.
//
// THREE PROPERTIES, and the third is the one that matters:
//
//   1. No elevation. The registry root is under HKCU and the file tree lives in
//      the build directory, so the whole suite runs as an ordinary user.
//
//   2. Cleanup on failure. Every fixture is RAII. A test that throws mid-run
//      still unwinds through the destructor, so residue cannot outlive a
//      failure, which is exactly when residue is most likely.
//
//   3. Refusal outside the root. Every path and key a helper is handed is
//      checked against its root before anything is touched, and a violation
//      throws with a named message rather than acting. Trusting the caller is
//      how a test suite eventually deletes somebody's documents.
//
// WHY THE REGISTRY ROOT IS NOT UNDER THE PRODUCT KEY. D00 T02 §2 was written
// against HKCU\Software\Rizonesoft\Fixtures. That key's parent holds real
// settings on a developer machine: ClassicPanel and Office were both present
// here. Teardown is recursive deletion, so a fixture root one level below live
// user data is one arithmetic mistake away from taking it. The root below is
// named for the test suite and can never be mistaken for somebody's
// preferences.

#include <windows.h>

#include <filesystem>
#include <stdexcept>
#include <string>
#include <vector>

namespace resolute::fixtures {

// ── The roots, in one place ──────────────────────────────────

// Under HKCU so no elevation is needed, and named so it cannot be confused
// with a product key.
inline constexpr const wchar_t* kRegistryRoot = L"Software\\ResoluteTestFixtures";

// Thrown when a helper is handed something outside its root, or when Windows
// refuses an operation. Carries a message naming what was refused and why.
class FixtureError : public std::runtime_error {
public:
    explicit FixtureError(const std::string& what) : std::runtime_error(what) {}
};

// ── Registry ─────────────────────────────────────────────────

// A disposable registry subtree under kRegistryRoot.
//
// Construction creates the key. Destruction deletes it, including on an
// exception. Every name handed to Set/Get/CreateSubkey is checked to be a
// relative name inside this fixture: no backslash-prefixed absolute path, no
// `..`, no escaping.
class RegistryFixture {
public:
    // `name` identifies this fixture beneath the root, so two tests running in
    // the same process cannot collide.
    explicit RegistryFixture(const std::wstring& name);
    ~RegistryFixture();

    RegistryFixture(const RegistryFixture&) = delete;
    RegistryFixture& operator=(const RegistryFixture&) = delete;

    // `HKCU\Software\ResoluteTestFixtures\<name>`, for assertions.
    const std::wstring& KeyPath() const { return m_keyPath; }

    // Seed a declared state. `valueName` may be empty for the default value.
    void SetString(const std::wstring& valueName, const std::wstring& data);
    void SetDword(const std::wstring& valueName, DWORD data);

    // Read back. These exist so a test asserts what the registry holds rather
    // than what a setter returned, which is the rule in tests/README.md.
    std::wstring GetString(const std::wstring& valueName) const;
    DWORD GetDword(const std::wstring& valueName) const;

    bool ValueExists(const std::wstring& valueName) const;

    // A nested key, for seeding a shape rather than a single value.
    void CreateSubkey(const std::wstring& relativePath);

    // Delete this fixture's key now rather than at destruction. Idempotent, so
    // the destructor can call it after an explicit teardown.
    void Remove();

    // Does the fixture key exist? Used by teardown assertions.
    static bool Exists(const std::wstring& name);

    // Is the ROOT itself present? After every fixture is torn down this must
    // be false, which is what the checkpoint asserts.
    static bool RootExists();

    // Remove the root if it is empty. Called by the suite, never by a test.
    static void RemoveRootIfEmpty();

    // Remove the root and everything under it, called by the suite BEFORE the
    // first test. RAII cleans up a throw; it does not survive a process death,
    // because std::abort and a crash run no destructors. Proven, not assumed:
    // aborting mid-test left this key behind. Sweeping at run start means a
    // previous crash's residue cannot outlive the next run.
    static void SweepRoot();

private:
    void AssertRelative(const std::wstring& candidate, const char* what) const;

    std::wstring m_name;
    std::wstring m_subPath;   // Software\ResoluteTestFixtures\<name>
    std::wstring m_keyPath;   // HKCU\... , for messages and assertions
};

// ── Filesystem ───────────────────────────────────────────────

// A disposable directory tree inside the build directory.
//
// Construction creates the root. Destruction removes it, including on an
// exception. Every path handed to a member is resolved and checked to be
// inside the fixture root before anything is created, read, or deleted.
class FileTreeFixture {
public:
    explicit FileTreeFixture(const std::wstring& name);
    ~FileTreeFixture();

    FileTreeFixture(const FileTreeFixture&) = delete;
    FileTreeFixture& operator=(const FileTreeFixture&) = delete;

    const std::filesystem::path& Root() const { return m_root; }

    // Create a file with content, making parent directories as needed.
    // `relative` must stay inside the root.
    std::filesystem::path WriteFile(const std::wstring& relative,
                                    const std::string& content);
    std::filesystem::path MakeDir(const std::wstring& relative);

    std::string ReadFile(const std::wstring& relative) const;

    // The owner of a path, as a SID string, read back from the filesystem.
    // The ownership tests compare this before and after.
    std::wstring OwnerSid(const std::wstring& relative) const;

    // Add a declared access rule, so a test has a real ACL to change. This is
    // possible unelevated because the fixture owns everything it creates,
    // verified on an unelevated session before this was written.
    void GrantCurrentUser(const std::wstring& relative, DWORD accessMask);

    // Count of access entries in the DACL, read back for assertions.
    size_t AccessEntryCount(const std::wstring& relative) const;

    void Remove();

    // The directory every fixture tree lives under.
    static std::filesystem::path StoreRoot();
    static bool StoreRootExists();
    static void RemoveStoreRootIfEmpty();

    // See RegistryFixture::SweepRoot. Same reason, same timing.
    static void SweepStoreRoot();

private:
    // Resolves `relative` against the root and refuses anything that escapes,
    // including `..` traversal and absolute paths. Returns the resolved path.
    std::filesystem::path Resolve(const std::wstring& relative) const;

    std::wstring m_name;
    std::filesystem::path m_root;
};

} // namespace resolute::fixtures
