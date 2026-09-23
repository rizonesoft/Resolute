# Decision crossover overlap (D00 T04 §23 item 3)

Candidate: `listview.cpp` (1149 lines, blob `a25d9450292a`) + `listview.h`
(237 lines, blob `ccdcbbcf755e6765`), frozen at `dd2a2b6d`. Class
shipped-code. Rungs: Sol medium (exit 0, 254s, 54761tokens, 10 finds) and
Opus medium (exit 0, 254s, 78449tokens, modelUsage `claude-opus-5`, 18
finds), matched 4-lens prompts (identical bytes, manifest
`PANEL-40b31d483fee92c3`), both check-panel PASS. Matcher: Sol medium,
X/Y-anonymized (X = shorter/Sol, Y = longer/Opus), exit 0, 23s,
9393tokens.

Pairs (5):

- X3-Y7: incompatible WM_COMMAND packing conventions break a single
  parent-dispatch contract (sites 294,462 vs 1035,1069+ overlap fully).
- X4-Y13: row-based navigation and scrolling contradict icon-mode grid
  geometry (312-328, 411, 892, 1077-1089 region).
- X5-Y8: item-count changes force scrollbar visibility instead of deriving
  it from overflow (shared site 207; X5's validation/reconcile remainder
  is unmatched detail within the paired find, not a second defect: one
  site, one call, rung-presented-as-one, so no split).
- X7-Y4: discarding the icon mask and forcing zero alpha opaque breaks
  mask-only icons (sites 139,144,149-159,177 overlap).
- X9-Y3: scrollbar hit-testing ignores visibility and alpha, allowing an
  invisible track to capture clicks (sites 352-357,492,986 overlap).

Solos (18): X1, X2, X6, X8, X10, Y1, Y2, Y5, Y6, Y9, Y10, Y11, Y12, Y14,
Y15, Y16, Y17, Y18.

Adjudications: none. All 5 pairs hold on shared mechanism plus
overlapping sites against the rung outputs. All 18 solos verified
unpaired; nearest near-misses distinguished: X1 (missing negative check)
vs Y2 (stale index after clear) are distinct bounds defects; X2 (allocation
overflow) vs Y4 (transparency logic) share a function but not a mechanism;
X8 (missing key behaviors) vs Y10 (dead check) vs Y12 (ungated arrows)
are three distinct editor defects; X6 (unretrievable edited value) vs Y15
(unreachable rename path) differ in trigger vs retrieval; X10 (animation
claim) vs Y17 (virtualization claim) are different false claims.

Union 23 distinct defects, pairs 5, Jaccard 5/23 = 0.22 (bank carries two
decimals; the join recomputes from pairs/union where exactness matters).
Minimum-activation rule met (2 rungs reporting). No-split rationale: every
find presents one defect mechanism; X5's remainder shares its site and call
with the paired core, and splitting would move Jaccard 0.22 to 0.21,
immaterial to every threshold.

Confinement: Sol ran with cwd pinned to its snapshot plus `-s read-only`;
Opus with cwd pinned plus `--restricted` and no file tools granted.
Prompts carry the candidate inline (reads unnecessary); output scan finds
27 + 66 cites, all inside the frozen files, zero live-tree paths.
Residual: codex exposes no read-deny flag, so Sol-side confinement rests
on cwd plus sandbox plus instruction plus the output scan; OS-level
enforcement files forward with the runner controls.
