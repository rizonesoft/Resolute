# Antigravity Output and Safety Rule

- Bound every shell command output (`Select-Object -First` on Windows, `head` or `tail` on WSL, filtered test cases) and redirect full logs to scratch, never the repository: `R:\scratch` on Windows, `/mnt/r/scratch` on WSL (the same folder), or the session scratchpad when one is given; `build/` holds derived project output.
- Treat `git status` as a concurrency lock: never write over unfamiliar uncommitted changes from another session without asking the user first.
- Never use em dashes or en dashes anywhere: prose, code, comments, commit messages and generated files. Use a comma, colon, parentheses or a full stop. Write one line per Markdown paragraph and list item.
- Use atomic temporary-file-then-replace writes for all persistent data files.
- Author and execute TODO work as small, single-responsibility sections with granular micro-step checklist items (`Done when:` and backticked path/symbol per item) toward a 100% complete development plan with zero silent drops or unowned controls.
- End code change reports with a `Layer:` line identifying the owning module.
