// Tests for rui::Dpi. D00 T02 §1.
//
// DPI scaling is worth being the first thing under test rather than a
// placeholder: DESIGN.md requires every surface render correctly at every DPI,
// no control may hardcode a size, and every control in the shared library
// routes its geometry through these two functions. A rounding change here
// moves every window in the suite by a pixel.

#include <catch2/catch_test_macros.hpp>
#include <catch2/matchers/catch_matchers_floating_point.hpp>

#include <resolute/dpi.h>

using Catch::Matchers::WithinAbs;
using rui::Dpi;

// The four scale factors Windows actually offers in its display settings.
// 96 is 100%, and the rest are what a user picks from the dropdown.
TEST_CASE("Scale matches the Windows display percentages", "[ui][dpi]") {
    CHECK(Dpi::Scale(100, 96) == 100);   // 100%
    CHECK(Dpi::Scale(100, 120) == 125);  // 125%
    CHECK(Dpi::Scale(100, 144) == 150);  // 150%
    CHECK(Dpi::Scale(100, 192) == 200);  // 200%
}

// MulDiv rounds to NEAREST, which is why it is used here rather than plain
// integer division. The distinction is invisible at 100% and visible on every
// odd value at 125%, where truncation would lose half a pixel per control and
// accumulate down a stacked layout.
TEST_CASE("Scale rounds to nearest rather than toward zero", "[ui][dpi]") {
    // 1 * 120 / 96 = 1.25, nearest is 1
    CHECK(Dpi::Scale(1, 120) == 1);
    // 3 * 120 / 96 = 3.75, nearest is 4. Truncation would give 3.
    CHECK(Dpi::Scale(3, 120) == 4);
    // 5 * 144 / 96 = 7.5, away-from-zero on the tie gives 8
    CHECK(Dpi::Scale(5, 144) == 8);
}

TEST_CASE("Scale is the identity at 96 DPI", "[ui][dpi]") {
    for (int value : {0, 1, 7, 16, 100, 4096}) {
        CAPTURE(value);
        CHECK(Dpi::Scale(value, 96) == value);
    }
}

TEST_CASE("Scale handles zero and negative values", "[ui][dpi]") {
    CHECK(Dpi::Scale(0, 144) == 0);
    // Negative offsets are real: a control may inset by a negative margin.
    CHECK(Dpi::Scale(-10, 192) == -20);
}

// ScaleF is the float path, used where a fractional result must survive to the
// renderer instead of being rounded at each step. Direct2D takes floats, so
// rounding early is how a layout drifts.
TEST_CASE("ScaleF keeps the fraction that Scale rounds away", "[ui][dpi]") {
    CHECK_THAT(Dpi::ScaleF(1.0f, 120), WithinAbs(1.25f, 0.0001f));
    CHECK_THAT(Dpi::ScaleF(3.0f, 120), WithinAbs(3.75f, 0.0001f));
    CHECK_THAT(Dpi::ScaleF(5.0f, 144), WithinAbs(7.5f, 0.0001f));

    // The integer path would have rounded each of these; that is the whole
    // reason both exist.
    CHECK(Dpi::Scale(3, 120) == 4);
    CHECK_THAT(Dpi::ScaleF(3.0f, 120), WithinAbs(3.75f, 0.0001f));
}

TEST_CASE("ScaleF is the identity at 96 DPI", "[ui][dpi]") {
    CHECK_THAT(Dpi::ScaleF(13.0f, 96), WithinAbs(13.0f, 0.0001f));
    CHECK_THAT(Dpi::ScaleF(0.0f, 96), WithinAbs(0.0f, 0.0001f));
}
