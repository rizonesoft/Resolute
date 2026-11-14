"""Bind Codex Stop events to the launcher-owned Resolute run."""
import json
import os
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))
import run_guard


def main():
    session = os.environ.get("RESOLUTE_RUN_SESSION")
    if not session:
        print("{}")
        return
    try:
        raw = sys.stdin.read(2_000_001)
        if len(raw) > 2_000_000:
            raise ValueError("hook payload too large")
        data = json.loads(raw)
        data["session_id"] = session
        print(run_guard.hook(json.dumps(data)) or "{}")
    except Exception as error:
        print(f"Codex run guard: {error}", file=sys.stderr)
        print("{}")


if __name__ == "__main__":
    main()
