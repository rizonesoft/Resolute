// Reads a reference dataset embedded by cmake/ResoluteRefdata.cmake (D00 T06 §2).
//
// Test-side only. The framework's loader is D01 T01 §14 and does not exist
// yet; this is the smallest reader that proves the embedded form documented in
// docs/reference-data.md opens at run time, and that section's loader replaces
// it. It checks what a loader must: the header, that the payload decompresses
// to exactly the size the header promises, and that the dataset and version
// stamped in the header are the ones the export inside it carries.

#pragma once

#include <windows.h>

#include <compressapi.h>

#include <cstddef>
#include <cstdint>
#include <cstring>
#include <set>
#include <string>
#include <vector>

namespace refdata_test {

struct Embedded {
    std::string   dataset;
    std::uint32_t version = 0;
    std::string   digest;      // 64 lower-case hex digits
    std::string   exportText;  // the export file's bytes
    std::size_t   embeddedSize = 0;
    std::string   error;       // empty when the dataset opened
};

inline std::string HeaderValue(const std::string& text, const char* label) {
    const std::string needle = std::string("\n") + label + " ";
    const std::size_t at = text.find(needle);
    if (at == std::string::npos) return {};
    const std::size_t from = at + needle.size();
    return text.substr(from, text.find('\n', from) - from);
}

// Opens the bytes of one embedded dataset. On failure `error` names the dataset
// when the header gave one.
inline Embedded Open(const std::vector<std::uint8_t>& blob) {
    Embedded out;
    out.embeddedSize = blob.size();
    constexpr std::size_t kFixed = 8 + 2 + 2 + 4 + 4 + 4 + 2;
    if (blob.size() < kFixed || std::memcmp(blob.data(), "RSLRDAT1", 8) != 0) {
        out.error = "not an embedded dataset";
        return out;
    }
    // Little-endian, read as unsigned throughout: a byte promoted to int would make these signed shifts.
    auto byteAt = [&](std::size_t at) { return static_cast<std::uint32_t>(blob[at]); };
    auto u16 = [&](std::size_t at) { return static_cast<std::uint16_t>(byteAt(at) | (byteAt(at + 1) << 8U)); };
    auto u32 = [&](std::size_t at) {
        return byteAt(at) | (byteAt(at + 1) << 8U) | (byteAt(at + 2) << 16U) | (byteAt(at + 3) << 24U);
    };
    const std::uint16_t format = u16(8), algorithm = u16(10), nameLength = u16(24);
    out.version = u32(12);
    const std::uint32_t rawSize = u32(16), packedSize = u32(20);
    const std::size_t payloadAt = kFixed + nameLength + 32;
    if (blob.size() < payloadAt) {
        out.error = "the header is cut short";
        return out;
    }
    out.dataset.assign(reinterpret_cast<const char*>(blob.data()) + kFixed, nameLength);
    static const char kHex[] = "0123456789abcdef";
    for (std::size_t i = 0; i < 32; ++i) {
        const std::uint8_t byte = blob[kFixed + nameLength + i];
        out.digest += kHex[static_cast<unsigned>(byte) >> 4U];
        out.digest += kHex[static_cast<unsigned>(byte) & 15U];
    }
    if (format != 1 || algorithm != COMPRESS_ALGORITHM_XPRESS_HUFF) {
        out.error = "dataset " + out.dataset + ": a format or algorithm this reader does not know";
        return out;
    }
    if (blob.size() != payloadAt + packedSize) {
        out.error = "dataset " + out.dataset + ": the header promises a different number of compressed bytes";
        return out;
    }
    DECOMPRESSOR_HANDLE handle = nullptr;
    if (!CreateDecompressor(COMPRESS_ALGORITHM_XPRESS_HUFF, nullptr, &handle)) {
        out.error = "dataset " + out.dataset + ": no decompressor";
        return out;
    }
    std::string raw(rawSize, '\0');
    SIZE_T written = 0;
    // compressapi.h declares the input PVOID; Decompress only reads it.
    std::vector<std::uint8_t> packed(blob.begin() + static_cast<std::ptrdiff_t>(payloadAt), blob.end());
    const BOOL ok = Decompress(handle, packed.data(), packedSize, raw.data(), rawSize, &written);
    CloseDecompressor(handle);
    if (!ok || written != rawSize) {
        out.error = "dataset " + out.dataset + ": the data does not decompress to the size its header promises";
        return out;
    }
    const std::string heldDataset = HeaderValue("\n" + raw, "dataset");
    const std::string heldVersion = HeaderValue("\n" + raw, "version");
    const std::string heldDigest  = HeaderValue("\n" + raw, "digest");
    if (heldDataset != out.dataset || heldVersion != std::to_string(out.version) || heldDigest != out.digest) {
        out.error = "dataset " + out.dataset + ": stamped version " + std::to_string(out.version) + " and holding " + heldDataset +
                    " version " + heldVersion + "; the stamp and the data disagree";
        return out;
    }
    out.exportText = std::move(raw);
    return out;
}

// The bytes of this executable's RCDATA resource `name`, empty when it has none.
inline std::vector<std::uint8_t> Resource(const wchar_t* name) {
    HMODULE module = GetModuleHandleW(nullptr);
    HRSRC found = FindResourceW(module, name, RT_RCDATA);
    if (!found) return {};
    HGLOBAL loaded = LoadResource(module, found);
    const auto* data = static_cast<const std::uint8_t*>(loaded ? LockResource(loaded) : nullptr);
    if (!data) return {};
    return {data, data + SizeofResource(module, found)};
}

// The names of this executable's dataset resources.
inline std::set<std::wstring> ResourceNames() {
    // The callback's LONG_PTR parameter would have to be cast back to a pointer; the names are collected through a
    // local the callback can see instead. Tests run one at a time, so one collection is ever in flight.
    static std::set<std::wstring>* collecting = nullptr;
    std::set<std::wstring> names;
    collecting = &names;
    EnumResourceNamesW(
        GetModuleHandleW(nullptr), RT_RCDATA,
        [](HMODULE, LPCWSTR, LPWSTR name, LONG_PTR) -> BOOL {
            if (!IS_INTRESOURCE(name) && std::wcsncmp(name, L"REFDATA_", 8) == 0) collecting->insert(name);
            return TRUE;
        },
        0);
    collecting = nullptr;
    return names;
}

}  // namespace refdata_test
