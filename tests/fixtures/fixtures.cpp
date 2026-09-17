#include "fixtures.h"

#include <aclapi.h>
#include <sddl.h>

#include <system_error>

namespace resolute::fixtures {
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

[[noreturn]] void Throw(const std::string& what, LSTATUS status) {
    throw FixtureError(what + " (win32 " + std::to_string(status) + ")");
}

// Recursive key delete. RegDeleteTreeW does this, and it is used rather than a
// hand-rolled walk precisely because the hand-rolled walk is where a teardown
// bug would live.
LSTATUS DeleteKeyTree(const std::wstring& subPath) {
    HKEY key{};
    LSTATUS status = RegOpenKeyExW(HKEY_CURRENT_USER, subPath.c_str(), 0,
                                   KEY_READ | KEY_WRITE, &key);
    if (status == ERROR_FILE_NOT_FOUND) return ERROR_SUCCESS;
    if (status != ERROR_SUCCESS) return status;
    status = RegDeleteTreeW(key, nullptr);
    RegCloseKey(key);
    if (status != ERROR_SUCCESS) return status;
    return RegDeleteKeyW(HKEY_CURRENT_USER, subPath.c_str());
}

bool KeyExists(const std::wstring& subPath) {
    HKEY key{};
    if (RegOpenKeyExW(HKEY_CURRENT_USER, subPath.c_str(), 0, KEY_READ, &key)
            == ERROR_SUCCESS) {
        RegCloseKey(key);
        return true;
    }
    return false;
}

} // namespace

// ── RegistryFixture ──────────────────────────────────────────

// The refusal. A name that is empty, absolute, or contains a traversal segment
// never reaches the registry API: it throws first, naming what was refused.
void RegistryFixture::AssertRelative(const std::wstring& candidate,
                                     const char* what) const {
    if (candidate.empty()) {
        throw FixtureError(std::string("fixture refused an empty ") + what);
    }
    if (candidate.front() == L'\\' || candidate.front() == L'/') {
        throw FixtureError(std::string("fixture refused an absolute ") + what
                           + ": '" + Narrow(candidate)
                           + "'. Names are relative to " + Narrow(m_keyPath));
    }
    if (candidate.find(L"..") != std::wstring::npos) {
        throw FixtureError(std::string("fixture refused a traversing ") + what
                           + ": '" + Narrow(candidate)
                           + "'. A fixture may not reach outside "
                           + Narrow(m_keyPath));
    }
    // A colon would name a different hive or a stream.
    if (candidate.find(L':') != std::wstring::npos) {
        throw FixtureError(std::string("fixture refused a qualified ") + what
                           + ": '" + Narrow(candidate) + "'");
    }
}

RegistryFixture::RegistryFixture(const std::wstring& name) : m_name(name) {
    m_subPath = std::wstring(kRegistryRoot) + L"\\" + name;
    m_keyPath = L"HKCU\\" + m_subPath;
    // The name itself is checked before it is used to build a path.
    AssertRelative(name, "fixture name");

    HKEY key{};
    DWORD disposition = 0;
    LSTATUS status = RegCreateKeyExW(HKEY_CURRENT_USER, m_subPath.c_str(), 0,
                                     nullptr, REG_OPTION_NON_VOLATILE,
                                     KEY_READ | KEY_WRITE, nullptr, &key,
                                     &disposition);
    if (status != ERROR_SUCCESS) {
        Throw("fixture could not create " + Narrow(m_keyPath), status);
    }
    RegCloseKey(key);
}

// Cleanup on failure lives here. A test that throws unwinds through this, so
// residue cannot outlive a failure.
RegistryFixture::~RegistryFixture() {
    DeleteKeyTree(m_subPath);   // best effort: a destructor may not throw
}

void RegistryFixture::SetString(const std::wstring& valueName,
                                const std::wstring& data) {
    if (!valueName.empty()) AssertRelative(valueName, "value name");
    HKEY key{};
    LSTATUS status = RegOpenKeyExW(HKEY_CURRENT_USER, m_subPath.c_str(), 0,
                                   KEY_WRITE, &key);
    if (status != ERROR_SUCCESS) Throw("fixture could not open its key", status);
    status = RegSetValueExW(key, valueName.empty() ? nullptr : valueName.c_str(),
                            0, REG_SZ,
                            reinterpret_cast<const BYTE*>(data.c_str()),
                            static_cast<DWORD>((data.size() + 1) * sizeof(wchar_t)));
    RegCloseKey(key);
    if (status != ERROR_SUCCESS) Throw("fixture could not set a string", status);
}

void RegistryFixture::SetDword(const std::wstring& valueName, DWORD data) {
    if (!valueName.empty()) AssertRelative(valueName, "value name");
    HKEY key{};
    LSTATUS status = RegOpenKeyExW(HKEY_CURRENT_USER, m_subPath.c_str(), 0,
                                   KEY_WRITE, &key);
    if (status != ERROR_SUCCESS) Throw("fixture could not open its key", status);
    status = RegSetValueExW(key, valueName.empty() ? nullptr : valueName.c_str(),
                            0, REG_DWORD,
                            reinterpret_cast<const BYTE*>(&data), sizeof(data));
    RegCloseKey(key);
    if (status != ERROR_SUCCESS) Throw("fixture could not set a dword", status);
}

std::wstring RegistryFixture::GetString(const std::wstring& valueName) const {
    wchar_t buffer[1024]{};
    DWORD size = sizeof(buffer);
    DWORD type = 0;
    LSTATUS status = RegGetValueW(HKEY_CURRENT_USER, m_subPath.c_str(),
                                  valueName.empty() ? nullptr : valueName.c_str(),
                                  RRF_RT_REG_SZ, &type, buffer, &size);
    if (status != ERROR_SUCCESS) Throw("fixture could not read a string", status);
    return std::wstring(buffer);
}

DWORD RegistryFixture::GetDword(const std::wstring& valueName) const {
    DWORD data = 0;
    DWORD size = sizeof(data);
    DWORD type = 0;
    LSTATUS status = RegGetValueW(HKEY_CURRENT_USER, m_subPath.c_str(),
                                  valueName.empty() ? nullptr : valueName.c_str(),
                                  RRF_RT_REG_DWORD, &type, &data, &size);
    if (status != ERROR_SUCCESS) Throw("fixture could not read a dword", status);
    return data;
}

bool RegistryFixture::ValueExists(const std::wstring& valueName) const {
    DWORD size = 0;
    return RegGetValueW(HKEY_CURRENT_USER, m_subPath.c_str(),
                        valueName.empty() ? nullptr : valueName.c_str(),
                        RRF_RT_ANY, nullptr, nullptr, &size) == ERROR_SUCCESS;
}

void RegistryFixture::CreateSubkey(const std::wstring& relativePath) {
    AssertRelative(relativePath, "subkey path");
    std::wstring full = m_subPath + L"\\" + relativePath;
    HKEY key{};
    LSTATUS status = RegCreateKeyExW(HKEY_CURRENT_USER, full.c_str(), 0, nullptr,
                                     REG_OPTION_NON_VOLATILE, KEY_READ | KEY_WRITE,
                                     nullptr, &key, nullptr);
    if (status != ERROR_SUCCESS) Throw("fixture could not create a subkey", status);
    RegCloseKey(key);
}

void RegistryFixture::Remove() {
    LSTATUS status = DeleteKeyTree(m_subPath);
    if (status != ERROR_SUCCESS) Throw("fixture could not delete its key", status);
}

bool RegistryFixture::Exists(const std::wstring& name) {
    return KeyExists(std::wstring(kRegistryRoot) + L"\\" + name);
}

bool RegistryFixture::RootExists() {
    return KeyExists(kRegistryRoot);
}

void RegistryFixture::RemoveRootIfEmpty() {
    HKEY key{};
    if (RegOpenKeyExW(HKEY_CURRENT_USER, kRegistryRoot, 0, KEY_READ, &key)
            != ERROR_SUCCESS) {
        return;
    }
    DWORD subkeys = 0, values = 0;
    RegQueryInfoKeyW(key, nullptr, nullptr, nullptr, &subkeys, nullptr, nullptr,
                     &values, nullptr, nullptr, nullptr, nullptr);
    RegCloseKey(key);
    // Only ever removes an EMPTY root, so a concurrent fixture cannot be
    // deleted out from under a running test.
    if (subkeys == 0 && values == 0) {
        RegDeleteKeyW(HKEY_CURRENT_USER, kRegistryRoot);
    }
}

void RegistryFixture::SweepRoot() {
    // The root is named for the test suite and can hold nothing else, which
    // is why this is safe to do unconditionally at run start.
    DeleteKeyTree(kRegistryRoot);
}

// ── FileTreeFixture ──────────────────────────────────────────

std::filesystem::path FileTreeFixture::StoreRoot() {
    // Under the build directory, which is gitignored and user-writable, so
    // nothing here needs elevation and nothing here is ever committed, and
    // `rm -rf build` removes every fixture with it.
    //
    // CMake supplies the path, so no absolute path is written into a tracked
    // build file, which is what D00 T01 §4 requires. The temp fallback exists
    // for a test binary run outside the build that produced it.
#ifdef RESOLUTE_FIXTURE_ROOT
    return std::filesystem::path(RESOLUTE_FIXTURE_ROOT);
#else
    return std::filesystem::temp_directory_path() / L"resolute-fixtures";
#endif
}

// The refusal. `relative` is resolved against the root and the result must
// still be under it. This catches `..`, an absolute path, and a drive-qualified
// path alike, because all three are visible after resolution and none is
// reliably visible before it.
std::filesystem::path FileTreeFixture::Resolve(const std::wstring& relative) const {
    if (relative.empty()) {
        throw FixtureError("fixture refused an empty path");
    }
    std::filesystem::path candidate(relative);
    if (candidate.is_absolute()) {
        throw FixtureError("fixture refused an absolute path: '"
                           + Narrow(relative) + "'. Paths are relative to "
                           + m_root.string());
    }
    std::filesystem::path combined = m_root / candidate;
    // weakly_canonical resolves `..` without requiring the target to exist,
    // which matters because most of these paths are about to be created.
    std::filesystem::path resolved = std::filesystem::weakly_canonical(combined);
    std::filesystem::path root = std::filesystem::weakly_canonical(m_root);

    auto rootIt = root.begin();
    auto resIt = resolved.begin();
    for (; rootIt != root.end(); ++rootIt, ++resIt) {
        if (resIt == resolved.end() || *resIt != *rootIt) {
            throw FixtureError("fixture refused a path outside its root: '"
                               + Narrow(relative) + "' resolves to "
                               + resolved.string() + ", which is not under "
                               + root.string());
        }
    }
    return resolved;
}

FileTreeFixture::FileTreeFixture(const std::wstring& name) : m_name(name) {
    if (name.empty() || name.find(L"..") != std::wstring::npos
        || std::filesystem::path(name).is_absolute()) {
        throw FixtureError("fixture refused the tree name '" + Narrow(name) + "'");
    }
    m_root = StoreRoot() / name;
    std::error_code ec;
    std::filesystem::create_directories(m_root, ec);
    if (ec) {
        throw FixtureError("fixture could not create " + m_root.string()
                           + ": " + ec.message());
    }
}

FileTreeFixture::~FileTreeFixture() {
    std::error_code ec;
    std::filesystem::remove_all(m_root, ec);   // best effort in a destructor
}

std::filesystem::path FileTreeFixture::MakeDir(const std::wstring& relative) {
    std::filesystem::path target = Resolve(relative);
    std::error_code ec;
    std::filesystem::create_directories(target, ec);
    if (ec) throw FixtureError("fixture could not create a directory: " + ec.message());
    return target;
}

std::filesystem::path FileTreeFixture::WriteFile(const std::wstring& relative,
                                                 const std::string& content) {
    std::filesystem::path target = Resolve(relative);
    std::error_code ec;
    std::filesystem::create_directories(target.parent_path(), ec);

    HANDLE handle = CreateFileW(target.c_str(), GENERIC_WRITE, 0, nullptr,
                                CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
    if (handle == INVALID_HANDLE_VALUE) {
        Throw("fixture could not create " + target.string(),
              static_cast<LSTATUS>(GetLastError()));
    }
    DWORD written = 0;
    if (!::WriteFile(handle, content.data(), static_cast<DWORD>(content.size()),
                     &written, nullptr)) {
        DWORD err = GetLastError();
        CloseHandle(handle);
        Throw("fixture could not write " + target.string(),
              static_cast<LSTATUS>(err));
    }
    CloseHandle(handle);
    return target;
}

std::string FileTreeFixture::ReadFile(const std::wstring& relative) const {
    std::filesystem::path target = Resolve(relative);
    HANDLE handle = CreateFileW(target.c_str(), GENERIC_READ, FILE_SHARE_READ,
                                nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL,
                                nullptr);
    if (handle == INVALID_HANDLE_VALUE) {
        Throw("fixture could not open " + target.string(),
              static_cast<LSTATUS>(GetLastError()));
    }
    std::string out;
    char buffer[4096];
    DWORD read = 0;
    while (::ReadFile(handle, buffer, sizeof(buffer), &read, nullptr) && read > 0) {
        out.append(buffer, read);
    }
    CloseHandle(handle);
    return out;
}

std::wstring FileTreeFixture::OwnerSid(const std::wstring& relative) const {
    std::filesystem::path target = Resolve(relative);
    PSID owner = nullptr;
    PSECURITY_DESCRIPTOR descriptor = nullptr;
    DWORD status = GetNamedSecurityInfoW(target.c_str(), SE_FILE_OBJECT,
                                         OWNER_SECURITY_INFORMATION, &owner,
                                         nullptr, nullptr, nullptr, &descriptor);
    if (status != ERROR_SUCCESS) {
        Throw("fixture could not read the owner of " + target.string(),
              static_cast<LSTATUS>(status));
    }
    LPWSTR text = nullptr;
    std::wstring result;
    if (ConvertSidToStringSidW(owner, &text)) {
        result = text;
        LocalFree(text);
    }
    LocalFree(descriptor);
    return result;
}

void FileTreeFixture::GrantCurrentUser(const std::wstring& relative,
                                       DWORD accessMask) {
    std::filesystem::path target = Resolve(relative);

    HANDLE token = nullptr;
    if (!OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &token)) {
        Throw("fixture could not open the process token",
              static_cast<LSTATUS>(GetLastError()));
    }
    DWORD size = 0;
    GetTokenInformation(token, TokenUser, nullptr, 0, &size);
    std::vector<BYTE> buffer(size);
    if (!GetTokenInformation(token, TokenUser, buffer.data(), size, &size)) {
        DWORD err = GetLastError();
        CloseHandle(token);
        Throw("fixture could not read the token user", static_cast<LSTATUS>(err));
    }
    CloseHandle(token);
    PSID user = reinterpret_cast<TOKEN_USER*>(buffer.data())->User.Sid;

    PACL existing = nullptr;
    PSECURITY_DESCRIPTOR descriptor = nullptr;
    DWORD status = GetNamedSecurityInfoW(target.c_str(), SE_FILE_OBJECT,
                                         DACL_SECURITY_INFORMATION, nullptr,
                                         nullptr, &existing, nullptr, &descriptor);
    if (status != ERROR_SUCCESS) {
        Throw("fixture could not read the DACL of " + target.string(),
              static_cast<LSTATUS>(status));
    }

    EXPLICIT_ACCESS_W access{};
    access.grfAccessPermissions = accessMask;
    access.grfAccessMode = GRANT_ACCESS;
    access.grfInheritance = NO_INHERITANCE;
    access.Trustee.TrusteeForm = TRUSTEE_IS_SID;
    access.Trustee.TrusteeType = TRUSTEE_IS_USER;
    access.Trustee.ptstrName = reinterpret_cast<LPWSTR>(user);

    PACL updated = nullptr;
    status = SetEntriesInAclW(1, &access, existing, &updated);
    if (status != ERROR_SUCCESS) {
        LocalFree(descriptor);
        Throw("fixture could not build a DACL", static_cast<LSTATUS>(status));
    }
    status = SetNamedSecurityInfoW(const_cast<LPWSTR>(target.c_str()),
                                   SE_FILE_OBJECT, DACL_SECURITY_INFORMATION,
                                   nullptr, nullptr, updated, nullptr);
    LocalFree(updated);
    LocalFree(descriptor);
    if (status != ERROR_SUCCESS) {
        Throw("fixture could not set the DACL of " + target.string(),
              static_cast<LSTATUS>(status));
    }
}

size_t FileTreeFixture::AccessEntryCount(const std::wstring& relative) const {
    std::filesystem::path target = Resolve(relative);
    PACL dacl = nullptr;
    PSECURITY_DESCRIPTOR descriptor = nullptr;
    DWORD status = GetNamedSecurityInfoW(target.c_str(), SE_FILE_OBJECT,
                                         DACL_SECURITY_INFORMATION, nullptr,
                                         nullptr, &dacl, nullptr, &descriptor);
    if (status != ERROR_SUCCESS) {
        Throw("fixture could not read the DACL of " + target.string(),
              static_cast<LSTATUS>(status));
    }
    size_t count = dacl ? dacl->AceCount : 0;
    LocalFree(descriptor);
    return count;
}

void FileTreeFixture::Remove() {
    std::error_code ec;
    std::filesystem::remove_all(m_root, ec);
    if (ec) throw FixtureError("fixture could not remove its tree: " + ec.message());
}

bool FileTreeFixture::StoreRootExists() {
    std::error_code ec;
    return std::filesystem::exists(StoreRoot(), ec);
}

void FileTreeFixture::SweepStoreRoot() {
    std::error_code ec;
    std::filesystem::remove_all(StoreRoot(), ec);
}

void FileTreeFixture::RemoveStoreRootIfEmpty() {
    std::error_code ec;
    if (!std::filesystem::exists(StoreRoot(), ec)) return;
    if (std::filesystem::directory_iterator(StoreRoot(), ec)
            == std::filesystem::directory_iterator()) {
        std::filesystem::remove(StoreRoot(), ec);
    }
}

} // namespace resolute::fixtures
