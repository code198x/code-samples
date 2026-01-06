# Unit 3: The Hop

Joystick input for frog movement.

## What This Unit Covers

- Joystick port reading via JOY1DAT
- Direction decoding from hardware
- Grid-based movement
- Boundary checking
- Sprite position updates

## Building

```bash
vasmm68k_mot -Fhunkexe -o hop hop.asm
```

## Running

Load `hop` in an emulator. Move the frog with joystick in port 2.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| JOY1DAT | Joystick 2 position register at $DFF00C |
| Direction bits | XOR adjacent bits for direction |
| Grid snap | Move in fixed 16-pixel increments |
| Position limits | Clamp to playfield boundaries |

## Joystick Decoding

```asm
move.w  JOY1DAT(a5),d0
btst    #1,d0           ; Right
btst    #9,d0           ; Left
move.w  d0,d1
lsr.w   #1,d1
eor.w   d1,d0
btst    #0,d0           ; Down
btst    #8,d0           ; Up
```

## Files

- `hop.asm` - Assembly source
- `hop` - Compiled Amiga executable
