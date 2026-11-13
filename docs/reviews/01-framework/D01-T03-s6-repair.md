## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T16:33:39Z
- Candidate: e9fce9e1f0fa7068c76bbf75295a176ff0cb9d51
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: e9fce9e1f0fa7068c76bbf75295a176ff0cb9d51
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 3
- Digest: 5363a394b6e0de2b

HIGHEST: none
PLAN: complete
OVERALL: approve

## Round 1: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T16:35:41Z
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: e9fce9e1f0fa7068c76bbf75295a176ff0cb9d51
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: adversarial
- Lines: 8
- Digest: 1e03af557e4eaf89

### adversarial: needs-attention

1. **P2: The fallback promises log evidence that may not exist.** `docs/framework/notices.md:104` unconditionally says completed steps remain in the log. However, `todo/01-framework/TODO-01-framework-core.md:131` explicitly allows logging to be disabled, and `docs/framework/log-surface.md:143` covers failed writes. **Reproduce:** disable logging, run the specified fixture repair, then fault it with restore-record and report writes refused. `Crash_Steps_Log` directs the user to missing or stale evidence. Specify wording for unavailable or incomplete logs, and promise recorded steps only when their persistence is known.

2. **P3: The report-only failure still permits a nonexistent-report reference.** `docs/framework/notices.md:103` replaces only the third body line when report writing fails. The partial-recovery body at `:74` still uses `Crash_Changed_More`, “and %1 more, listed in the report.” **Reproduce:** extend the specified irreversible-item fixture to eleven irreversible items, successfully flush its restore record, and refuse report creation. The notice simultaneously directs the user to the report and says it could not be saved. This is an edge case, but violates the Repair contract’s explicit record-written/report-failed combination. Specify an overflow presentation that does not depend on a report when none exists.

HIGHEST: P2
OVERALL: needs-attention

## Round 2: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T16:37:00Z
- Effort: low
- Writer model: claude-fable-5-2
- Policy: e9fce9e1f0fa7068c76bbf75295a176ff0cb9d51
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: consistency
- Lines: 6
- Digest: c8f90b670efd4edd

## consistency: approve

No findings in the three Repair items. The candidate matches the shared restart wording, message-layer rules, and conditional recovery text.

HIGHEST: none
OVERALL: approve

## Completion review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T16:38:35Z
- Candidate: 98e5fdae9ee54606c1598402e4b54fc8e14504dc
- Effort: medium
- Writer model: claude-fable-5-2
- Policy: e9fce9e1f0fa7068c76bbf75295a176ff0cb9d51
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lines: 24
- Digest: d3abfc387b2b70e7

Part 1: completeness

Reviewed the three-item Repair contract. This is a notice specification, not a delivered Preferences dialog. It closes the three prior findings; runtime parity and rendered conformance remain the named build sections’ proof obligations.

1. **present**: Elevation timeout has its own localized reason, distinct from Windows refusing startup. The unanswered instance is ended, the original stays usable, and timing excludes the permission prompt. Evidence: `docs/framework/notices.md:49`; named failure check at `:263`.
2. **present**: Failed restore-record writing selects recovery instructions according to whether a report, log, or neither exists. Evidence: `docs/framework/notices.md:75`, `:104`; named checks at `:268`, `:269`, `:270`.
3. **present**: When the restore record exists but the report does not, overflow instructions point to the record. Evidence: `docs/framework/notices.md:74`; eleven-item failure check at `:271`.
4. **present**: Deferred notification supplies localized recovery wording for both fully and partly undoable changes, requiring no additional restart. Evidence: `docs/framework/notices.md:77`; the next-start check at `:275` requires the correct record and successful Undo.
5. **present**: Deferred-notice acknowledgement includes persistence read-back, suppression on the following start, and repeat notification when saving acknowledgement fails. Evidence: `docs/framework/notices.md:108`, `:275`.
6. **present**: Settings remain protected by the existing atomic Save/read-back contract and restart cancellation rules. Evidence: `docs/framework/preferences.md:52`, `:57`; `docs/framework/notices.md:155`, `:157`, `:264`. The repair introduces no competing persistence behavior.
7. **present**: Added strings have language-pack keys and inherit shared keyboard, announcement, copying and sizing behavior. Evidence: `docs/framework/notices.md:220`, `:239`; `docs/framework/standard-window.md:100`.
8. **present**: Failure-sensitive checks are assigned to build owners. Independently verified **34 matrix rows, zero missing failure/check entries**, and lint result **`[]`**. These establish specification coverage, not executed behavioral proof.

Part 2: excellence

Counterpart: AutoIt ReBar behavior, with the new refusal and crash recovery surfaces assessed against `DESIGN.md` §§9–11. The Preferences references do not make this notices-only repair a Preferences implementation.

No concrete remaining shortfall found within the repair scope. The specified outcomes address the prior wording, recovery and unnecessary-restart defects without changing the frozen tools’ effects.

Gap list

Empty.

COMPLETION: complete
