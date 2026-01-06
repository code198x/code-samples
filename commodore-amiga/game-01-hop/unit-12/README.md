# Unit 12: Title Screen

Title display and game state management.

## What This Unit Covers

- Title screen graphics
- Game state machine
- Fire button to start
- State transitions
- Screen clearing between states

## Building

```bash
vasmm68k_mot -Fhunkexe -o hop hop.asm
```

## Running

Load `hop` in an emulator. Title screen displays until fire button pressed.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Game states | Title, playing, game over |
| State variable | Determines which update to run |
| Fire detect | Check joystick button bit |
| Screen swap | Different graphics per state |

## Game States

| State | Value | Description |
|-------|-------|-------------|
| Title | 0 | Show title, wait for fire |
| Playing | 1 | Active gameplay |
| Game Over | 2 | Final score, wait for fire |

## State Machine

```asm
main_loop:
    jsr     wait_vblank
    move.w  game_state,d0
    add.w   d0,d0
    lea     state_table,a0
    move.l  (a0,d0.w),a0
    jsr     (a0)
    bra.s   main_loop

state_table:
    dc.l    do_title
    dc.l    do_playing
    dc.l    do_gameover
```

## Files

- `hop.asm` - Assembly source
- `hop` - Compiled Amiga executable
