# Code Like It's 198x - Code Samples

Complete, working code samples for learning retro game development across classic platforms.

## Platforms

| Platform | Game | Units | Description |
|----------|------|-------|-------------|
| [Commodore 64](commodore-64/game-01-sid-symphony/) | SID Symphony | 16 | Rhythm game with SID audio |
| [ZX Spectrum](sinclair-zx-spectrum/game-01-ink-war/) | Ink War | 16 | Territory control strategy |
| [Commodore Amiga](commodore-amiga/game-01-hop/) | Hop | 16 | Frogger-style arcade game |
| [NES](nintendo-entertainment-system/game-01-neon-nexus/) | Neon Nexus | 16 | Fixed-screen action game |

## Structure

```
code-samples/
├── commodore-64/
│   └── game-01-sid-symphony/
│       ├── README.md           # Game overview
│       └── unit-01..16/
│           ├── README.md       # Unit documentation
│           ├── symphony.asm    # Assembly source
│           └── symphony.prg    # Compiled executable
├── sinclair-zx-spectrum/
│   └── game-01-ink-war/
├── commodore-amiga/
│   └── game-01-hop/
└── nintendo-entertainment-system/
    └── game-01-neon-nexus/
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

https://code198x.stevehill.xyz

## Licence

Educational use - see main website repository for full licence information.
