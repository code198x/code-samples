# Unit 8: Landing

Stop player on platforms when falling.

## What This Unit Covers

- Predictive collision
- Position correction
- Grounded state

## Key Concepts

| Concept | Description |
|---------|-------------|
| Look-ahead | Check future position |
| Snap to tile | Align Y to tile boundary |
| Stop velocity | Zero Y velocity on land |
| Both feet | Check left and right foot |

## Landing Logic

```asm
check_landing:
    ; Only check when falling
    lda player_vel_y
    bmi @done               ; Moving up
    beq @done               ; Not moving

    ; Calculate future Y
    lda player_y
    clc
    adc player_vel_y
    clc
    adc #16                 ; Bottom of player
    sta temp_y

    ; Check left foot
    lda player_x
    clc
    adc #2                  ; Inset from left
    jsr pixel_to_tile
    tax
    lda temp_y
    jsr pixel_to_tile
    tay
    jsr check_tile_solid
    bne @land

    ; Check right foot
    lda player_x
    clc
    adc #13                 ; Inset from right
    jsr pixel_to_tile
    tax
    lda temp_y
    jsr pixel_to_tile
    tay
    jsr check_tile_solid
    beq @done

@land:
    ; Snap to tile top
    lda player_y
    clc
    adc #16
    jsr pixel_to_tile
    asl a
    asl a
    asl a                   ; Back to pixels
    sec
    sbc #16                 ; Player height
    sta player_y

    ; Stop falling
    lda #0
    sta player_vel_y
    lda #1
    sta player_grounded

@done:
    rts
```

## Expected Result

Player lands on platforms and stops. Can walk on crates.

## Building

```bash
ca65 crate.asm -o crate.o
ld65 -C nes.cfg crate.o -o crate.nes
```

## Files

- `crate.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `crate.nes` - Compiled ROM
