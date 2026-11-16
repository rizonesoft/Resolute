# DESIGN.md

The suite's design contract moved to Resolute-SDK on 2026-11-15, beside the UI library that implements it: [`DESIGN.md` in Resolute-SDK](https://github.com/rizonesoft/Resolute-SDK/blob/main/DESIGN.md), which is `sdk/DESIGN.md` in a bootstrapped clone, at the commit `sdk.json` pins.

Every surface of the launcher answers to that file. A reference to `DESIGN.md` anywhere in this repository, with or without a section number, means that file: its section numbers 1 to 13 are the ones this file had, and sections 14 (application icons) and 15 (the SDK's identity) are new there.

## The launcher's identity

What stays here is only the launcher's own identity: its icon, wordmark and banners. The operator chose it on 2026-11-16 (`docs/plans/2026-11-15-app-split.md`, row 0b). The launcher's interface is not part of it.

- **The icon** is a gold spanner crossed under a steel screwdriver with a blue handle, free-standing with no tile behind it. The spanner runs from upper left to lower right, with its open jaw at the top and its ring at the bottom; the screwdriver lies across it, blade at the upper right.
- **It is the one icon of the suite with gradients.** Every tool's icon is flat and two-tone (`sdk/DESIGN.md` section 14); the launcher is the suite's front door and is drawn richer. Gold runs from `#FFE9A8` through the suite's Amber `#FFB020` to `#C76A00`, the steel from `#F1F5F9` to `#94A3B8`, and the handle from `#5CC8FF` to `#1D4ED8`.
- **Below 40 pixels** a second drawing is used: thicker tools, and no collar or grooves on the handle.
- **The wordmark** is the icon beside "Resolute" in Sora Bold, as every brand of the suite is set.
- **`brand/build.py` builds all of it** through the SDK's kit, and `python brand/build.py --check` says when a tracked asset differs from what it builds. It also owns `resources/icons/Resolute.ico`, the icon the executable embeds, so the two cannot drift apart. Nothing under `brand/` or that file is edited by hand.
- The Rizonesoft logo under `resources/logos/` is the company's and is not part of this identity.