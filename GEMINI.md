# GEMINI.md

Follow [AGENTS.md](./AGENTS.md). This file holds only what is specific to Google Antigravity (`agy`).

- Skills live in `.agents/skills/<name>/` and are mirrored as real files in `.claude/skills/<name>/` and `.codex/skills/<name>/`. Change all three together.
- Use `.agents/skills/local-tool-safety` before local tool, Windows/WSL, connector, mail, cloud, SQL, or outbound work.
- Rules live in `.agents/rules/`.
- Subagents and orchestration: Antigravity uses native `Orchestrator (Carbon)` (`gemini-pro-orchestrator`, which manages effort internally and rejects `--effort`), planning automatically on Carbon (`<plan_execute_protocol>`), handing execution to Hydrogen via `exit_plan_mode`, and delegating to built-in subagents (`self`, `research`, `image-generator`) via `invoke_subagent` without custom `.agents/agents/` wrappers.
