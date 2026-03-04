# Code Like It's 198x - Code Samples

Complete, working code samples for learning retro game development across classic platforms.

## Platforms

| Platform | Game | Units | Description |
|----------|------|-------|-------------|
| [Commodore 64](commodore-64/game-01-starfield/) | Starfield | 128 | Single-screen space shooter |
| [ZX Spectrum](sinclair-zx-spectrum/game-01-shadowkeep/) | Shadowkeep | 128 | Top-down maze explorer |
| [Commodore Amiga](commodore-amiga/game-01-exodus/) | Exodus | 128 | Terrain puzzle with Blitter |
| [NES](nintendo-entertainment-system/game-01-dash/) | Dash | 128 | Side-scrolling runner |

## Structure

```
code-samples/
├── commodore-64/
│   └── game-01-starfield/
│       ├── README.md           # Game overview
│       └── unit-01..16/
│           ├── README.md       # Unit documentation
│           ├── starfield.asm   # Assembly source
│           └── starfield.prg   # Compiled executable
├── sinclair-zx-spectrum/
│   └── game-01-shadowkeep/
├── commodore-amiga/
│   └── game-01-exodus/
└── nintendo-entertainment-system/
    └── game-01-dash/
```

## Building

### Using Docker (Recommended)

Each platform has a Docker container with all required tools:

```bash
# Commodore 64 (ACME assembler)
docker run --rm -v "$(pwd):/workspace" -w /workspace \
  ghcr.io/code198x/commodore-64:latest \
  acme -f cbm -o symphony.prg symphony.asm

# ZX Spectrum (pasmonext assembler)
docker run --rm -v "$(pwd):/workspace" -w /workspace \
  ghcr.io/code198x/sinclair-zx-spectrum:latest \
  pasmonext --tapbas inkwar.asm inkwar.tap

# Commodore Amiga (vasm assembler)
docker run --rm -v "$(pwd):/workspace" -w /workspace \
  ghcr.io/code198x/commodore-amiga:latest \
  vasmm68k_mot -Fhunkexe -o hop hop.asm

# NES (cc65 toolchain)
docker run --rm -v "$(pwd):/workspace" -w /workspace \
  ghcr.io/code198x/nintendo-nes:latest \
  sh -c "ca65 nexus.asm -o nexus.o && ld65 -C nes.cfg nexus.o -o nexus.nes"
```

### Native Installation

| Platform | Assembler | Install |
|----------|-----------|---------|
| C64 | [ACME](https://sourceforge.net/projects/acme-crossass/) | `brew install acme` |
| ZX Spectrum | [pasmo](https://pasmo.speccy.org/) | `brew install pasmo` |
| Amiga | [vasm](http://sun.hasenbraten.de/vasm/) | Build from source |
| NES | [cc65](https://cc65.github.io/) | `brew install cc65` |

## Running

| Platform | Emulator | Command |
|----------|----------|---------|
| C64 | [VICE](https://vice-emu.sourceforge.io/) | `x64sc symphony.prg` |
| ZX Spectrum | [Fuse](http://fuse-emulator.sourceforge.net/) | `fuse inkwar.tap` |
| Amiga | [FS-UAE](https://fs-uae.net/) | Load via Workbench |
| NES | [Mesen](https://www.mesen.ca/) | Open `nexus.nes` |

## Learning Path

Each game progresses through 16 units, building features incrementally:

1. **Units 1-4**: Display setup, basic graphics, input handling
2. **Units 5-8**: Game objects, movement, core mechanics
3. **Units 9-12**: Scoring, sound, game states
4. **Units 13-16**: Polish, difficulty, high scores, final release

See each game's README for detailed unit breakdowns and learning objectives.

## CI/CD

All code is automatically built and verified on every push via GitHub Actions. Build status reflects whether all assembly files compile successfully across all platforms.

## Website

https://code198x.com

## Licence

Educational use - see main website repository for full licence information.
