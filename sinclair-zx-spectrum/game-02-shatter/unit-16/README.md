# Unit 16: Final Polish

Complete game with title screen and refinements.

## What This Unit Covers

- Title screen
- High score tracking
- Game feel improvements
- State machine completion

## Key Concepts

| Concept | Description |
|---------|-------------|
| Game states | Title, Playing, Game Over |
| Title screen | Game name, instructions, high score |
| Polish | Visual feedback, timing tweaks |
| High score | Track best score across games |

## Game States

```asm
STATE_TITLE     = 0
STATE_PLAYING   = 1
STATE_GAMEOVER  = 2

game_state:     defb STATE_TITLE

main_loop:
    ld a, (game_state)
    cp STATE_TITLE
    jp z, do_title
    cp STATE_PLAYING
    jp z, do_playing
    jp do_gameover
```

## Title Screen

```asm
show_title:
    call clear_screen
    ; Print "SHATTER" in large text
    ; Print "Press SPACE to start"
    ; Print high score
    ret

title_input:
    ld a, $7F
    in a, ($FE)         ; Space row
    bit 0, a
    ret nz              ; Not pressed

    ; Start game
    call init_game
    ld a, STATE_PLAYING
    ld (game_state), a
    ret
```

## Complete Feature List

- Title screen with instructions
- Paddle movement with O/P keys
- Smooth ball physics
- Angled bounces off paddle
- 6 rows of coloured bricks
- Score tracking
- 3 lives with respawn
- Power-ups (wide paddle, slow ball, extra life)
- Multiple levels
- Beeper sound effects
- High score persistence
- Game over screen

## Building

```bash
pasmonext --tapbas shatter.asm shatter.tap
```

## Running

```bash
fuse shatter.tap
```

## Files

- `shatter.asm` - Assembly source
- `shatter.tap` - Tape image
