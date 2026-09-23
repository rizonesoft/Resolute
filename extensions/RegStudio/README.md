# RegStudio

A modern, bare-metal Windows Registry Editor built with C++23 and Native Win32 API.

## Features

- **Native Performance** — Direct Win32 API with no framework overhead
- **Modern UI** — Explorer-style controls with Dark Mode support
- **Virtual ListView** — Handles thousands of registry values without lag
- **RAII Design** — Safe, leak-free registry handle management
- **Static Linking** — Single portable executable, no DLL dependencies

## Tech Stack

| Component | Choice |
|-----------|--------|
| Compiler | G++ (MinGW-w64 x86_64) |
| Standard | C++23 |
| UI | Native Win32 (user32, comctl32) |
| Build | CMake + Ninja |
| Styling | UxTheme + DWM APIs |

## Building

### Prerequisites

- [MSYS2](https://www.msys2.org/) with MinGW-w64 toolchain
- CMake 3.25+
- Ninja

```bash
# Install dependencies (MSYS2 MinGW64 shell)
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-cmake ninja
```

### Build

```bash
mkdir build && cd build
cmake -G Ninja ..
ninja
```

The output executable will be in `bin/RegStudio.exe`.

## License

[MIT](LICENSE) © Rizonesoft
