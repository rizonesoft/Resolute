You are rating the severity of review findings against developer tooling (a review-checker suite: git-identity gates, run-record checkers, a findings ledger, a trigger query, review prompt fences) and its plan records. You know nothing about who raised these findings, what happened after, or what decision they feed; rate each defect on its own impact.

Severity scale (closed set, exact words):
- critical: invalidates safety, data integrity, or the stamp.
- major: wrong behavior in code, plan, or record.
- minor: polish or wording, or no surviving defect.

Rating rules:
- Findings marked refuted, withdrawn, or duplicate rate minor (mechanical rule, no judgment).
- Findings marked advisory rate as raised: the note stands as written.
- Plan-stage corrections rate by impact: minor when ordinary execution would have caught them, major when the defect would have survived it.
- Rate the defect's impact, never its fate. The fate word (fixed, filed, advisory, refuted, duplicate) tells you what happened after, not how bad the defect was; use it only for the mechanical rules above. A filed defect is not less severe for being filed, and a fixed defect is not more severe for being fixed.

Findings (B1-B109). Each carries an id, a category, a fate word, and a mechanism description:

B1 [record, refuted]: seven cites over six paths read as one short: the enumeration is reported incomplete against the count.
B2 [consistency, fixed]: exit-code docs omit an exit and a map: the exit line omits one code and its conditions, and one docstring states no exits at all.
B3 [adversarial, fixed]: read-back admits non-integer schemas: boolean and float values pass an equality check meant for exact integers. Hand-crafted attestations only; the writer never emits them.
B4 [consistency, refuted]: a diagnostic class allegedly unregistered and unmirrored, reported as shipping with no registry entry and no guide row.
B5 [integration, duplicate]: OID binding re-resolves instead of pinning persistently, restated: the same no-persistent-pin claim as another finding in the same review. No new claim.
B6 [adversarial, fixed]: fence emission crashes on diffs outside the console code page: output follows the console encoding while the manifest hashes canonical UTF-8, so setup fails before any review runs. Crash-only, nothing approved falsely.
B7 [adversarial, fixed]: unordered word match satisfies reordered citations: bag-of-words matching accepts citations whose words arrive out of order.
B8 [record, fixed]: a Commit item unchecked across two same-section commits: the item stays unchecked while history holds the implementation plus a fix commit.
B9 [integration, fixed]: an item drive missing from the candidate: the transport ships with the item unticked and no quoted large run, leaving the Done-when unmet.
B10 [record, advisory]: a stamp reads ineligible until sign-off cost records: the note stands as written, resolved by the flow it prescribes.
B11 [consistency, filed]: format docstrings miss the report-mode carve-out: both state the structured form flatly while report modes interleave prose or print none.
B12 [adversarial, fixed]: non-textual changes vacuously covered: renames, mode flips, and binary patches carry no text lines, so a text-line leg covers them vacuously.
B13 [consistency, fixed]: a code list restated outside the registry: checker docstrings restate the mapping, so the single-place record is false as written.
B14 [integration, fixed]: an unbounded permutation search hangs the content leg: the order leg tries distinct permutations with no count bound, so a long declaration hangs factorially.
B15 [record, fixed]: a proof quote records the verdict fragment rather than the probe output; quoting the full manifest line verbatim is stronger and costs a sentence.
B16 [record, fixed]: checker prefix and timestamp shape admit nonsense: the checker line needs no PASS prefix and the timestamp needs no real calendar date.
B17 [record, fixed]: a history-silence record names impossible and false consequences: the comment justifies silence with a fatal that cannot happen on its path, and the Done claims a warning the silent case never emits.
B18 [consistency, refuted]: an OID binding re-resolves instead of pinning persistently, reported as silent rebinding under history rewriting.
B19 [record, fixed]: a no-behavior-changed record contradicts the fix it follows: the Done claims no change immediately after recording a behavior change.
B20 [adversarial, fixed]: content consumption never diminishes and surplus rides free: every declared commit compares against the same undiminished counters, so one occurrence covers identical lines in two commits, and surplus lines fail nothing.
B21 [record, fixed]: a cost item struck ahead of its evidence: ticked before the recorded-round evidence it claims exists.
B22 [adversarial, fixed]: alternatively-spelled cites false-fire untracked: raw cited spellings compare against the normalized tracked set, so equivalent spellings of tracked files fire with no fix past respelling.
B23 [integration, fixed]: a stamp-review fix loop never re-emits the attestation: the loop routinely edits the findings file, so the next attempt read-back fails with no step re-emitting.
B24 [record, duplicate]: PASS binding restatement: the same forged-PASS claim as other findings in the same review. No new defect.
B25 [adversarial, filed]: cross-check blind to dropped commits: the contract covers file sets, so a hand-assembled non-contiguous candidate can drop commits silently with sets agreeing.
B26 [record, fixed]: live-green quotes stale at the candidate tip: the Done quotes a finding count the grown ledger no longer reads.
B27 [adversarial, filed]: single-dash tokens parse as paths, not usage: a single-dash token parses as a file path instead of refusing, while the sibling checker refuses it. Pre-existing, fails loud.
B28 [record, fixed]: a design claims pattern reuse the code never performs: the span cut mirrors a parser line rather than the claimed pattern.
B29 [record, fixed]: attestation hashed findings before later edits: attesting right after sign-off binds bytes that plan review and round recording rewrite afterward.
B30 [adversarial, refuted]: an unsigned bundle manifest passes offline verify under consistent rewrite, reported as not the independently tamper-verifiable bundle the title names.
B31 [record, refuted]: an attestation file named before it exists, reported as a record defect.
B32 [record, duplicate]: a bundle delivered unsigned against a signed title, restated: the same unsigned-manifest claim as another finding in the same review. No new claim.
B33 [adversarial, fixed]: an attested pair resolves without proving a chain: membership re-resolves the endpoints but never proves the base ancestral to the head, so a forged pair of arbitrary real commits authorizes unrelated oids.
B34 [integration, fixed]: interim overlap announces unfired cuts: the interim report fires on the similarity half alone, before the value half is measured.
B35 [adversarial, filed]: unanchored identity parse poisoned by paths: a path or title containing the pair field markers makes the parse lift the pair from the file list. Loud failure, never silent acceptance.
B36 [adversarial, refuted]: carried transcripts not replayed against their inputs, reported as letting a fabricated PASS verify without replay.
B37 [record, refuted]: a back-reference to another section sits outside the fenced candidate, reported as breaking review completeness.
B38 [consistency, refuted]: an item matcher disagrees with parsed checklist state, reported as a mirror break between the rule and the parser.
B39 [adversarial, fixed]: unknown flags and surplus positionals slip past usage refusal: unrecognized switches parse as paths and surplus positionals succeed silently, instead of the usage refusal the contract demands.
B40 [record, fixed]: attestation missing beside the findings file at the time of the finding; the flow emits it after the final round.
B41 [adversarial, refuted]: a hostile title carrying a commits claim would diverge the manifest parsers, reported as a parser-disagreement spoof.
B42 [adversarial, fixed]: a blocking stamp transcript verifies as a passing record: single-PASS-led matching admits the blocking output, so a blocking transcript emits success and verifies.
B43 [integration, fixed]: untracked findings pass the staged proof while anchors read the worktree: the cleanliness check ignores untracked paths and the anchor checker resolves against worktree bytes, so a never-staged file ships without its proof.
B44 [integration, fixed]: stamp read-back verifies the disk file, not the staged blob: a valid-but-different blob on disk passes while the committed staged blob goes unverified.
B45 [record, fixed]: candidate-tip suite counts stale: the run file and findings figures disagree after new legs land mid-review.
B46 [record, fixed]: a record omits the head record commit: the range closes early while the fenced head runs further.
B47 [record, fixed]: a single-place record false while docstrings duplicate: the Done claims the registry lives once while docstrings duplicate it.
B48 [record, fixed]: the attested tree resolves from the checkout instead of the candidate, self-contradictory once the checkout advances past the candidate.
B49 [correctness, fixed]: cross-check rejects valid rename candidates: the manifest records both rename sides while the default file listing reports only the destination, so every rename diverges.
B50 [adversarial, fixed]: self-test plus format slips past usage refusal: staged parsing lets a flag combination run the suite instead of refusing, while the Done claims the gate tightened.
B51 [integration, fixed]: holding patterns unwitnessed against checker wording: patterns duplicate reason strings with hand-written legs, so a reason drift would break the emit while every suite stays green.
B52 [adversarial, fixed]: mistitled diffs bypass identity enforcement: the title match is case-sensitive, so a differently-cased title skips the base and head demand.
B53 [consistency, filed]: the author-facing guide lacks the struck-item deferral spec: fatal requirements exist with code comments as the only spec.
B54 [integration, fixed]: stamp failover checks stale bytes: the failover command writes nowhere, so the checker reads the stale failed attempt bytes while the fresh sentence survives only on the terminal.
B55 [record, fixed]: a candidate table understates again: the table omits record commits inside the reviewed range.
B56 [integration, duplicate]: stamp receipt eyeballed, not checked: the same gap as another finding in the same review. No new defect.
B57 [consistency, fixed]: a round-suffix case split plus ambiguous recorded duplicates: headings parse case-insensitively while the round suffix parses case-sensitively, so an all-caps heading claims its position; duplicated round numbers match tags ambiguously.
B58 [consistency, fixed]: range-stamp coverage trips the citation ban: the coverage strip handles only single-section coverage, so a legal range stamp the graph accepts fails validation on legal grammar.
B59 [adversarial, duplicate]: checker binding restatement: the same hand-written-PASS claim as other findings in the same review. No new defect.
B60 [record, fixed]: attestation text fields carry no semantics: verdict, checker line, and timestamp accepted without shape, so session typos attest.
B61 [record, duplicate]: a sizing observation stale at the live assembly size: answered at another finding in the same review whose fix replaces the cap and its rationale.
B62 [correctness, fixed]: an order pin crashes on renamed headers: a bare index lookup traceback-crashes the suite instead of failing the pin.
B63 [adversarial, duplicate]: checker evidence unbound, restated: the same unbound-PASS claim as another finding in the same review. No new defect.
B64 [adversarial, fixed]: untracked cites pass anchors: a cite to a file present on disk but never added passes existence and ships without it; outside-repo paths fail open as evidence.
B65 [integration, fixed]: filed follow-up items lack their relation to the originating finding: items state a dependency the graph never carries.
B66 [record, fixed]: an exit-2 record false for unknown switches: the Done claims every usage error pins to exit 2 while unknown switches fall through elsewhere.
B67 [integration, fixed]: Live proof postdates the attestation: proof and round records are written after the attestation position, so read-back fails on the finalized file and no step re-emits.
B68 [consistency, filed]: a refusal docstring overclaims the live mechanism: claims key order is the live property while output sorting makes membership what fires. Imprecise, not false.
B69 [adversarial, fixed]: manifest lookalike filenames: literal whitespace lets a crafted filename parse as manifest metadata.
B70 [integration, fixed]: an anchor checker never invoked: the checker shipped without a call site in the procedure.
B71 [adversarial, fixed]: check-export flags slip past usage refusal: the strictness covers one path but not the export-check mode, whose argument falls through instead of refusing.
B72 [adversarial, filed]: multiset coverage ignores order and position: a rearranged patch with identical multisets passes while the reviewed content differs.
B73 [adversarial, fixed]: cost telemetry coerced instead of rejected: boolean, float, and numeric-string values convert to false costs instead of failing.
B74 [adversarial, fixed]: any-pass owners let a defective owner ride a valid one: one resolving owner reference validates the deferral while garbage references accumulate silently beside it.
B75 [consistency, fixed]: a runner model claim unfalsifiable: the runner names no model on its output, so the model pin is trusted and no mismatch can fire.
B76 [integration, filed]: oversized assemblies with voided members have no legal path: past the declaration bound the refusal advises fencing the range, but a range re-admits the voided commits declarations exist to exclude.
B77 [record, refuted]: the residual agreement is agreement on a false claim: combined diffs stand as the sole residual while forged blocks are claimed mishandled, reported as a true-claim failure.
B78 [record, filed]: a design says three shapes and enumerates four: the count went stale when a new exemption joined.
B79 [record, fixed]: attestation identity floats free of the manifest: base and head written without comparison, so a read-back could claim a candidate the manifest never covered.
B80 [record, refuted]: a sweep contradiction across two items records: one records a clean sweep while another records reds in the same sweep, reported as an unsatisfied clean rerun.
B81 [record, fixed]: a candidate table omits the latest fix commit: the record table ends early while the reviewed range runs further.
B82 [consistency, fixed]: a schema-keys constant ships unread: defined and never read while both suites spell the literal, so a drifted key fails nowhere central.
B83 [consistency, fixed]: a findings-file citation rule undocumented in the procedure: the procedure states the rule as stamp-only while the validator also scans the findings file and attestation.
B84 [adversarial, fixed]: a count cap sits at the live assembly size: the refusal trips one past the fenced size, so one more fix commit would break the flow, and its range advice fails voided spans.
B85 [integration, fixed]: anchors read non-stamp files unverified: the stamp-set proof covers only stamp files, but anchors resolve cited paths in any file from worktree bytes.
B86 [record, fixed]: a provenance line without finding ID, plus a misread reference: the filing provenance omits its finding key, and a finding reference in another item is misread as a disposition claim.
B87 [adversarial, fixed]: a bank newest reads last-listed, not newest: taking the last line lets a hand-appended out-of-order line pose as newest, so the freshness leg reads fresh on overdue calibration.
B88 [consistency, fixed]: stamp-time read-back claimed but not wired: the record claims read-back at stamp time while the flow reads back only at emit, so an altered file survives to the stamp review.
B89 [adversarial, refuted]: pasted diff lines forge the file list: a forged block yields extra files in the manifest, reported as manifest-body mismatch letting content leak into the file list.
B90 [adversarial, fixed]: a bare hold verdict loops with no figure: the verdict without its closing period reads as a blocking naming with nothing to fix, looping fix-restage-rerun with no escape.
B91 [consistency, fixed]: a describe docstring names the wrong exception: states one exception while the raise and both suites pin another. One-word doc fix.
B92 [adversarial, fixed]: substring citation satisfies off unrelated items: containment lets a short citation match inside a longer unrelated sentence.
B93 [consistency, fixed]: a docstring omits the residual sentence its comment states; comment and docstring disagree on the residual.
B94 [record, fixed]: a round record missing: the findings file carries no section for a round whose fixes the Dones cite.
B95 [integration, fixed]: a content leg unwired into the procedure flow: the check never runs because the procedure passes neither the declaration nor the body.
B96 [integration, fixed]: a deferral block does not stop at headers: sub-headers fail to end the span, so references below them misattribute to the block.
B97 [adversarial, fixed]: legacy skips bypass binding for new stamps: hashless cites skip verification by the legacy rule, so a newly authored stamp could dodge binding with the hashless shape.
B98 [consistency, filed]: stamp receipt demanded but never verified: no stamp-output checker exists, so the procedural eye-check stands alone.
B99 [record, fixed]: a completion record contradicts the filed residual: the Done reads complete while a follow-up item admits the forged-evidence residual.
B100 [record, fixed]: a stale line-count quote again: second occurrence of the drifting file-size quote.
B101 [integration, fixed]: spaced cites skip silently, and a sweep finds stale cites in shipped sections: the anchor patterns exclude spaces, so spaced cites never check.
B102 [record, fixed]: a stale line-count quote: the Done quotes a file size the file no longer measures.
B103 [adversarial, fixed]: staged-vs-disk findings at read-back: read-back hashes the disk file while the commit ships the staged blob.
B104 [integration, fixed]: unreadable exports ignore the structured form: the missing-file branch always emits text, breaking the promise that gate modes print exactly one structured document.
B105 [record, fixed]: a Done note claims comment, docstring, and probe quote agree while the docstring lacks the clause.
B106 [adversarial, fixed]: cross-check range floats free of the manifest pair: a swapped or foreign range with the same file set passes silently, since swapped endpoints list identical files.
B107 [consistency, fixed]: an in-flight suite total survives against the delta discipline: an absolute total the discipline forbids, stale.
B108 [adversarial, filed]: checker evidence unbound to runner output: a one-line PASS file hashes into a valid-looking attestation without proving the checker ran.
B109 [consistency, fixed]: a dead post-cutoff cite fails twice for one defect: a dead hashless cite fails two verdicts against the one-defect-one-fault discipline.

Return exactly 109 lines, one per finding, in B1-B109 order, each line opening `B<n>: <critical|major|minor> -- ` followed by a one-clause reason naming the impacted artifact. No other text.
