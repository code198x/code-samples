# Unit Plan: commodore-64/game-01-starfield/unit-10

## Learning Objectives
- Reuse the collision pattern (ship vs enemy instead of bullet vs enemy)
- Game state flag — a single byte controls whether the game runs
- Looped collision — checking the ship against each enemy in the table

## Prerequisites
- Indexed addressing and data tables (Unit 9)
- Bounding-box collision (Unit 6, refined in Unit 9)
- Subroutines with JSR/RTS (Unit 9)

## What the Learner Builds

Ship-enemy collision. Each frame, after enemies move, loop through all three
enemies and compare distance to the ship. On collision, set `game_over` flag.
The game loop checks this flag — when set, all input and updates are skipped.
The game freezes. The ship sprite changes to red to show it's been hit.

## New Variables

```asm
game_over = $11     ; 0 = playing, 1 = game over
```

## Assembly Code Design

### Zero-page layout (complete)
```
bullet_active = $02
bullet_y      = $03
score         = $07
enemy_x_tbl   = $08  ; 3 bytes
enemy_y_tbl   = $0b  ; 3 bytes
flash_tbl      = $0e  ; 3 bytes
game_over      = $11  ; 1 byte
```

### Changes from Unit 9

1. **Init:** Set `game_over` to 0.

2. **Game loop top:** After raster wait, check `game_over`. If non-zero, skip
   all input/movement/collision and jump back to game_loop (freeze).

3. **Ship-enemy collision loop:** After enemy update loop, before `jmp game_loop`.
   Loop X from 0 to 2, skip flashing enemies, check ship-enemy distance using
   the same bounding-box pattern as bullet-enemy collision. On hit, set
   `game_over` to 1 and change ship colour to red ($02).

4. **SCREENSHOT_MODE:** Show game over state — ship turned red, enemies visible,
   score showing.

### Snippets

1. `01-ship-collision.asm` — The ship-enemy distance check loop
2. `02-game-over-flag.asm` — Setting and checking game_over at top of loop

### MDX Sections

- Opening: enemies descend but the ship is invincible — not any more
- Reusing the Collision Pattern
- Checking All Enemies
- Freezing the Game
- The Complete Code
- If It Doesn't Work
- Try This: Different Death Effects
- What You've Learnt
- What's Next (Unit 11: game over text + restart)
