# 01 Framework

> **Phase 1**

The shared framework every tool consumes. Startup, settings, logging, localization, update, elevation, preferences, About, DPI, and theme, written once. This is the single largest reduction in the project.

## TODOs

| TODO | Title | Status |
| ---- | ----- | :----: |
| [TODO-01](./TODO-01-framework-core.md) | Framework Core | draft |
| [TODO-02](./TODO-02-design-system.md) | Design System | draft |

## Completed

| TODO | Title | Completed |
| ---- | ----- | :-------: |

## In scope

- The application shell and the tool descriptor
- One settings writer and one settings path
- One log format, the localization loader, and the update check
- The standard window, About, preferences, DPI, and system theme
- Proof that a tool runs standalone in an empty folder
- The design system that makes `DESIGN.md` true and checkable

## Out of scope

- Anything a specific tool does (03, 04, 05)
- The repair machinery the destructive tools need (02)
- Language pack content (08); this domain loads packs, it does not write them

---

Format spec: [../README.md](../README.md) · Root index: [../TODO-00-INDEX.md](../TODO-00-INDEX.md)
