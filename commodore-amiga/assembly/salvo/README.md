# Salvo

Fixed-screen space shooter for the Commodore Amiga.

## Overview

Salvo builds on Hop's foundation to add player-controlled shooting. You'll create a complete shooter with projectile management, enemy waves, and collision detection - deepening your understanding of the Amiga's custom chipset while learning essential game mechanics.

## What You'll Learn

| Skill | Description |
|-------|-------------|
| Projectile spawning | Creating bullets on button press |
| Bullet pooling | Managing multiple projectiles |
| Enemy formations | Coordinated enemy movement |
| Collision detection | Bullet-enemy and enemy-player |
| Wave system | Progressive difficulty |
| Score tracking | Blitter text rendering |

## Unit Progression

| Unit | Feature | Key Concept |
|------|---------|-------------|
| 01 | Display setup | Copper list, playfield |
| 02 | Player sprite | Hardware sprite positioning |
| 03 | Player movement | Joystick via CIA |
| 04 | Bullet sprite | Second sprite, fire button |
| 05 | Bullet movement | Projectile velocity |
| 06 | Bullet pooling | Multiple bullets in flight |
| 07 | Enemy sprite | BOB or sprite for enemy |
| 08 | Enemy movement | Patrol patterns |
| 09 | Bullet collision | Hit detection |
| 10 | Enemy destruction | Visual feedback |
| 11 | Multiple enemies | Enemy array |
| 12 | Enemy-player collision | Damage handling |
| 13 | Wave system | Respawn and progression |
| 14 | Score display | Blitter text |
| 15 | Lives and audio | Paula sound effects |
| 16 | Final polish | Title screen, balance |

## Building

```bash
# Using Docker
docker run --rm -v "$(pwd):/workspace" -w /workspace \
  ghcr.io/code198x/commodore-amiga:latest \
  vasmm68k_mot -Fhunkexe -o salvo salvo.asm

# Native
vasmm68k_mot -Fhunkexe -o salvo salvo.asm
```

## Running

Load `salvo` in FS-UAE or on real hardware via Workbench.

## Controls

| Input | Action |
|-------|--------|
| Joystick | Move ship |
| Fire button | Shoot |

## Files

Each unit contains:
- `salvo.asm` - Assembly source
- `salvo` - Compiled executable
- `README.md` - Unit documentation
