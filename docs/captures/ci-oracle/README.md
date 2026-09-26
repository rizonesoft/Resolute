# CI oracle captures

Durable evidence for the CI read-back's decoder and re-run printout (D00 T04 §39).
Each drill ran once on a disposable `drill/**` branch that was then deleted, so the only lasting record is here.
`scripts/review_prompt.py --self-test` reads these files: the expected outputs come from GitHub's own logs, never from the author.

| Drill | Workflow | Run | Runner | Proves |
| --- | --- | --- | --- | --- |
| D00 T04 §35 scalar drill | `scalar-echo.yml` | 36175449390 | ubuntu-24.04, image 20260920.314.1, runner 2.337.0 | how GitHub decodes each YAML scalar form of `run:` |
| D00 T04 §37 context drill | `context-echo.yml` | 36191008012 | ubuntu-24.04, image 20260920.314.1, runner 2.337.0 | bash default and explicit templates, env, and working directory |
| D00 T04 §37 sh drill | `context-echo-sh.yml` | 36194988672 | ubuntu-24.04, image 20260920.314.1, runner 2.337.0 | the explicit `sh` template |
| D00 T04 §39 Windows drill | `context-echo-win.yml` | 36211341983 | windows-2025-vs2026, image 20260922.246.2, runner 2.337.0 | the `pwsh`, `powershell`, and `cmd` templates, and the `Stop` error preference GitHub sets |

Files per drill:

- `<workflow>.yml`: the workflow file at the drill's head commit, fetched from GitHub by commit.
- `run-<run id>.json`: the run's record (`gh run view --json`): id, head sha, branch, event, conclusion, attempt.
- `log-<run id>.txt`: the run's full log (`gh run view --log`). Each step's output follows its `##[endgroup]`; its `shell:` line is the template GitHub ran.

`oracle.json` lists the drills. A new drill adds its three files and one entry there.
