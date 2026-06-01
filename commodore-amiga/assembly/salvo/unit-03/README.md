# Unit 3: Player Movement

Move the ship with joystick input.

## What This Unit Covers

- Reading joystick from CIA
- Updating sprite position
- Movement boundaries

## Key Concepts

| Concept | Description |
|---------|-------------|
| JOY1DAT | $DFF00C - joystick port 1 data |
| Direction decode | XOR adjacent bits for direction |
| Position update | Modify sprite control words |
| Boundaries | Keep sprite on screen |

## Joystick Reading

```asm
read_joystick:
    move.w  JOY1DAT,d0

    ; Right: bit 1 XOR bit 0
    move.w  d0,d1
    lsr.w   #1,d1
    eor.w   d0,d1
    btst    #0,d1
    beq.s   .not_right
    addq.w  #2,player_x

.not_right:
    ; Left: bit 9 XOR bit 8
    btst    #1,d1
    beq.s   .not_left
    subq.w  #2,player_x

.not_left:
    ; Up/Down similar with bits 8,9
```

## Position to Sprite

```asm
update_sprite_pos:
    move.w  player_x,d0
    move.w  player_y,d1

    ; Encode into control words
    ; HSTART = X + $40
    ; VSTART = Y
```

## Expected Result

Player ship moves in all directions with joystick, stays within screen bounds.

## Building

```bash
vasmm68k_mot -Fhunkexe -o salvo salvo.asm
```

## Files

- `salvo.asm` - Assembly source
- `salvo` - Compiled executable
