import re, sys, pathlib
path, sections, target = pathlib.Path(sys.argv[1]), set(sys.argv[2].split(',')), sys.argv[3]
marker = f"> **Moved:** 2026-11-15 to docs/plans/2026-11-15-app-split.md (operator instruction); worked in the `{target}` repository (`D:\\Resolute_Bin\\{target.split('/')[1]}`) by its own plan."
out, cur, n = [], None, 0
for line in path.read_text(encoding='utf-8').split('\n'):
    m = re.match(r'^## (\d+)\. ', line)
    if m or re.match(r'^## ', line):
        cur = m.group(1) if m else None
        out.append(line)
        if cur in sections:
            out += ['', marker]
        continue
    if cur in sections:
        m2 = re.match(r'^- \[ \] (Commit: )?(.*)$', line)
        if m2 and '~~' not in line:
            line = f"- [ ] {m2.group(1) or ''}~~{m2.group(2)}~~ -> `{target}`"; n += 1
        elif line.startswith('**Test checkpoint:**'):
            line = f"**Test checkpoint:** Moved with the section. The `{target}` repository's plan carries it."
    out.append(line)
path.write_text('\n'.join(out), encoding='utf-8', newline='\n')
print(path.name, 'struck', n)
