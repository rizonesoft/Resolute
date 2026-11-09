## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T18:16:55Z
- Candidate: e9e118fa6bc645fbd3fbe6c1d65a287bcac3186f
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: e9e118fa6bc645fbd3fbe6c1d65a287bcac3186f
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 7
- Digest: 0d6b13b7b0c92fa1

1. **plan verdict: approve.** The proposed repair closes both in-scope gaps: quoted clean-build evidence in the section and repair record, plus a tracked, parameterized capture driver with complete reproduction commands and verification of all four captures.

2. **plan scope:** README embedding remains correctly assigned to §2. No additional application controls, persistence, Ctrl+K, or undo requirements arise from this repair.

HIGHEST: none
PLAN: complete
OVERALL: approve

- Implemented: repair built (writer, 2026-11-09). (1) The clean-build proof is quoted in the section's build item: fresh clone at c4f6fcde with no prior build output, pin-verified bootstrap (3 installed), and `pwsh scripts/build.ps1 Resolute` ending `Resolute OK Bin\Release\Resolute.exe` / `build: 1 target(s) built, Release`. (2) The capture driver is tracked as scripts/capture-launcher-readme.ps1 (parameterized, reproduction command in its header) and all four shots were re-captured through it: every sidecar's launch context now names the tracked script with its arguments, the recorded source revision is c4f6fcde31af213ebf3b6e9309ffd3a5360f206d, the exe sha256 (2CD7AD07...) matches the built exe, all four PNGs are 1582x991 with distinct hashes, and the Details and Large Icons states in both themes were inspected in the images.

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T18:19:18Z
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: e9e118fa6bc645fbd3fbe6c1d65a287bcac3186f
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 8
- Digest: c51f3d5e00f7be83

adversarial: needs-attention.

1. **P2, `scripts/capture-launcher-readme.ps1:94`: The driver forcibly retakes focus after the operator resumes work.** It attaches to the foreground application's input thread and activates the launcher without checking operator activity or requiring an explicit visible-run mode. Reproduce by running the documented capture command against `Bin\Release\Resolute.exe`, then switching to an editor during the theme-setting sleeps and typing. Lines 94-95 attempt to pull focus back to the launcher, interrupting typing. This repeats for each shot. The downstream capture helper's foreground check cannot protect against this because the driver itself takes foreground first. This violates `docs/testing.md`'s operator-input stand-down rule. Require explicit visible execution or apply the existing idle/stand-down policy before desktop interaction.

Static review only; no desktop automation executed and no files modified.

HIGHEST: P2
OVERALL: needs-attention

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T18:21:18Z
- Effort: low
- Writer model: muse-wonder-1.0
- Policy: e9e118fa6bc645fbd3fbe6c1d65a287bcac3186f
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 6
- Digest: ff19a97a136c43d2

consistency: needs-attention

1. **P2** `scripts/capture-launcher-readme.ps1:94` at `9229ff86`: The driver attaches to the foreground thread and forces activation without an explicit visible-run opt-in or idle fence. This contradicts `docs/testing.md`’s desktop-use policy and bypasses the operator-controlled foreground behavior of `capture-window.ps1`. Reproduce by running the documented capture command during daytime while typing in an editor: the driver takes focus for each shot. Require explicit visible-run consent before launching, or use the governed idle collection path. This finding concerns the requested commit, regardless of later checkout changes.

HIGHEST: P2
OVERALL: needs-attention

## Round 3: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T18:22:04Z
- Effort: low
- Writer model: muse-wonder-1.0
- Policy: e9e118fa6bc645fbd3fbe6c1d65a287bcac3186f
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: quality
- Lines: 6
- Digest: 3c40e85cf950aedc

quality: needs-attention

1. **P3**, `scripts/capture-launcher-readme.ps1:136`: The generated reproduction command omits mandatory `-Visible`. All four committed sidecars inherit this misleading command. Reproduce by running the command portion of any sidecar’s `launch context`: the driver exits 2 without capturing anything. Include `-Visible` in `$context` and correct the sidecars.

HIGHEST: P3
OVERALL: needs-attention

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: muse
- Run: 2026-11-09T18:24:21Z
- Candidate: 16031ca887fc3da7a34f9079e26610083560cf5d
- Effort: medium
- Writer model: muse-wonder-1.0
- Policy: e9e118fa6bc645fbd3fbe6c1d65a287bcac3186f
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 43
- Digest: 7f9b24230e86c8ba

Part 1: completeness

Reviewed `e9e118fa..16031ca8` read-only. No desktop capture was run, and the uncommitted review-record edit was excluded.

1. **present:** Quoted clean-build evidence now records the checkout revision, initially absent build output, bootstrap result, build command and successful output. Evidence: `todo/00-workspace/TODO-05-repo-face.md:60`.

2. **present:** The tracked driver supplies both views in both themes. All four committed PNG headers report 1582 × 991 pixels. Evidence: `scripts/capture-launcher-readme.ps1:146` and the four `docs/captures/2026-11-09-D00-T05-s1-launcher-*.png` files. Sidecars record executable hash, revision, DPI and appearance.

3. **missing-in-scope:** Sidecar commands do not work as written. The generator omits mandatory `-Visible`, leaves paths unquoted, and appends explanatory parentheses as executable PowerShell syntax. Even extracting the command before the parentheses reaches the explicit refusal without `-Visible`. It also omits `-Date`, so later reproduction changes filenames. Evidence: `scripts/capture-launcher-readme.ps1:65`, `scripts/capture-launcher-readme.ps1:134`, and all four sidecars at line 14.

4. **missing-in-scope:** Operator stand-down does not protect the complete interaction. The driver starts the visible launcher at line 107 and calls activating `SetWindowPos` at line 117 before its first idle check at line 127. After that check, there is no monitoring for resumed input during foreground acquisition or capture. Three seconds without input also treats an ordinary reading pause as desktop availability. Evidence: `scripts/capture-launcher-readme.ps1:88`, compared with `docs/testing.md:36` and `docs/testing.md:40`.

5. **present:** Basic refusal and failure cleanup exist: missing `-Visible` refuses, missing paths fail resolution, missing windows time out, capture failure propagates, and `finally` stops the launcher the driver started. Evidence: `scripts/capture-launcher-readme.ps1:65`, `:99`, `:116`, `:137`, `:139`. The helper refuses a nonforeground target at `scripts/capture-window.ps1:203`.

6. **missing-in-scope:** Regression proof for the two broken behaviors is absent. The candidate adds no tests for replaying generated commands or operator input before launch and during capture; searching `scripts/tests` found no driver coverage. Successful screenshots do not exercise either refusal path.

7. **missing-out-of-scope:** Safe replacement of existing PNG/sidecar pairs is absent in the shared capture writer. It saves the PNG directly before writing the sidecar; a locked sidecar, full disk or interruption can leave a new image with stale metadata. There is no transactional replacement or readback. Evidence: `scripts/capture-window.ps1:238` and `:293`. Owner: **D00 workspace capture infrastructure**, through a repair section for D00 T02 §3.

8. **missing-out-of-scope:** README delivery, theme selection and alternative text remain assigned to **D00 T05 §2**, specifically `todo/00-workspace/TODO-05-repo-face.md:85`. This remains outside the approved repair.

No new application controls, dialogs, shortcuts, settings, registry changes or ACL changes arise from this repair.

Part 2: excellence

Counterpart: **D00 T02 §3 capture provenance and `docs/testing.md` operator stand-down**. There is no `resolute_au3/` counterpart or changed `DESIGN.md` application surface, so AutoIt parity and application accessibility are not additional acceptance requirements here.

1. **in-scope:** Reproduction still requires manual repair of the recorded command. Target: each sidecar contains a standalone, correctly quoted command with all required switches and the recorded date, with explanation outside executable syntax. Verify the generated command through the same invocation path a second operator uses.

2. **in-scope:** Foreground safety falls short of the declared stand-down behavior. Target: no window activation while the operator is active; resumed input dismisses owned capture windows and prevents subsequent shots from taking focus. Prove both initial activity and mid-capture resumption, using the established collection threshold rather than a three-second pause.

3. **out-of-scope:** Capture publication can leave contradictory evidence after an ordinary write failure. Target: failed replacement preserves the previous valid pair, successful replacement reads back both files, and failure never reports success. Owner: D00 capture infrastructure.

4. **out-of-scope:** README readers cannot yet consume the proof shots in the intended presentation. Target: both view pairs render with appropriate theme selection and meaningful alternative text. Existing owner: D00 T05 §2.

Gap list

1. **missing-in-scope / in-scope:** Generate executable, quoted, complete reproduction commands in every sidecar.
2. **missing-in-scope / in-scope:** Enforce operator stand-down before activation and throughout capture.
3. **missing-in-scope:** Add regression proof for command replay and operator-interruption paths.
4. **missing-out-of-scope / out-of-scope:** Make shared PNG/sidecar replacement recoverable and verified; owner D00 capture infrastructure.
5. **missing-out-of-scope / out-of-scope:** Complete README image integration and alternative text through existing D00 T05 §2.

COMPLETION: gaps
