## Plan review: astra (`gpt-6-astra` via `codex`)

- Writer: claude
- Run: 2026-11-13T13:53:20Z
- Candidate: 4757a8427588914ab527db300386e82361535eee
- Effort: medium
- Writer model: claude-opus-5-5
- Policy: 4757a8427588914ab527db300386e82361535eee
- Execution: returned
- Attempt reviewer: astra
- Attempt model: gpt-6-astra
- Attempt cli: codex
- Lenses: plan
- Lines: 7
- Digest: 0e31c7699bdfc222

1. **P2, line 86:** Disabling both log items when the file is absent conflicts with `docs/framework/standard-window.md:58`, which enables “Open log folder” whenever the folder exists. Deleting a log normally leaves its folder intact. Specify and check independent availability: disable file opening, keep folder opening enabled when its directory exists, and open that directory without selecting the missing file. Give a missing directory its own accurate disabled reason.

2. **P2, line 87:** The heading repair changes placement but requires only updating the regions table. The existing density check verifies heights and clipping, so incorrect icon offsets or title spacing could still pass. Require that same matrix check to measure the icon’s left/top offsets and its gap to the title against `SpacingMD`, `SpacingLG` and `SpacingXL` at the respective densities.

HIGHEST: P2
PLAN: gaps
OVERALL: needs-attention

## Writer note: plan findings

- Planned: independent availability for the two log items, a missing folder's own reason, and checks for a first run, a deleted log and a missing folder (P2), in the corrected first Repair 2 item.
- Planned: the density check measures the heading's icon offsets and title gap (P2), in the corrected second Repair 2 item.
