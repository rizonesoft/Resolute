# Review brief: shipped-code crossover candidate (D00 T04 §23 item 3)

Target: `listview.cpp` (1149 lines, blob `a25d9450292a`) plus its paired
`listview.h` (237 lines, blob `ccdcbbcf755e6765`), frozen from the tree at
commit `dd2a2b6d`. Both files are fenced inline below; the snapshot
directories carry the same bytes for reference. A Win32 Direct2D list-view
UI control: window procedure, item model, scrolling, selection, rendering,
DPI handling. The header carries the declarations; review the code as
presented and do not assume unseen files.

Shape: one verdict per lens (approve / needs-attention / advisory):
adversarial (spoofs, hostile input, bypasses), consistency (internal
contradictions, naming, convention breaks), integration (broken callers,
misused APIs, violated contracts with the header or the platform), record
(comment-code disagreement, false claims in comments). Numbered findings
cite `<filename>:<line>` with line numbers counting within that file's
fenced body starting at 1.

Scope: defects in the candidate as presented. Shared UI-library code ships
to every tool, so a wrong behavior here lands everywhere; rate what you
see, not what might surround it.
