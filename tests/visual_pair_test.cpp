// Port-vs-port visual comparison: engine drills and the fenced pair case.
// D00 T02 section 12. The drills are focus-free and run in the default
// suite; the pair case is [headful] and compares a fresh launcher capture
// against the composed baseline (the section 10 capture of record).

#include <catch2/catch_test_macros.hpp>
#include <wincodec.h>
#include <wrl/client.h>

#include <algorithm>
#include <filesystem>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>

#include "fence.h"
#include "focus_guard.h"
#include "visual_pair.h"

using Microsoft::WRL::ComPtr;
using visualpair::Compare;
using visualpair::EquivalenceMap;
using visualpair::Image;
using visualpair::MeasureRegion;
using visualpair::Observed;
using visualpair::RegionSpec;

namespace {

IWICImagingFactory* Wic() {
    static ComPtr<IWICImagingFactory> factory = [] {
        CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
        ComPtr<IWICImagingFactory> f;
        CoCreateInstance(CLSID_WICImagingFactory, nullptr, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&f));
        return f;
    }();
    return factory.Get();
}

bool LoadPng(const std::filesystem::path& path, Image& img) {
    ComPtr<IWICBitmapDecoder> dec;
    ComPtr<IWICBitmapFrameDecode> frame;
    ComPtr<IWICFormatConverter> conv;
    if (FAILED(Wic()->CreateDecoderFromFilename(path.c_str(), nullptr, GENERIC_READ, WICDecodeMetadataCacheOnDemand,
                                                &dec)) ||
        FAILED(dec->GetFrame(0, &frame)) || FAILED(Wic()->CreateFormatConverter(&conv)) ||
        FAILED(conv->Initialize(frame.Get(), GUID_WICPixelFormat32bppBGRA, WICBitmapDitherTypeNone, nullptr, 0.0,
                                WICBitmapPaletteTypeCustom)))
        return false;
    UINT w = 0, h = 0;
    conv->GetSize(&w, &h);
    img.w = static_cast<int>(w);
    img.h = static_cast<int>(h);
    img.px.assign(static_cast<size_t>(w) * h, 0);
    return SUCCEEDED(conv->CopyPixels(nullptr, w * 4, w * h * 4, reinterpret_cast<BYTE*>(img.px.data())));
}

struct Spec {
    std::vector<RegionSpec> regions;
    EquivalenceMap equivalents;
};

Spec LoadSpec() {
    Spec out;
    std::ifstream in(std::filesystem::path(RESOLUTE_SOURCE_ROOT) / "tests" / "visual_pair_spec.txt");
    std::string line;
    while (std::getline(in, line)) {
        if (line.empty() || line[0] == '#') continue;
        std::vector<std::string> f;
        std::stringstream ss(line);
        std::string cell;
        while (std::getline(ss, cell, '|')) f.push_back(cell);
        if (f.size() >= 2 && f[0] == "equiv") {
            out.equivalents[f[1]] = f[2];
        } else if (f.size() >= 11 && f[0] == "region") {
            RegionSpec r;
            r.name = f[1];
            r.label = f[2];
            r.value = f[3];
            r.x0 = std::stod(f[4]);
            r.y0 = std::stod(f[5]);
            r.x1 = std::stod(f[6]);
            r.y1 = std::stod(f[7]);
            r.minPainted = std::stod(f[8]);
            r.minDetail = std::stod(f[9]);
            r.text = f[10] == "text";
            out.regions.push_back(r);
        }
    }
    return out;
}

std::vector<Observed> MeasureAll(const Image& img, const std::vector<RegionSpec>& regions) {
    std::vector<Observed> out;
    for (const RegionSpec& r : regions) {
        Observed o;
        MeasureRegion(img, r, o);
        if (!r.label.empty()) o.label = r.label;  // labels come from the spec record
        out.push_back(o);
    }
    return out;
}

Image Synthetic(bool dark) {
    Image img;
    img.w = 200;
    img.h = 100;
    const uint32_t bg = dark ? 0xFF101010u : 0xFFF0F0F0u;
    const uint32_t fg = dark ? 0xFFF0F0F0u : 0xFF101010u;
    img.px.assign(200 * 100, bg);
    for (int y = 10; y < 30; ++y)
        for (int x = 10; x < 90; ++x)
            if ((x + y) % 3 == 0) img.px[static_cast<size_t>(y) * 200 + x] = fg;
    return img;
}

RegionSpec SyntheticSpec() {
    RegionSpec r;
    r.name = "tool-list";
    r.label = "Tools";
    r.x0 = 0.0;
    r.y0 = 0.0;
    r.x1 = 0.5;
    r.y1 = 0.5;
    r.minPainted = 0.05;
    r.minDetail = 0.5;
    r.text = true;
    return r;
}

bool AnyNames(const std::vector<std::string>& failures, const std::string& needle) {
    return std::any_of(failures.begin(), failures.end(),
                       [&](const std::string& f) { return f.find(needle) != std::string::npos; });
}

}  // namespace

TEST_CASE("Visual pair spec enumerates the launcher regions", "[visual-pair]") {
    const Spec spec = LoadSpec();
    CHECK(spec.regions.size() == 5);
    CHECK(AnyNames([&] {
              std::vector<std::string> names;
              for (const auto& r : spec.regions) names.push_back(r.name);
              return names;
          }(),
          "status-bar"));
    CHECK(spec.equivalents.count("Resolute") == 1);
}

TEST_CASE("A renamed label fails naming the control", "[visual-pair]") {
    const RegionSpec want = SyntheticSpec();
    Observed got;
    got.name = "tool-list";
    got.present = true;
    got.label = "Utilities";
    got.painted = 0.5;
    got.detail = 5;
    got.contrast = 10;
    const auto failures = Compare({want}, {got}, {}, {});
    CHECK(AnyNames(failures, "tool-list"));
    CHECK(AnyNames(failures, "label"));
}

TEST_CASE("A removed control fails naming the region", "[visual-pair]") {
    const RegionSpec want = SyntheticSpec();
    const auto failures = Compare({want}, {}, {}, {});
    CHECK(AnyNames(failures, "tool-list"));
    CHECK(AnyNames(failures, "missing"));
}

TEST_CASE("A clipped control fails under the theme exemption", "[visual-pair]") {
    const RegionSpec want = SyntheticSpec();
    Observed got;
    got.name = "tool-list";
    got.present = true;
    got.label = "Tools";
    got.painted = 0.5;
    got.detail = 5;
    got.contrast = 10;
    got.clipped = true;
    const auto failures = Compare({want}, {got}, {}, {"theme"});
    CHECK(AnyNames(failures, "clipped"));
}

TEST_CASE("A low-contrast region fails despite a theme exemption", "[visual-pair]") {
    const RegionSpec want = SyntheticSpec();
    Observed got;
    got.name = "tool-list";
    got.present = true;
    got.label = "Tools";
    got.painted = 0.5;
    got.detail = 5;
    got.contrast = 2.0;  // below the 4.5:1 text floor
    const auto failures = Compare({want}, {got}, {}, {"theme"});
    CHECK(AnyNames(failures, "contrast"));
}

TEST_CASE("Dark and light of the same layout pass with the theme exemption quoted", "[visual-pair]") {
    const std::vector<RegionSpec> spec{SyntheticSpec()};
    const auto light = MeasureAll(Synthetic(false), spec);
    const auto dark = MeasureAll(Synthetic(true), spec);
    const std::vector<std::string> exemptions{"theme"};
    std::string quoted;
    for (const auto& e : exemptions) quoted += (quoted.empty() ? "" : ",") + e;
    INFO("exemption quoted: " << quoted);
    CHECK(Compare(spec, light, {}, exemptions).empty());
    CHECK(Compare(spec, dark, {}, exemptions).empty());
}

TEST_CASE("The unmodified real 150 capture passes against the section 10 baseline", "[visual-pair]") {
    const Spec spec = LoadSpec();
    Image baseline;
    const auto path =
        std::filesystem::path(RESOLUTE_SOURCE_ROOT) / "docs" / "captures" / "runs" / "2026-11-09-D00-T02-s10-launcher-light-150.png";
    REQUIRE(LoadPng(path, baseline));
    const auto observed = MeasureAll(baseline, spec.regions);
    const auto failures = Compare(spec.regions, observed, spec.equivalents, {});
    INFO("failures: " << failures.size());
    for (const auto& f : failures) INFO(f);
    CHECK(failures.empty());
}

TEST_CASE("A blurred copy of the 150 capture fails", "[visual-pair]") {
    const Spec spec = LoadSpec();
    Image img;
    const auto path =
        std::filesystem::path(RESOLUTE_SOURCE_ROOT) / "docs" / "captures" / "runs" / "2026-11-09-D00-T02-s10-launcher-light-150.png";
    REQUIRE(LoadPng(path, img));
    // Box blur, radius 2, two passes: edges smear, detail collapses.
    Image blurred = img;
    for (int pass = 0; pass < 2; ++pass) {
        const Image srcPass = blurred;
    for (int y = 2; y < img.h - 2; ++y) {
        for (int x = 2; x < img.w - 2; ++x) {
            int r = 0, g = 0, b = 0;
            for (int dy = -2; dy <= 2; ++dy)
                for (int dx = -2; dx <= 2; ++dx) {
                    const uint32_t c = srcPass.px[static_cast<size_t>(y + dy) * img.w + (x + dx)];
                    r += static_cast<int>((c >> 16) & 0xFF);
                    g += static_cast<int>((c >> 8) & 0xFF);
                    b += static_cast<int>(c & 0xFF);
                }
            blurred.px[static_cast<size_t>(y) * img.w + x] =
                0xFF000000u | (static_cast<uint32_t>(r / 25) << 16) | (static_cast<uint32_t>(g / 25) << 8) |
                static_cast<uint32_t>(b / 25);
        }
    }
    }
    const auto failures = Compare(spec.regions, MeasureAll(blurred, spec.regions), spec.equivalents, {});
    CHECK(!failures.empty());
}

TEST_CASE("Launcher pair at 150 percent compares against the composed baseline", "[visual-pair][headful][place:dpi144]") {
    RESOLUTE_HEADFUL_GATE();
    // The C++ leg: a fresh capture of the running launcher, taken by the
    // capture script into build scratch, compared region by region against
    // the section 10 baseline of record. The AutoIt half of the pair is
    // deferred to D03 T02 section 7 (elevated session); this case proves
    // the harness the pair will run on.
    HMONITOR monitor = focusguard::MonitorWithDpi(144);
    if (!monitor) {
        const std::string why = "hardware absent: no monitor at 144 DPI; re-probed each night";
        std::printf("SKIP \"%s\" %s\n", Catch::getResultCapture().getCurrentTestName().c_str(), why.c_str());
        std::fflush(stdout);
        SKIP(why);
    }
    const Spec spec = LoadSpec();
    Image baseline;
    REQUIRE(LoadPng(std::filesystem::path(RESOLUTE_SOURCE_ROOT) / "docs" / "captures" / "runs" /
                        "2026-11-09-D00-T02-s10-launcher-light-150.png",
                    baseline));
    const auto baselineObserved = MeasureAll(baseline, spec.regions);
    REQUIRE(Compare(spec.regions, baselineObserved, spec.equivalents, {}).empty());

    // Fresh capture through the same script and target the section 10
    // matrix uses, into build scratch (never docs/captures/runs/).
    const std::filesystem::path out = std::filesystem::path(RESOLUTE_CAPTURE_DIR) / "pair-launcher-light-150.png";
    std::error_code made;
    std::filesystem::create_directories(out.parent_path(), made);
    const std::filesystem::path script = std::filesystem::path(RESOLUTE_SOURCE_ROOT) / "scripts" / "capture-window.ps1";
    std::wstring cmd = L"pwsh -NoProfile -File \"" + script.wstring() + L"\" -Path \"" +
                       std::filesystem::path(RESOLUTE_LAUNCHER).wstring() + L"\" -WindowTitle Resolute -Appearance light" +
                       L" -Fixture \"visual pair: launcher at startup, extensions scanned\" -Out \"" + out.wstring() +
                       L"\" -Describes \"visual pair C++ leg, light, 150 percent (D00 T02 section 12)\"";
    STARTUPINFOW si{};
    si.cb = sizeof(si);
    PROCESS_INFORMATION pi{};
    std::vector<wchar_t> buf(cmd.begin(), cmd.end());
    buf.push_back(L'\0');
    REQUIRE(CreateProcessW(nullptr, buf.data(), nullptr, nullptr, FALSE, 0, nullptr, nullptr, &si, &pi));
    const DWORD wait = WaitForSingleObject(pi.hProcess, 120000);
    DWORD rc = 1;
    GetExitCodeProcess(pi.hProcess, &rc);
    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);
    REQUIRE(wait == WAIT_OBJECT_0);
    INFO("capture-window exit " << rc << " (3 means it failed closed without the foreground)");
    REQUIRE(rc == 0);
    REQUIRE(std::filesystem::exists(out));
    std::filesystem::path sidecar = out;
    sidecar.replace_extension(".txt");
    REQUIRE(std::filesystem::exists(sidecar));
    std::ifstream sin(sidecar);
    const std::string sidecarText((std::istreambuf_iterator<char>(sin)), std::istreambuf_iterator<char>());
    CHECK(sidecarText.find("fixture") != std::string::npos);
    CHECK(sidecarText.find("launch args") != std::string::npos);
    CHECK(sidecarText.find("locale") != std::string::npos);
    CHECK(sidecarText.find("exe sha256") != std::string::npos);
    CHECK(sidecarText.find("source revision") != std::string::npos);

    Image fresh;
    REQUIRE(LoadPng(out, fresh));
    const auto freshObserved = MeasureAll(fresh, spec.regions);
    const auto failures = Compare(spec.regions, freshObserved, spec.equivalents, {"dpi"});
    std::printf("visual pair: %zu regions, %zu divergence(s)\n", spec.regions.size(), failures.size());
    for (const auto& f : failures) std::printf("visual pair divergence: %s\n", f.c_str());
    std::fflush(stdout);
    CHECK(failures.empty());
}
