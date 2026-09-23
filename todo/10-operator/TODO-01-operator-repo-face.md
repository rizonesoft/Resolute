---
schema_version: 1
id: operator-repo-face
domain: 10-operator
status: draft
title: "TODO-01 -- Operator Repo Face (Manual)"
depends_on: []
track: N0
---

# TODO-01 -- Operator Repo Face (Manual)

> **Goal:** The repository's GitHub face is complete and human-verified: the About bar, topics, and social preview are set, branch protection guards the real checks, a cold reader has run the quick start verbatim, and a demo clip shows the app moving. Every click leaves proof in the repo.

> [!IMPORTANT]
> **Current state:** The repo lives at `https://github.com/rizonesoft/Resolute` on the `master` branch. The agent half of the face lands in `D00 T05`: screenshots, the full-structure README, and the setup-path CI lane. Nothing in this file can start until its `D00 T05` dependency ships, and nothing in it runs under an agent runner. Proof screenshots land under `docs/captures/setup-proof/`, the repo's standing capture directory.

<!-- claim: exists .github/workflows/plan.yml -->

## Inputs

- [`D00 T05 §2`](../00-workspace/TODO-05-repo-face.md) -- the README whose one-liner §1 quotes and whose quick start §3 runs
- [`D00 T05 §3`](../00-workspace/TODO-05-repo-face.md) -- the CI lane whose live check names §2 collects
- [`docs/captures/`](../../docs/captures/) -- exists; §1, §2, and §4 commit proof beneath it

## Outcome

- The repo About bar, topics, and social preview are set and screenshotted into the repo.
- Branch protection requires the real check names with force-push blocked, proven by the rule screenshot.
- A cold reader has run the quick start verbatim, and every surprise is an issue or a dated no-gaps record.
- A 15-to-30-second demo clip under 10 MB is embedded under the README hero line.

**Adjacency:** list=not-applicable (settings pages hold no records a user browses); document=applicable @ D10 T01 §4; settings=applicable @ D10 T01 §2; reporting=not-applicable (CI verdicts belong to D00 T05 §3; this file adds no report); notifications=not-applicable (no notify channel is configured); permissions=applicable @ D10 T01 §2; audit=applicable @ D10 T01 §1; exchange=applicable @ D10 T01 §3; reverse=not-applicable (GitHub clicks have no undo; each section records its before-state in proof)

**Adjacency rationale:** The manual half is settings and permissions work with an audit trail: the branch rule anchors both on §2 because it is a repo setting that restricts who can push what. Proof screenshots are the only audit this work leaves, anchored on §1 where the first proof lands. The clip is published documentation on §4, and cold-reader surprises filed as issues are the contributor exchange on §3. Reporting and notifications stay not-applicable because the file configures no channel, and reverse because a misclicked setting is re-clicked, not undone.

## Implementation Order

| Order | Section | Deliverable | Depends On | Status |
| :---: | :-----: | ----------- | ---------- | :----: |
|   1   |   §1    | About bar, topics, social preview | D00 T05 §2 |  [ ]   |
|   2   |   §2    | Branch protection with required checks | D00 T05 §3 |  [ ]   |
|   3   |   §3    | Cold-reader taste pass | D00 T05 §2 |  [ ]   |
|   4   |   §4    | Demo clip recorded and embedded | §1 |  [ ]   |

---

## 1. About Bar, Topics, Social Preview

> **OPERATOR-ONLY:** no agent runner takes this row; the operator works it from this file with the click paths below, starting from `https://github.com/rizonesoft/Resolute`.

The repo face quotes the README: the description is the `D00 T05 §2` one-liner, topics name what the suite is, and the social preview shows the app. Proof comes back into the repo because Settings pages are not public evidence on their own.

- [ ] Set the description and topics. Done when: from the repo page, the About gear opens the dialog, the description matches the README one-liner word for word, and the topic list is recorded in the proof note. Cheaper substitute that fails the checkpoint: paraphrasing the one-liner, which lets the bar and the README drift apart from day one.
- [ ] Upload the social preview hero. Done when: from Settings, Pages-adjacent Social preview under General, the `D00 T05 §1` hero uploads and renders on the repo page.
- [ ] Commit proof and verify through the public API. Done when: a screenshot of the repo face lands under `docs/captures/setup-proof/`, and `gh api repos/rizonesoft/Resolute` shows the description and topics, quoted into the proof note.
- [ ] Commit: `"docs: repo About bar, topics, and social preview proof"`

**Test checkpoint:** The proof screenshot shows the description, topics, and hero; the API output quoted beside it agrees word for word. Cheaper substitute that fails the checkpoint: the operator's memory that the clicks happened, which no later reader can check.

-> XREF: D00 T05 §2 -- the README this About bar quotes
-> XREF: D10 T01 §4 -- the clip embedded under this hero

## 2. Branch Protection With Required Checks

> **OPERATOR-ONLY:** no agent runner takes this row; the operator works it from this file with the click paths below, starting from `https://github.com/rizonesoft/Resolute`.

The `master` branch requires the real checks before merge, with force-push blocked. Check names are collected from a live Actions run, never guessed, because a guessed name guards nothing. Proof is the rule screenshot since rules are not public.

- [ ] Collect the check names from a live run. Done when: from Actions, the latest setup-path run's check names are recorded exactly as shown, and the plan-gates names beside them.
- [ ] Set the rule requiring pull requests plus the checks. Done when: from Settings, Branches, Add rule for `master`, require-a-pull-request is on and every collected check name is required, with no guessed name in the list. Cheaper substitute that fails the checkpoint: typing check names from memory, which silently guards a check that never runs.
- [ ] Block force-push and prove the rule. Done when: force-push is blocked on the rule, and a screenshot of the finished rule lands under `docs/captures/setup-proof/`.
- [ ] Commit: `"docs: branch protection rule proof"`

**Test checkpoint:** The rule screenshot shows `master`, the required checks matching the live-run names exactly, and force-push blocked. Cheaper substitute that fails the checkpoint: a rule whose names were guessed, which passes review and protects nothing.

-> XREF: D00 T05 §3 -- the workflow this rule guards

## 3. Cold-Reader Taste Pass

> **OPERATOR-ONLY:** no agent runner takes this row; the operator works it with fresh eyes and no repo knowledge beyond the README.

A clean machine follows the README quick start verbatim, and every surprise becomes an issue or the pass records an explicit dated no-gaps line. The pass assumes zero GitHub knowledge of the repo: the README is the whole map.

- [ ] Run the quick start verbatim on a clean machine. Done when: a machine that has never had the suite follows only the README from clone to green build, and every command that departs from the text is logged. Cheaper substitute that fails the checkpoint: running it on the development machine, where installed tools hide the missing steps.
- [ ] File every surprise or record no gaps. Done when: each surprise is a GitHub issue with its README line attached, or the proof note carries an explicit dated no-gaps line naming the machine and the commit.
- [ ] Commit: `"docs: cold-reader pass findings or no-gaps record"`

**Test checkpoint:** The issues (or the dated no-gaps line) exist and each names the README line it came from. Cheaper substitute that fails the checkpoint: a verbal "looks fine", which files nothing and fixes nothing.

-> XREF: D00 T05 §2 -- the README this pass proofs

## 4. Demo Clip Recorded and Embedded

> **OPERATOR-ONLY:** no agent runner takes this row; the operator records, uploads, and embeds from this file.

A 15-to-30-second clip under 10 MB shows the app moving, recorded with ScreenToGif (free, Windows-native), uploaded to the repo, and embedded under the README hero line. The agent verification afterward checks the file plus the reference, not the taste.

- [ ] Install the recorder. Done when: ScreenToGif installs on the recording host and its version is recorded in the proof note.
- [ ] Record the clip. Done when: 15 to 30 seconds, under 10 MB, showing the built app performing one real task end to end. Cheaper substitute that fails the checkpoint: a slideshow of the §1 screenshots, which shows nothing moving.
- [ ] Upload and embed under the hero line. Done when: the clip is committed under `docs/captures/`, the README embeds it directly beneath the hero, and the page renders it.
- [ ] Verify file plus reference. Done when: the committed file plays, the README reference resolves to it, and both are quoted in the proof note.
- [ ] Commit: `"docs: demo clip embedded under the hero"`

**Test checkpoint:** The clip plays from the README, runs 15 to 30 seconds, stays under 10 MB, and the proof note quotes file plus reference. Cheaper substitute that fails the checkpoint: an unembedded clip file, which exists and is seen by no one.

-> XREF: D10 T01 §1 -- the About page hosting this clip

## Verification

- [ ] The proof screenshots and the no-gaps-or-issues record exist under `docs/captures/setup-proof/`
- [ ] The demo clip plays from the README under the hero line
- [ ] The branch-rule screenshot names the live check names exactly
- [ ] `python scripts/todo-graph.py validate` clean
