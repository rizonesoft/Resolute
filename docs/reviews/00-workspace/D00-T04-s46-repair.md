## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T21:22:30Z
- Candidate: 275fcec6756a9835a8d394b85423b2bab8a961c9
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 275fcec6756a9835a8d394b85423b2bab8a961c9
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 5
- Digest: c6dcb151835a8210

1. **P2, plan lens, section lines 1896, 1897 and 1904:** Byte-for-byte preservation is required but not proven by the existing self-test. At the candidate, `scripts/todo-graph.py:1273` compares `read_text()` with the fixture string, which normalizes Windows line endings. A refused sync that rewrites CRLF as LF could still pass. Require before/after `read_bytes()` comparisons for every refusal case, including the new `Moved` case, with a CRLF fixture.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

- Planned: finding 1, every refusal case compares `read_bytes` before and after under LF and CRLF, in the section-correction commit that follows this record

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T21:28:01Z
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 275fcec6756a9835a8d394b85423b2bab8a961c9
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 6
- Digest: 6acf9b76b44677d0

### adversarial: approve

No findings in the candidate range. Read-only probes found no refusal bypass at valid or stale `Moved` notes.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-12T21:29:38Z
- Candidate: 13a402ca61adf86e00e4c1b7f4b046ba63ae8153
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: 275fcec6756a9835a8d394b85423b2bab8a961c9
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 29
- Digest: ae44363e8923d0ff

The stray-row refusal is complete within §46’s scope. One existing safety gap remains in the successful-sync path. No files were modified.

Part 1: completeness

1. **present:** Phase and table boundaries are tracked, including headings, paragraphs, blank lines and missing delimiters. Evidence: `scripts/todo-graph.py:847` and `:864`; refusal fixtures at `:1258`.
2. **present:** A `Moved` note ends table membership, preventing subsequent rows from being silently accepted. Evidence: `scripts/todo-graph.py:916`; regression fixture at `:1269`.
3. **present:** Both `--check` and `--sync` refuse stray rows with exit code 1, section reference and line number. Evidence: `scripts/todo-graph.py:927`, `:970` and `:977`.
4. **present:** Refused sync returns before writing. Tests compare original and resulting bytes for LF and CRLF inputs. Evidence: `scripts/todo-graph.py:975` and `:1272`. My in-memory runs confirmed zero write calls for all six refusal cases in both modes.
5. **present:** Recovery instructions say to move rows into their phase tables before syncing. Evidence: `scripts/todo-graph.py:770`, `:974`, `:994`; assertions at `:1285`.
6. **present:** Valid plans remain accepted. Evidence: control at `scripts/todo-graph.py:1287`; live `plan --check` passed with 75/241 sections complete.
7. **present:** Consumers invoke the guarded commands: `scripts/check-all.ps1:229`, `.claude/skills/process-phase/SKILL.md:38`, and the projection step in `.github/workflows/plan.yml`. Documentation describes the refusal in `todo/README.md:419`.
8. **present:** Regression coverage exercises both modes, diagnostics, preservation and recovery guidance. Evidence: `scripts/todo-graph.py:1258–1289`. I inspected these tests but did not run the disk-writing self-test under the no-modification instruction.
9. **missing-out-of-scope:** Successful sync overwrites the plan directly, without atomic replacement or readback (`scripts/todo-graph.py:999`). A full disk or interrupted write can truncate the committed plan, including uncommitted manual edits. A new **D00 workspace tooling** section should own atomic publication, readback and failure-path tests. This predates the candidate and does not compromise refused-sync preservation.

GUI controls, focus order, themes, DPI, elevation, registry operations and user settings do not apply to this parser-only feature. Refusal requires no undo because it writes nothing.

Part 2: excellence

Counterpart: **none** in `resolute_au3/`. Behavioral parity and `DESIGN.md`’s rendered-surface requirements are not applicable.

1. **out-of-scope:** Successful-sync recovery falls below the repository’s atomic-write and readback rule. Target: failed writes or replacements preserve the previous plan byte-for-byte; successful publication is read back and verified; disk-full and locked-destination tests demonstrate those guarantees. Evidence: `scripts/todo-graph.py:999`. Owner: D00 workspace tooling.

No additional concrete shortfall was found in §46’s refusal behavior, feedback or common-case steps.

Gap list

1. **missing-out-of-scope / out-of-scope:** `scripts/todo-graph.py:999`: successful sync needs atomic publication, readback and failure-preservation tests, owned by a new D00 workspace tooling section; not filed because this review prohibits file changes.

COMPLETION: gaps

- Filed: D00 T04 §47 (a successful plan sync writes in place, without atomic replacement or readback)
