# Icon sources

The SVGs here are embedded into the launcher by `../CMakeLists.txt`, each under its file name. Most are Lucide icons; the `theme-*`, `view-*`, `system`, `network`, `security`, `display`, and `programs` files are the suite's own.

Added by D00 T02 §8, whose manifest audit found the shared controls referencing seven names the set did not carry (each resolved to null and drew nothing). Each is Lucide 1.48.0 (`https://github.com/lucide-icons/lucide`, ISC licence, copyright Lucide Icons and Contributors), whitespace collapsed to one line, saved under the name the controls reference:

| File | Lucide 1.48.0 source |
| --- | --- |
| `inbox.svg` | `icons/inbox.svg` |
| `alert-triangle.svg` | `icons/triangle-alert.svg` |
| `check-circle.svg` | `icons/circle-check.svg` |
| `circle.svg` | `icons/circle.svg` |
| `loader-2.svg` | `icons/loader-circle.svg` |
| `check.svg` | `icons/check.svg` |
| `ellipsis.svg` | `icons/ellipsis.svg` |
| `square-dashed.svg` | `icons/square-dashed.svg` (D00 T02 §9: the fallback drawn for an unknown name) |

`tests/icon_manifest.txt` lists every icon name the code references, and `tests/icon_manifest_test.cpp` asserts each resolves.
