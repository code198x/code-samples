# Starfield

Single-screen space shooter for the Commodore 64.

## Overview

Starfield teaches hardware sprites - the C64's signature graphics feature. You'll build a complete shooter with player ship, bullets, and enemy waves, learning sprite management, joystick input, and collision detection along the way.

## What You'll Learn

| Skill | Description |
|-------|-------------|
| Hardware sprites | Enabling, positioning, and animating VIC-II sprites |
| Sprite pointers | Defining custom sprite graphics in memory |
| Joystick input | Reading the CIA port for player control |
| Sprite collision | Using hardware collision registers |
| Bullet management | Spawning and tracking multiple projectiles |
| Score display | Updating screen memory for scoring |

## Unit Progression

| Unit | Feature | Key Concept |
|------|---------|-------------|
| 01 | Screen setup | Clear screen, set colours |
| 02 | First sprite | Enable sprite, set position |
| 03 | Sprite graphics | Custom sprite data, pointers |
| 04 | Joystick reading | CIA port 2, direction bits |
| 05 | Player movement | Combine input with sprite position |
| 06 | Screen boundaries | Keep player within playfield |
| 07 | Bullet sprite | Second sprite, fire button |
| 08 | Bullet movement | Projectile travels upward |
| 09 | Bullet pooling | Multiple bullets in flight |
| 10 | Enemy sprite | Alien graphics and positioning |
| 11 | Enemy movement | Horizontal patrol patterns |
| 12 | Collision detection | Hardware collision registers |
| 13 | Enemy destruction | Bullets destroy enemies |
| 14 | Wave system | Multiple enemies, respawning |
| 15 | Score and lives | Display and game state |
| 16 | Final polish | Title screen, difficulty, SID effects |

## Building

```bash
# Using Docker
docker run --rm -v "$(pwd):/workspace" -w /workspace \
  ghcr.io/code198x/commodore-64:latest \
  acme -f cbm -o starfield.prg starfield.asm

# Native
acme -f cbm -o starfield.prg starfield.asm
```

## Running

```bash
x64sc starfield.prg
```

## Controls

| Input | Action |
|-------|--------|
| Joystick Port 2 | Move ship |
| Fire button | Shoot |

## Files

Each unit contains:
- `starfield.asm` - Assembly source
- `starfield.prg` - Compiled executable
- `README.md` - Unit documentation
