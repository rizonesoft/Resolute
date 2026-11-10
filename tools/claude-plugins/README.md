# Claude Code plugins

The plugins this repository ships for its own Claude Code sessions. `.claude/settings.json` declares this folder as the `resolute-tools` marketplace, by a path relative to the repository, and enables what is listed here, so a session opened in a trusted clone needs no install step.

## resolute-lsp

Language servers, so a session sees compiler and type errors right after an edit and finds definitions and callers by symbol instead of by text search.

| Server | Files | What starts |
| ------ | ----- | ----------- |
| clangd | `.c`, `.h`, `.hpp`, `.cpp`, `.cc`, `.cxx`, `.inl` | The clangd in `reskit/llvm-mingw/bin`, beside the compiler the build uses, reading `build/debug/compile_commands.json`, with clang-tidy on |
| pyright | `.py` | `pyright-langserver` from `PATH`, limited by `pyrightconfig.json` to `scripts/` |

Both start through `python scripts/lsp-launch.py <server>`, which finds the binary, holds it in a job object, and exits when the process that started it exits, so a language server never outlives its session.

## Setting up a clone

```powershell
pwsh scripts/bootstrap.ps1                       # the pinned toolchain, which carries clangd
npm install -g pyright                           # the Python server
pwsh scripts/build.ps1 Resolute -Config Debug    # writes the compile database clangd reads
```

Without a compile database clangd still starts and falls back to default flags.

## Checking a server by hand

A server that does not start shows under `/plugin`, Errors. `python scripts/lsp-launch.py clangd` prints why (a missing toolchain, a missing `pyright-langserver`) to stderr and exits 1.
