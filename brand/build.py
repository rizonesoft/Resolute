#!/usr/bin/env python3
"""Build the Resolute launcher's brand assets: the icon, its renders, the wordmarks and both banners.

    python brand/build.py            write every asset under brand/ and the application icon under resources/icons/
    python brand/build.py --check    exit 1 when a tracked asset differs from what this script builds

The icon was chosen by the operator on 2026-11-16: a gold spanner crossed under a steel screwdriver with a blue handle,
drawn new for the launcher after the tools left for their own repositories. It is the one icon of the suite with
gradients: the tools' icons are flat and two-tone, and the launcher is the suite's front door. sdk/brand/brandkit.py
turns this description into the files. Run `pwsh scripts/sdk.ps1` first: the kit and the fonts come from the pinned SDK.

The application icon the executable embeds (src/Resolute.rc.in) is resources/icons/Resolute.ico. This script owns that
file too, so the brand and the executable cannot drift apart.
"""
import sys
from pathlib import Path

BRAND = Path(__file__).resolve().parent
sys.path.insert(0, str(BRAND.parent / "sdk" / "brand"))
import brandkit

# The icon on a 96-unit grid, free-standing: the spanner turned to the left, the screwdriver across it.
LARGE = '<defs><linearGradient id="rlg" gradientUnits="userSpaceOnUse" x1="34" y1="4" x2="62" y2="92"><stop offset="0" stop-color="#FFE9A8"/><stop offset="0.45" stop-color="#FFB020"/><stop offset="1" stop-color="#C76A00"/></linearGradient><linearGradient id="rls" gradientUnits="userSpaceOnUse" x1="44" y1="5" x2="52" y2="5"><stop offset="0" stop-color="#F1F5F9"/><stop offset="1" stop-color="#94A3B8"/></linearGradient><linearGradient id="rlh" gradientUnits="userSpaceOnUse" x1="38" y1="54" x2="58" y2="92"><stop offset="0" stop-color="#5CC8FF"/><stop offset="1" stop-color="#1D4ED8"/></linearGradient><linearGradient id="rlc" gradientUnits="userSpaceOnUse" x1="42" y1="48" x2="54" y2="56"><stop offset="0" stop-color="#E2E8F0"/><stop offset="1" stop-color="#64748B"/></linearGradient><mask id="rlm"><rect width="96" height="96" fill="#FFFFFF"/><path d="M41.500 0 H54.500 V19 A6.500 6.500 0 0 1 41.500 19 Z" fill="#000000"/><circle cx="48" cy="79" r="5.500" fill="#000000"/></mask></defs><g transform="rotate(-45 48 48) translate(4.800 4.800) scale(0.9)"><g mask="url(#rlm)" fill="url(#rlg)"><circle cx="48" cy="19" r="15.500"/><rect x="42" y="28" width="12" height="46" rx="3"/><circle cx="48" cy="79" r="12"/></g></g><g transform="rotate(45 48 48) translate(4.800 4.800) scale(0.9)"><path d="M43.500 16 L45.500 5 H50.500 L52.500 16 Z" fill="url(#rls)"/><rect x="45.300" y="14" width="5.400" height="38" fill="url(#rls)"/><rect x="42" y="48" width="12" height="8" rx="2.500" fill="url(#rlc)"/><rect x="38" y="54" width="20" height="38" rx="9" fill="url(#rlh)"/><path d="M44 62 V84 M48 61 V85 M52 62 V84" stroke="#0B2A6B" stroke-width="2" stroke-linecap="round" fill="none" opacity="0.6"/></g>'
# The drawing used below 40 pixels: thicker tools, and no collar or grooves on the handle.
SMALL = '<defs><linearGradient id="rsg" gradientUnits="userSpaceOnUse" x1="34" y1="4" x2="62" y2="92"><stop offset="0" stop-color="#FFE9A8"/><stop offset="0.45" stop-color="#FFB020"/><stop offset="1" stop-color="#C76A00"/></linearGradient><linearGradient id="rss" gradientUnits="userSpaceOnUse" x1="44" y1="5" x2="52" y2="5"><stop offset="0" stop-color="#F1F5F9"/><stop offset="1" stop-color="#94A3B8"/></linearGradient><linearGradient id="rsh" gradientUnits="userSpaceOnUse" x1="38" y1="54" x2="58" y2="92"><stop offset="0" stop-color="#5CC8FF"/><stop offset="1" stop-color="#1D4ED8"/></linearGradient><linearGradient id="rsc" gradientUnits="userSpaceOnUse" x1="42" y1="48" x2="54" y2="56"><stop offset="0" stop-color="#E2E8F0"/><stop offset="1" stop-color="#64748B"/></linearGradient><mask id="rsm"><rect width="96" height="96" fill="#FFFFFF"/><path d="M40 -2 H56 V20 A8 8 0 0 1 40 20 Z" fill="#000000"/><circle cx="48" cy="78" r="6" fill="#000000"/></mask></defs><g transform="rotate(-45 48 48) translate(4.800 4.800) scale(0.9)"><g mask="url(#rsm)" fill="url(#rsg)"><circle cx="48" cy="20" r="18"/><rect x="40" y="28" width="16" height="46" rx="3"/><circle cx="48" cy="78" r="14.500"/></g></g><g transform="rotate(45 48 48) translate(4.800 4.800) scale(0.9)"><path d="M42 18 L44.500 3 H51.500 L54 18 Z" fill="url(#rss)"/><rect x="44" y="16" width="8" height="38" fill="url(#rss)"/><rect x="35" y="50" width="26" height="43" rx="12" fill="url(#rsh)"/></g>'

if __name__ == "__main__":
    files = brandkit.app_assets(
        slug="resolute", name="Resolute", tagline="Windows repair and system tools that fix the problem, show what they changed, and can put it back",
        large=LARGE, small=SMALL, social_ground="#17191E", social_muted="#D9D5CC", credit="By Rizonesoft")
    # What the executable and the campaign shortcuts read (scripts/campaign-icon.py), kept the same as the brand's.
    files["../resources/icons/Resolute.ico"] = files["resolute.ico"]
    files["../resources/icons/Resolute_48.png"] = files["resolute-icon-48.png"]
    files["../resources/icons/Resolute_32.png"] = files["resolute-icon-32.png"]
    sys.exit(brandkit.main(BRAND, files))
