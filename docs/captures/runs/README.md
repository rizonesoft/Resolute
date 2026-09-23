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

## Retention

A run capture stays as long as the claim it supports is live. When a section is restaked and its evidence is re-taken, the old capture goes in the same commit, because two captures of the same claim with different dates is an invitation to cite the wrong one.
