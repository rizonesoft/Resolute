# Tests

Catch2 v3. One suite for the whole repository, run with `ctest --preset debug`.

Catch2 is a dependency, not a design. What this file decides is the **shape of an assertion**, because fourteen tools written against three different assertion styles is the fourteen-copies problem in a new place, and `AGENTS.md` exists largely to stop that.

## Running them

```powershell
pwsh scripts/build.ps1 Resolute -Config Debug   # builds the suite too
ctest --preset debug                            # runs it
ctest --preset debug --output-on-failure        # and shows why, when it fails
```

`pwsh scripts/check-all.ps1` runs the suite as one of its gates. A failing test fails the gate.

## Naming

One file per unit under test, named after it: `dpi_test.cpp` tests `Dpi`.

A test case is named for the **behaviour it pins**, not for the function it calls. `"Scale rounds to nearest, not toward zero"` survives a rename of the function; `"test ScaleF"` tells a later reader nothing about what broke.

```cpp
TEST_CASE("Scale rounds to nearest at fractional DPI", "[ui][dpi]") { ... }
```

## Tagging by tool

Every test carries at least one tag naming what it belongs to, because the suite will eventually hold fourteen tools' tests and a failure has to be attributable at a glance.

| Tag | Means |
| --- | --- |
| `[ui]` | the shared Direct2D UI library |
| `[framework]` | `src/framework/`, consumed by every tool |
| `[repair]` | the repair contract |
| `[<tool>]` | that tool specifically, lowercase: `[ownership]`, `[regstudio]` |

A second tag narrows: `"[ui][dpi]"`. Run one group with `ctest --preset debug -R` or `catch2 "[dpi]"`.

## The rule that matters

**A test asserting a system effect reads the effect back. It never trusts a return value.**

This is the one convention that is not a style preference. Six tools in this suite change a user's registry, ACLs, or drive, and `AGENTS.md` freezes what they write. A test that asserts `TakeOwnership() == true` proves that a function returned true. A test that reads the owner back off the path proves the thing the user cares about.

```cpp
// Not this: the return value is the function's opinion of itself.
REQUIRE(SetLongPathsEnabled(true) == true);

// This: the registry is asked what actually happened.
SetLongPathsEnabled(true);
REQUIRE(ReadLongPathsFromRegistry() == true);
```

The same applies to a file written, an `.ini` value stored, a service restarted, and an attribute cleared. Write, then read back, then assert on what came back.

**And the reverse is asserted too**, wherever the code offers one. A repair-contract item that claims an undo is not proven by the undo returning success; it is proven by the system matching what it was before, compared field by field.

## What a failure has to print

A failure is read by somebody who did not write the test, often months later. It must carry the tool tag, the expected value, and the actual value without anybody re-running it with more flags.

Catch2 does this for `REQUIRE(a == b)` on its own. It does **not** do it for `REQUIRE(f())`, which prints only that `f()` was false. Prefer the comparison form, and use `INFO` or `CAPTURE` when context is needed:

```cpp
CAPTURE(dpi, value);          // both appear in the failure output
REQUIRE(Dpi::Scale(value, dpi) == expected);
```

## Fixtures

Destructive code gets a disposable target rather than the developer's machine. `D00 T02 §2` builds that store; until it lands, a test that would touch real system state does not get written, it gets deferred with a named owner.

## What does not belong here

A file that prints something and asserts nothing is not a test. The repository carried one for a while, `test_font.cpp`, which `printf`ed DirectWrite metrics at the repository root, was built by nothing, and was deleted by `D00 T02 §1`. If a measurement is worth keeping, it belongs in the document that reasons about it, such as `DESIGN.md`, or in a test that asserts something about it.
