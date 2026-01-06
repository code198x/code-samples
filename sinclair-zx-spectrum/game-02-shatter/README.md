# Shatter

Breakout clone for the Sinclair ZX Spectrum.

## Overview

Shatter teaches smooth graphics on a machine with no hardware sprites. You'll build a polished Breakout game with pixel-perfect ball movement, satisfying collision physics, and custom fonts - learning the techniques that made classic Spectrum games shine despite hardware limitations.

## What You'll Learn

| Skill | Description |
|-------|-------------|
| Custom fonts | Designing and installing UDG characters |
| Smooth movement | Sub-cell positioning for fluid animation |
| Collision physics | Bounce angles and reflection |
| Attribute control | Managing colour without clash |
| Beeper sound | Pitch variation for audio feedback |
| Game polish | Timing, feel, and presentation |

## Unit Progression

| Unit | Feature | Key Concept |
|------|---------|-------------|
| 01 | Screen setup | Border drawing, play area |
| 02 | Custom font | UDG design and installation |
| 03 | Paddle drawing | XOR sprite technique |
| 04 | Paddle movement | Keyboard input, smooth motion |
| 05 | Ball sprite | Small moving object |
| 06 | Ball movement | Velocity and direction |
| 07 | Wall collision | Boundary detection, reflection |
| 08 | Paddle collision | Angle calculation |
| 09 | Brick grid | Drawing brick layout |
| 10 | Brick collision | Detection and removal |
| 11 | Score display | Number printing |
| 12 | Lives system | Ball loss, respawn |
| 13 | Sound effects | Beeper pitch variation |
| 14 | Power-ups | Paddle size, ball speed |
| 15 | Level progression | New brick layouts |
| 16 | Final polish | Title screen, game feel |

## Building

```bash
# Using Docker
docker run --rm -v "$(pwd):/workspace" -w /workspace \
  ghcr.io/code198x/sinclair-zx-spectrum:latest \
  pasmonext --tapbas shatter.asm shatter.tap

# Native
pasmonext --tapbas shatter.asm shatter.tap
```

## Running

```bash
fuse shatter.tap
```

## Controls

| Key | Action |
|-----|--------|
| O | Move paddle left |
| P | Move paddle right |
| SPACE | Launch ball / Start |

## Files

Each unit contains:
- `shatter.asm` - Assembly source
- `shatter.tap` - Tape image
- `README.md` - Unit documentation
