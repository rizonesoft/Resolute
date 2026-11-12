#!/usr/bin/env python3
"""Render a campaign launcher's icon: the suite icon with its runner's badge in the corner.

    python scripts/campaign-icon.py <target.ico> <badge colour> [<mark.svg>]

scripts/start-unattended-run.ps1 -InstallShortcut runs this once for each Desktop shortcut. The suite icon comes
from the committed resources/icons/Resolute.ico, each size from the smallest frame that is at least that large. The
badge is a circle in the runner's colour with a white outline, bottom right: the shape the other repositories'
campaign launchers on the operator's machine carry. A runner's mark (the Claude symbol, the Gemini sparkle) is
another company's trademark, so none is kept in this repository: when the optional SVG file exists on this machine
it is drawn in white inside the badge from 32 pixels up, and without it the badge carries its colour alone. The icon
is written beside the shortcut's other per-machine files, never into the repository.

Needs Pillow, and resvg_py for a mark. Neither is a dependency of the tree: this renders one machine's shortcut
icon, and without them the launcher gives the shortcut the plain suite icon and says so.
"""

import io
import os
import re
import sys
from pathlib import Path

SIZES = (16, 20, 24, 32, 40, 48, 64, 128, 256)
SOURCE = Path(__file__).resolve().parents[1] / "resources" / "icons" / "Resolute.ico"
MARK_FROM = 32  # below this the mark is a smudge: the colour alone tells the runners apart
OVERSAMPLE = 4  # the badge is drawn large and reduced, so its edge is smooth at every size


def suite_tile(size):
    """The suite icon at `size` pixels, from the smallest committed frame that is at least that large."""
    from PIL import Image
    from PIL.IcoImagePlugin import IcoImageFile

    with IcoImageFile(SOURCE) as icon:
        frames = sorted(side for side, _ in icon.info["sizes"])
        source = next((side for side in frames if side >= size), frames[-1])
        tile = icon.ico.getimage((source, source)).convert("RGBA")
    return tile if tile.size == (size, size) else tile.resize((size, size), Image.Resampling.LANCZOS)


def mark_image(mark, side):
    """The mark as a white image `side` pixels square, or None when no mark file is on this machine."""
    if not mark or not Path(mark).is_file():
        return None
    import resvg_py
    from PIL import Image

    data = bytes(resvg_py.svg_to_bytes(svg_path=str(mark), width=side, height=side))
    image = Image.open(io.BytesIO(data)).convert("RGBA")
    white = Image.new("RGBA", image.size, (255, 255, 255, 0))
    white.putalpha(image.getchannel("A"))  # whatever colour the file uses, the badge shows it in white
    return white


def frame(size, fill, mark):
    from PIL import Image, ImageDraw

    tile = suite_tile(size)
    full = size * OVERSAMPLE
    big = Image.new("RGBA", (full, full), (0, 0, 0, 0))
    draw = ImageDraw.Draw(big)
    radius = round(full * 0.24)
    centre = full - radius - max(1, round(full * 0.01))
    ring = max(OVERSAMPLE, round(full * 0.025))
    draw.ellipse((centre - radius, centre - radius, centre + radius, centre + radius), fill="white")
    inner = radius - ring
    draw.ellipse((centre - inner, centre - inner, centre + inner, centre + inner), fill=fill)
    if size >= MARK_FROM:
        side = round(radius * 1.15)
        logo = mark_image(mark, side)
        if logo:
            big.alpha_composite(logo, (centre - side // 2, centre - side // 2))
    tile.alpha_composite(big.resize((size, size), Image.Resampling.LANCZOS))
    return tile


def main(argv):
    if len(argv) not in (2, 3) or not re.fullmatch(r"#[0-9A-Fa-f]{6}", argv[1]):
        print("usage: python scripts/campaign-icon.py <target.ico> <badge colour> [<mark.svg>]", file=sys.stderr)
        return 2
    target, fill, mark = argv[0], argv[1], argv[2] if len(argv) == 3 else ""
    try:
        frames = [frame(size, fill, mark) for size in SIZES]
    except ImportError as error:
        print(f"not rendered: {error}", file=sys.stderr)
        return 1
    partial = target + ".tmp"
    frames[-1].save(partial, format="ICO", sizes=[(size, size) for size in SIZES], append_images=frames[:-1])
    os.replace(partial, target)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
