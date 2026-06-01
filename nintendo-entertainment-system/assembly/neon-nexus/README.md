# Neon Nexus

A fixed-screen action game for the Nintendo Entertainment System that teaches 6502 assembly programming through incremental game development.

## Overview

Neon Nexus is an arena-style action game where you collect items while avoiding enemies. Navigate the grid, grab power-ups, and survive as long as possible. The game demonstrates NES hardware programming including PPU graphics, APU audio, and controller input.

## Controls

- **D-Pad** - Move player
- **START** - Pause game
- **A/B** - Start game from title screen

## Building

Requires [cc65](https://cc65.github.io/) (ca65 assembler and ld65 linker).

```bash
ca65 nexus.asm -o nexus.o
ld65 -C nes.cfg nexus.o -o nexus.nes
```

Or use the provided Docker container:

```bash
docker run --rm -v "$(pwd):/workspace" -w /workspace \
  ghcr.io/code198x/nintendo-nes:latest \
  sh -c "ca65 nexus.asm -o nexus.o && ld65 -C nes.cfg nexus.o -o nexus.nes"
```

## Unit Progression

| Unit | Title | Features Introduced |
|------|-------|---------------------|
| 01 | The Grid | PPU setup, background rendering |
| 02 | The Player | OAM sprites, player display |
| 03 | Movement | Controller reading, player movement |
| 04 | Enemies | Enemy sprites, movement patterns |
| 05 | Items | Collectible items, spawning |
| 06 | Collision | Sprite collision detection |
| 07 | Score | Score tracking, HUD display |
| 08 | Lives | Lives system, respawning |
| 09 | Title Screen | Game states, title display |
| 10 | Sound Effects | APU audio programming |
| 11 | Difficulty | Progressive difficulty scaling |
| 12 | High Score | Best score persistence |
| 13 | Enemy Variety | Multiple enemy types |
| 14 | Pause | Pause functionality |
| 15 | Game Over Polish | Visual polish effects |
| 16 | Final Polish | Complete release version |

## Learning Objectives

### Phase 1: Display (Units 1-3)
- iNES header format
- PPU initialisation and timing
- Background nametables
- OAM sprite rendering
- Controller reading via $4016

### Phase 2: Gameplay (Units 4-7)
- Multiple sprite management
- Movement patterns
- Collision detection
- Score display in nametable

### Phase 3: Game Loop (Units 8-11)
- Lives and game over
- State machine architecture
- APU pulse and noise channels
- Difficulty ramping

### Phase 4: Polish (Units 12-16)
- High score tracking
- Enemy variety
- Pause system
- Visual feedback effects

## Hardware Used

- **PPU**: Background tiles, sprites (OAM), palette
- **APU**: Pulse channels for music/SFX, noise for effects
- **Controller**: $4016 for player input

## File Structure

Each unit contains:
- `nexus.asm` - Main assembly source
- `nes.cfg` - Linker configuration
- `nexus.nes` - Compiled NES ROM
- `snippets/` - Code excerpts (where applicable)
