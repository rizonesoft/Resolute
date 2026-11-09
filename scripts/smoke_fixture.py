#!/usr/bin/env python3
"""Deliberately broken tools for the smoke-run drills (D07 T01 S4).

Modes:
  nowindow  -- runs without ever showing a window (broken at start)
  hung      -- shows a window that ignores close requests (fails exit)
  deaf      -- shows a window with no About surface (fails about)
  normal    -- shows a plain window that closes on request

Stdlib only, like every TODO tool. Used through
`python scripts/smoke-run.py --drill`, never shipped.
"""

import sys
import time


def main() -> int:
    mode = sys.argv[1] if len(sys.argv) > 1 else "normal"
    if mode == "nowindow":
        time.sleep(30)
        return 0
    import tkinter

    root = tkinter.Tk()
    root.title(f"SmokeFixture-{mode}")
    root.geometry("320x200")
    tkinter.Label(root, text=f"smoke fixture: {mode}").pack(padx=20, pady=20)
    if mode == "hung":
        root.protocol("WM_DELETE_WINDOW", lambda: None)
    root.mainloop()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
