---
name: independent-review
description: Get an independent review of your own work from the reviewer pinned in .conclave/reviewers.toml (a different model family from yours, capped at medium effort), through scripts/review-dispatch.py, then verify and act on every finding. Use before calling a nontrivial change done, before a commit that ships, or when a TODO section needs its review round.
---

# Independent review

Your own review is not enough for a nontrivial change: a different model reviews it. One writer and one independent reviewer per session: Codex (`--writer codex`) uses Argon (`agy` CLI); Claude (`--writer claude`), Antigravity/Gemini (`--writer gemini`), and Meta/Muse (`--writer muse` or `--writer meta`) use GPT-6 Astra (`codex` CLI). Claude is never a reviewer. Reviewer effort is strictly capped at `medium` (`low` or `medium` only; `scripts/review-dispatch.py` refuses any effort above `medium`). The pin's `[schedule]` sets each pass's lenses and effort (`plan` at `medium`, round 1 at `medium` with `adversarial` alone, later rounds at `low` rotating through the pin’s `rotation` lenses up to `max_low_rounds = 32`, a `P1` on a low round using the `low` adversarial escalation, and final `completion` at `medium`). Pass `--writer <claude|codex|gemini|muse|meta> --writer-model <exact-model-version>` and keep one findings file. `scripts/review-dispatch.py` writes the review to the `--record` findings file and appends the writer's settled items (`- Filed:`, `- Not taken:`, `- Settled:` lines in that file) to every prompt.

| Work written by | `--writer` flag | Reviewer (every pass, max `medium` effort) | Fallback |
| --- | --- | --- | --- |
| Claude (`claude`) | `--writer claude` | GPT-6 Astra (`codex`) | none |
| Antigravity / Gemini (`agy`) | `--writer gemini` | GPT-6 Astra (`codex`) | none |
| Codex (`codex`) | `--writer codex` | Gemini 4 Argon (`agy`) | none |
| Muse / Meta | `--writer muse` / `--writer meta` | GPT-6 Astra (`codex`) | none |

The pin refuses an unknown writer or reviewer CLI, an effort above `medium`, a reviewer named twice or more than four, and a reviewer of the writer's own model family. A loop ends on the first clean round. The dispatcher judges cleanliness from declarations alone: exactly one standalone `HIGHEST: P3` or `HIGHEST: none` line (a missing, duplicate, or contradictory declaration is not clean). Declaring P3 or none while a `P1` or `P2` finding stands is a false declaration, not a clean round: the reviewer's duty is to report severity truthfully, and the dispatcher does not scan findings to check; an outage is no review, so run the round again.

## Steps

1. Review your own change first and fix what you find.
2. Write the review prompt to a scratch file, not the repository, from `docs/review-round-prompt.md`: name the candidate commit or range, the governing documents (`AGENTS.md`, `DESIGN.md`, `resolute_au3/`), and the lenses that apply.
3. Run the passes in the dispatcher's order on the one findings record: a section record takes its plan pass first (`--kind plan`, once, before any round), then rounds, then its completion pass (`--kind completion`) after a clean terminal round. The dispatcher refuses a round on a record with no returned plan review, refuses rounds after a clean terminal round, and refuses every pass after a returned completion (its gaps open a new `-repair` record). Every record takes that plan pass first, section or topic alike: the dispatcher refuses a round on any record with no returned plan review. Run the round:

   ```bash
   python scripts/review-dispatch.py --writer <claude|codex|gemini|muse|meta> --writer-model <exact-model-version> --prompt <scratch>/review-prompt.md --record docs/reviews/<topic>.md
   ```

4. Read the review. Verify every finding against the code before acting: fix what is real, and record why anything else is not.
5. Commit fixes as new commits and run another round on the new tip, up to `max_low_rounds` low rounds after round 1; the first clean round (exactly one standalone `HIGHEST: P3` or `HIGHEST: none` declaration, truthfully reporting no standing `P1` or `P2` finding) is the clean terminal round, its findings are filed as follow-up work through `add-todo`, and on every record the completion pass follows it last. Budget exhaustion (`1 + max_low_rounds` rounds) with findings open is operator recovery, never approval. A unit that needs patching three rounds running gets re-thought, not patched again.

## Rules

- The dispatcher's JSON output and the `## Round N` section it appends are the evidence. A verdict with no record is an opinion.
- Exit 1 means the reviewer returned no review (not installed, failed, timed out, empty or blocked), and nothing else runs. That is never an approval: say so, record the outage, and do not ship on it.
- A reviewer that could not reach the work (its sandbox could not read the repository) replies `OVERALL: blocked`, which is recorded as no review. If its sandbox keeps failing, put the diff in the prompt and run the round again.
- The reviewer runs read-only. Never pass it a secret, and never ask it to edit files.
- Change the reviewer only in `.conclave/reviewers.toml` (never past `medium` effort), never by calling a model directly.
