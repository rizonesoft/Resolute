# Run Captures

Evidence from a driven run, committed by the checkpoint that produced it.

`AGENTS.md` lists five proof types, and the fourth is "a driven run with evidence: a log line, an `.ini` readback, or a capture under `docs/captures/`". This directory is that.

## What makes a run capture evidence rather than a screenshot

Four things, and a capture missing any of them is a picture of a moment nobody can place:

1. **It says what it proves.** One line at the top, naming the claim it supports and the section that made it. A file called `output.png` proves nothing to a reader six months later.
2. **It names what produced it.** The binary and its version, or the command and its arguments, so the run can be repeated.
3. **It carries its machine.** Windows build, and DPI where the capture is visual. A capture that does not travel has to say so rather than be silently trusted on another machine.
4. **It is dated.** Against the commit it was taken at, so a reader can tell whether it predates the change they are looking at.

`scripts/capture-window.ps1` writes a `.txt` sidecar carrying all four for a window capture. A textual capture carries them in its own header.

## Prefer text

A log line, an `.ini` readback, a command's stdout and exit code are all diffable, travel between machines, and can be asserted in a test. An image is none of those.

**Capture an image only when the thing being proven is visual** and no textual form of it exists. `D00 T02 §3` rewrote itself on that basis: the house style is constants in source, so it is a contract a test enforces rather than a screenshot a human compares.

## Naming

```
docs/captures/runs/YYYY-MM-DD-<section>-<what>.<ext>
docs/captures/runs/2026-09-17-D00-T02-s3-launcher-window.png
docs/captures/runs/2026-09-17-D00-T02-s3-launcher-window.txt
```

The date is when it was captured, the section is who owes it, and the description says what it shows. Sorted by name, the directory reads chronologically.

## The appearance-by-DPI matrix

Every section that ships a user-visible surface owes that surface four captures: light and dark, at 100 and 150 percent. D00 T02 §9 set this so a surface meets human eyes in each appearance and scale before it ships, not only in whichever the developer's machine happened to use.

```
docs/captures/runs/YYYY-MM-DD-<section>-<surface>-<mode>-<dpi>.png
docs/captures/runs/2026-10-01-D01-T03-s1-main-window-dark-150.png
docs/captures/runs/2026-10-01-D01-T03-s1-main-window-dark-150.txt
```

`<mode>` is `light` or `dark`, and `<dpi>` is the scale in percent (`100` or `150`). Each capture carries the sidecar `scripts/capture-window.ps1` writes, whose `appearance` line records the appearance and whose `monitor dpi` line records the scale, so the name and the evidence can be checked against each other.

Captures prove a human looked; they are not the regression gate. Each shipped surface also extends the rendered goldens under `tests/golden/` with its own offscreen renders (`tests/ui_render_test.cpp`), which ctest diffs on every run.

A window capture needs the window in the foreground on a desktop somebody may be using, and the four need both appearances and both scales. They are therefore taken under D00 T02 §10's focus fence, which owns every headful run; the launcher's four are the fence's first instance there.

## Retention

A run capture stays as long as the claim it supports is live. When a section is restaked and its evidence is re-taken, the old capture goes in the same commit, because two captures of the same claim with different dates is an invitation to cite the wrong one.
