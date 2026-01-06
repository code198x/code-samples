# Unit 12: Lives System

Handle ball loss and game over.

## What This Unit Covers

- Detecting ball off bottom
- Lives counter
- Ball respawn
- Game over state

## Key Concepts

| Concept | Description |
|---------|-------------|
| Ball lost | Y position > screen bottom |
| Lives | Start with 3, decrement on loss |
| Respawn | Reset ball to paddle, wait for launch |
| Game over | Lives = 0, show message |

## Ball Loss Detection

```asm
check_ball_lost:
    ld a, (ball_y)
    cp 184                  ; Bottom of playfield
    ret c                   ; Still in play

    ; Ball lost!
    ld a, (lives)
    dec a
    ld (lives), a
    jr z, game_over

    ; Respawn
    call reset_ball
    call draw_lives
    ret

game_over:
    ld a, STATE_GAMEOVER
    ld (game_state), a
    call show_game_over
    ret
```

## Lives Display

```asm
lives:      defb 3

draw_lives:
    ; Draw ball icons for remaining lives
    ld a, (lives)
    ld b, a
    ld hl, LIVES_POSITION
draw_life:
    ld (hl), BALL_CHAR
    inc hl
    djnz draw_life
    ret
```

## Expected Result

Ball respawns on paddle after loss. Game ends when all lives gone.

## Building

```bash
pasmonext --tapbas shatter.asm shatter.tap
```

## Files

- `shatter.asm` - Assembly source
- `shatter.tap` - Tape image
