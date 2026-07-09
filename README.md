# Code198x code samples

Working source code, assets, capture helpers, and sample projects for Code198x curriculum units.

This repo is code-first support for the website catalogues. Do not treat this README as the module/status source of truth; current module and unit availability lives in the website repo under `src/content/modules/` and `src/content/units/`.

## Current layout

```text
code-samples/
├── commodore-64/
│   ├── basic/
│   └── assembly/
│       ├── meet-the-machine/
│       ├── sid-symphony/
│       └── starfield/
├── sinclair-zx-spectrum/
│   ├── basic/
│   ├── assembly/
│   │   ├── meet-the-machine/
│   │   ├── gloaming/
│   │   ├── the-long-night/
│   │   └── shadowkeep/
│   ├── assets/
│   ├── patterns/
│   ├── tools/
│   └── tests/
├── commodore-amiga/
│   ├── amos/
│   ├── blitz/
│   └── assembly/
├── nintendo-entertainment-system/
│   └── assembly/
│       ├── meet-the-machine/
│       ├── dash/
│       └── neon-nexus/
├── foundations/
├── _capture/
└── scripts/
```

Additional platform folders exist for emerging or reference sample work. Check the platform folder before assuming a sample path is part of the published curriculum.

## Relationship to the website

- Website module catalogue: `../website/src/content/modules/`
- Website unit catalogue: `../website/src/content/units/`
- Published pages/routes: `../website/src/pages/`

When adding or moving samples, update the relevant website catalogue or unit references in the same change if the sample is learner-facing.

## Building samples

Build commands are platform- and module-specific. Prefer the commands in the sample directory or the corresponding website unit.

Current toolchain direction:

- **C64 6502** — ACME-compatible sources; Asm198x support exists for curriculum-compatible paths.
- **ZX Spectrum Z80** — Spectrum assembly builds use Asm198x/pasmo-compatible flows; the old Spectrum dev-container repo is retired.
- **NES 6502** — ca65/ld65-compatible sources and linked `.nes` outputs.
- **Amiga** — AMOS, Blitz, and 68000/vasm-style assembly samples, depending on module.
- **Assets/media** — Build198x owns reusable conversion and packaging tools as they graduate from sample-local scripts.

Use each sample's `README.md`, Makefile, or script as the local authority for exact commands.

## Captures and verification

This repo contains sample-local capture and test support where needed, but not every sample has the same level of automation. If a workflow depends on emulator screenshots, audio, scripts, or MCP, prefer the documented Emu198x capture path for that platform.

## Licence

Educational use; see the project website and individual source headers where present.
