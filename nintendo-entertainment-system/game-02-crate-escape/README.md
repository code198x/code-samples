# Crate Escape

Single-screen platformer for the Nintendo Entertainment System.

## Overview

Crate Escape teaches platformer physics - the NES's signature genre. You'll build a complete platformer with gravity, jumping, platform collision, and animation, learning the techniques that powered classics like Super Mario Bros. and Mega Man.

## What You'll Learn

| Skill | Description |
|-------|-------------|
| Gravity | Acceleration and terminal velocity |
| Jump physics | Impulse, arc, and variable height |
| Platform collision | Tile-based detection |
| Animation | Walk cycles and state-based frames |
| Level design | Tile map layouts |
| Game loop | NMI-driven update cycle |

## Unit Progression

| Unit | Feature | Key Concept |
|------|---------|-------------|
| 01 | Display setup | PPU initialisation |
| 02 | Background tiles | Nametable and pattern table |
| 03 | Player sprite | OAM and metasprites |
| 04 | Horizontal movement | Controller input |
| 05 | Gravity | Downward acceleration |
| 06 | Jump physics | Impulse and arc |
| 07 | Platform detection | Tile collision |
| 08 | Landing | Stopping on platforms |
| 09 | Walk animation | Frame cycling |
| 10 | Jump animation | State-based sprites |
| 11 | Hazards | Spikes and pits |
| 12 | Enemy sprites | Basic enemy graphics |
| 13 | Enemy movement | Patrol patterns |
| 14 | Player-enemy collision | Damage handling |
| 15 | Level exit | Goal and completion |
| 16 | Final polish | Title screen, lives, audio |

## Building

```bash
# Using Docker
docker run --rm -v "$(pwd):/workspace" -w /workspace \
  ghcr.io/code198x/nintendo-nes:latest \
  sh -c "ca65 crate.asm -o crate.o && ld65 -C nes.cfg crate.o -o crate.nes"

# Native
ca65 crate.asm -o crate.o
ld65 -C nes.cfg crate.o -o crate.nes
```

## Running

Load `crate.nes` in Mesen or another NES emulator.

## Controls

| Button | Action |
|--------|--------|
| D-Pad | Move left/right |
| A | Jump |
| START | Pause |

## Files

Each unit contains:
- `crate.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `crate.nes` - Compiled ROM
- `README.md` - Unit documentation
