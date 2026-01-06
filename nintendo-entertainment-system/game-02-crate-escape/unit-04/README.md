# Unit 4: Horizontal Movement

Move player left and right with controller.

## What This Unit Covers

- Reading controller input
- Updating player position
- Screen boundaries

## Key Concepts

| Concept | Description |
|---------|-------------|
| Controller port | $4016 (read/strobe) |
| Read sequence | Strobe, then 8 reads |
| Button order | A, B, Select, Start, Up, Down, Left, Right |
| Movement speed | Pixels per frame |

## Controller Reading

```asm
CONTROLLER1 = $4016

buttons:        .res 1

read_controller:
    ; Strobe controller
    lda #$01
    sta CONTROLLER1
    lda #$00
    sta CONTROLLER1

    ; Read 8 buttons
    ldx #8
@loop:
    lda CONTROLLER1
    lsr a               ; Bit 0 to carry
    rol buttons         ; Carry into buttons
    dex
    bne @loop
    rts
```

## Movement

```asm
BUTTON_RIGHT = %00000001
BUTTON_LEFT  = %00000010
MOVE_SPEED   = 2

update_movement:
    lda buttons
    and #BUTTON_RIGHT
    beq @not_right
    lda player_x
    clc
    adc #MOVE_SPEED
    sta player_x

@not_right:
    lda buttons
    and #BUTTON_LEFT
    beq @not_left
    lda player_x
    sec
    sbc #MOVE_SPEED
    sta player_x

@not_left:
    rts
```

## Expected Result

Player moves left and right with D-pad. Stops at screen edges.

## Building

```bash
ca65 crate.asm -o crate.o
ld65 -C nes.cfg crate.o -o crate.nes
```

## Files

- `crate.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `crate.nes` - Compiled ROM
