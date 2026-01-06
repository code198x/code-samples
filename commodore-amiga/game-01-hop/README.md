# Hop

A Frogger-style arcade game for the Commodore Amiga that teaches 68000 assembly programming through incremental game development.

## Overview

Hop is a classic Frogger clone where you guide a frog across busy roads and treacherous rivers to reach home. The game demonstrates direct hardware programming on the Amiga, bypassing the operating system entirely.

## Controls

- **Joystick Port 2** - Move frog (up/down/left/right)
- **Fire Button** - Start game / continue

## Building

Requires [vasm](http://sun.hasenbraten.de/vasm/) assembler (Motorola syntax).

```bash
vasmm68k_mot -Fhunkexe -o hop hop.asm
```

Or use the provided Docker container:

```bash
docker run --rm -v "$(pwd):/workspace" -w /workspace \
  ghcr.io/code198x/commodore-amiga:latest \
  vasmm68k_mot -Fhunkexe -o hop hop.asm
```

## Unit Progression

| Unit | Title | Features Introduced |
|------|-------|---------------------|
| 01 | The Lanes | Copper list, display setup, machine takeover |
| 02 | The Frog | Hardware sprite display |
| 03 | The Hop | Joystick input, grid movement |
| 04 | The Traffic | Blitter operations for car drawing |
| 05 | Traffic Flow | Moving objects, animation timing |
| 06 | The River | River section graphics |
| 07 | Riding the Logs | Platform riding mechanics |
| 08 | Collision and Death | Hit detection, death animation |
| 09 | Lives and Scoring | Lives counter, score display |
| 10 | Home Zone | Goal detection, level completion |
| 11 | Sound Effects | Paula audio chip programming |
| 12 | Title Screen | Title display, game states |
| 13 | High Score Table | Score persistence |
| 14 | Level Progression | Difficulty scaling |
| 15 | Time Limit | Timer mechanics |
| 16 | Final Game | Complete polished version |

## Learning Objectives

### Phase 1: Display (Units 1-3)
- Amiga custom chip architecture
- Copper list programming
- Hardware sprite configuration
- Joystick reading via CIA

### Phase 2: Graphics (Units 4-7)
- Blitter operations (copy, fill, mask)
- Bitplane graphics
- Scrolling and animation
- Platform physics

### Phase 3: Gameplay (Units 8-11)
- Collision detection
- Game state management
- Lives and scoring systems
- Paula audio programming

### Phase 4: Polish (Units 12-16)
- Title and game over screens
- High score tracking
- Difficulty progression
- Time pressure mechanics

## Hardware Used

- **Copper**: Display list co-processor
- **Blitter**: Hardware block copy and fill
- **Sprites**: Hardware sprites for frog
- **Paula**: 4-channel audio chip
- **CIA**: Joystick port reading

## File Structure

Each unit contains:
- `hop.asm` - Main assembly source
- `hop` - Compiled Amiga executable (Hunk format)
