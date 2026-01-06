# Unit 16: Final Polish

Complete game with title screen and balance.

## What This Unit Covers

- Title screen state
- Game over screen
- High score tracking
- Final balancing

## Key Concepts

| Concept | Description |
|---------|-------------|
| Game states | Title, Playing, Game Over |
| State machine | Branch based on state |
| High score | Track best score |
| Polish | Visual feedback, timing |

## Game States

```asm
STATE_TITLE     = 0
STATE_PLAYING   = 1
STATE_GAMEOVER  = 2

game_state:     dc.b    STATE_TITLE

main_loop:
    bsr     wait_vblank

    moveq   #0,d0
    move.b  game_state,d0
    lsl.w   #2,d0
    lea     state_table(pc),a0
    move.l  (a0,d0.w),a0
    jsr     (a0)

    bra.s   main_loop

state_table:
    dc.l    do_title
    dc.l    do_playing
    dc.l    do_gameover
```

## Title Screen

```asm
do_title:
    ; Draw "SALVO" title
    ; Draw "Press Fire to Start"
    ; Draw high score

    btst    #7,CIAA_PRA
    bne.s   .done

    ; Start game
    bsr     init_game
    move.b  #STATE_PLAYING,game_state

.done:
    rts
```

## Complete Feature List

- Title screen with instructions
- Player ship with 4-directional movement
- Multiple bullets (4 in flight)
- 4 enemies with patrol patterns
- Bounding box collision detection
- Explosion effects
- Wave system with difficulty scaling
- Score display
- Lives system
- Paula sound effects
- High score tracking
- Game over screen

## Building

```bash
vasmm68k_mot -Fhunkexe -o salvo salvo.asm
```

## Running

Load in FS-UAE or on real Amiga hardware.

## Files

- `salvo.asm` - Assembly source
- `salvo` - Compiled executable
