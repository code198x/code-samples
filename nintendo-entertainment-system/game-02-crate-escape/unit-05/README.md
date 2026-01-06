# Unit 5: Gravity

Apply downward acceleration to the player.

## What This Unit Covers

- Velocity variables
- Acceleration (gravity constant)
- Terminal velocity

## Key Concepts

| Concept | Description |
|---------|-------------|
| Velocity | Speed and direction |
| Acceleration | Change in velocity per frame |
| Terminal velocity | Maximum fall speed |
| Fixed point | Fractional values via high/low bytes |

## Velocity Variables

```asm
player_vel_y:       .res 1  ; Signed velocity
GRAVITY         = 1         ; Acceleration per frame
TERMINAL_VEL    = 6         ; Maximum fall speed
```

## Gravity Application

```asm
apply_gravity:
    ; Add gravity to velocity
    lda player_vel_y
    clc
    adc #GRAVITY

    ; Clamp to terminal velocity
    cmp #TERMINAL_VEL
    bcc @store
    lda #TERMINAL_VEL

@store:
    sta player_vel_y

    ; Apply velocity to position
    lda player_y
    clc
    adc player_vel_y
    sta player_y
    rts
```

## Expected Result

Player falls downward with increasing speed until reaching terminal velocity.

## Building

```bash
ca65 crate.asm -o crate.o
ld65 -C nes.cfg crate.o -o crate.nes
```

## Files

- `crate.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `crate.nes` - Compiled ROM
