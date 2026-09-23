You are rating the severity of review findings against developer tooling (a review-checker suite: git-identity gates, run-record checkers, a findings ledger) and its plan records. You know nothing about who raised these findings, what happened after, or what decision they feed; rate each defect on its own impact.

Severity scale (closed set, exact words):
- critical: invalidates safety, data integrity, or the stamp.
- major: wrong behavior in code, plan, or record.
- minor: polish or wording, or no surviving defect.

Rating rules:
- Findings marked refuted, withdrawn, or duplicate rate minor (mechanical rule, no judgment).
- Findings marked cleared rate as raised, like fixed.
- Plan-stage corrections rate by impact: minor when ordinary execution would have caught them, major when the defect would have survived it.
- Rate the defect's impact, never its fate. The fate word (fixed, filed, cleared, refuted, duplicate) tells you what happened after, not how bad the defect was; use it only for the mechanical rules above. A filed defect is not less severe for being filed, and a fixed defect is not more severe for being fixed.

Findings (B1-B22). Each carries an id, a category, a fate word, and a mechanism description:

B1 [adversarial, fixed]: candidate-identity validation proved the compared objects are git objects, not commits; a tree object passes as the compared head with its own tree, so a forged tree-as-head manifest passes the commit-resolution gate.
B2 [correctness, fixed]: a content binding covers the runs file while finding dispositions float from the live ledger; the binding does not cover what the analysis consumes.
B3 [record, filed]: reconstructed figures cite a run file that is untracked mid-run; the values have no committed source anywhere in the tree.
B4 [adversarial, fixed]: replacement refs spoof the commit-type gate: a replacement ref pointing a tree at a commit makes the unflagged type check read commit.
B5 [record, fixed]: a completion note claims byte-identical output while recording that timestamp lines differ.
B6 [correctness, fixed]: an export checker blesses fabricated bindings on syntax alone, without checking that the binding resolves.
B7 [adversarial, fixed]: seventeen shell identity calls (push-binding comparisons, fence assembly, attestation tree reads) resolve through replacement refs, enabling consistent-shift spoofs of the compared parent, tree, and content.
B8 [consistency, filed]: a shipped section's record clause states a rule is unenforced after a later section enforces it; the present-tense description is stale.
B9 [adversarial, fixed]: unflagged content reads plus a name-set-only comparison: a content substitution on unchanged paths passes the agreement check, so the reviewer reviews a diff that is not the candidate's.
B10 [correctness, fixed]: resolvers crash with a traceback instead of reporting when the version-control binary fails.
B11 [adversarial, filed]: the stamp patch is produced by an unflagged diff that resolves through replacement; the fence and cross-check consume the spoofed patch and the name-set comparison is blind to content substitution, so the stamp reviewer reads a patch that is not the staged change.
B12 [record, refuted]: a ship message appends a section-ref parenthetical to the quoted message core; reported as not equal to the required exact string.
B13 [consistency, fixed]: a self-test scratch repository calls itself hermetic but inherits global templates and hooks that can mutate or fail the fixture.
B14 [record, fixed]: skill wording calls unmeasured cost untimed and claims unpersisted values complete.
B15 [record, duplicate]: evidence quotes bare counts without binding them to the producing commit; the same pattern as a previously decided finding.
B16 [record, fixed]: run evidence quotes abbreviated object ids with literal ellipsis instead of full ids; reconstructed summaries presented as quoted output.
B17 [record, fixed]: a proof quotes values that no committed line carries.
B18 [record, fixed]: a diagnostic abbreviates object ids; asserting that prefixes were quoted does not quote them.
B19 [record, fixed]: a checkpoint leg is unverifiable from the tree until the stamp writes the block it quotes.
B20 [record, fixed]: a recorded scope sentence overstates a fix (claims every call site when only some were changed).
B21 [record, fixed]: a recorded rationale asserts protection that does not exist, with no driven run cited.
B22 [consistency, filed]: a coverage sentence claims complete flag coverage while several instructed reads stay unflagged.

Return exactly 22 lines, one per finding, in B1-B22 order, each line opening `B<n>: <critical|major|minor> -- ` followed by a one-clause reason naming the impacted artifact. No other text.
