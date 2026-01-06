# Unit 9: Title Screen

Game state machine with title display.

## What This Unit Covers

- Game state variable
- Title screen nametable
- State transitions
- Start button detection

## Building

```bash
ca65 nexus.asm -o nexus.o
ld65 -C nes.cfg nexus.o -o nexus.nes
```

## Running

Load `nexus.nes` in an emulator. Title screen shows until START pressed.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| State machine | Variable determines update routine |
| Nametable swap | Different backgrounds per state |
| Button edge | Detect press, not hold |
| State init | Setup code when entering state |

## Game States

| State | Value | Description |
|-------|-------|-------------|
| Title | 0 | Show title, wait for START |
| Playing | 1 | Active gameplay |
| Game Over | 2 | Final score display |

## State Dispatch

```asm
main_loop:
    jsr wait_vblank
    lda game_state
    cmp #STATE_TITLE
    beq @do_title
    cmp #STATE_PLAYING
    beq @do_playing
    jmp @do_gameover
```

## Files

- `nexus.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `nexus.nes` - Compiled ROM
