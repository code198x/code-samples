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

### Selected pattern evidence

The Pattern evidence workflow checks five selected samples: C64 Hardware
Sprites, NES Square Wave, Amiga Playing a Sample, Spectrum Bitmap Addressing
and the cross-platform AABB Python reference. It runs on every pull request
and push to main/master, so a path filter cannot hide a changed input.

```sh
python3 scripts/check-pattern-evidence.py
python3 -m unittest discover -s scripts -p test_pattern_evidence.py -v
python3 cross-platform/patterns/physics/aabb-collision/verification/verify.py --output /tmp/aabb-check
```

Use Python 3.14, as CI does; no Python packages or firmware are required.
The first command compares 18 declared source/observer/helper hashes with
existing execution records. `recorded_inputs_match` means those recorded
inputs match current files. It does not mean the machines were rerun or that
current tool binaries, firmware or other configurations are qualified.
`--output /path/to/report.json` retains the same report printed to stdout.
A stale or missing input returns a nonzero exit and a diagnostic naming the
fixture. Missing/malformed records and reduced or duplicate selections fail.
The separate AABB job freshly executes its independent occupied-pixel oracle
and negative cases; this is Python host behaviour, not retro CPU execution.

`scripts/pattern-evidence.json` selects existing records and hash fields;
it is an adapter for these five samples, not a new execution-record schema.
After changing a declared source or observer, rerun that sample's documented
verifier and review the new result. Preserve historical runs and point the
selection to the new record when it has a new filename. Do not merely replace
old hashes to silence the guard. Changing the selected scope also requires
an explicit update to the checker's required fixture/binding counts and its
regression tests.

CI uploads the binding report and fresh AABB result with 14-day retention.
The sample-local committed records remain the durable historical evidence.
Other pattern observers are not executed by this workflow. Broader runtime,
release-toolchain and firmware-dependent qualification stays separate.

### Executable curriculum proofs

Versioned proof manifests connect selected lessons to primary evidence and the
exact Asm198x, Build198x, and Emu198x revisions that produced their runnable
artefacts. The first proof is Amiga assembly “Colour and the Copper”:

```bash
python3 _capture/verify.py \
  commodore-amiga/assembly/meet-the-machine/unit-07/capture/manifest.json \
  --public
```

Public mode verifies the cited evidence, executable, deterministic ADF, and
structure without requiring copyrighted firmware. Full mode additionally needs
`EMU198X_AMIGA_KICKSTART` to name a legally obtained, recognised Kickstart 1.3
ROM and asserts the exact Emu198x frame.

## Licence

Educational use; see the project website and individual source headers where present.
