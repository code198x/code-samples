# Unit 13: Enemy Movement

Animate enemies with patrol patterns.

## What This Unit Covers

- Patrol movement (left/right)
- Edge detection
- Direction reversal

## Key Concepts

| Concept | Description |
|---------|-------------|
| Patrol | Walk back and forth |
| Edge detect | Check for platform edge |
| Direction | Store facing for each enemy |
| Speed | Pixels per frame |

## Enemy Movement Data

```asm
enemy_dir:      .res MAX_ENEMIES    ; 1 = right, -1 = left
ENEMY_SPEED = 1
```

## Patrol Logic

```asm
update_enemies:
    ldx #0

@loop:
    lda enemy_active,x
    beq @next

    ; Move in current direction
    lda enemy_x,x
    clc
    adc enemy_dir,x
    sta enemy_x,x

    ; Check for edge or wall
    jsr check_enemy_edge
    bcc @no_reverse

    ; Reverse direction
    lda enemy_dir,x
    eor #$FF
    clc
    adc #1                  ; Negate
    sta enemy_dir,x

@no_reverse:
@next:
    inx
    cpx #MAX_ENEMIES
    bne @loop
    rts
```

## Edge Detection

```asm
check_enemy_edge:
    ; Check tile below and ahead
    lda enemy_x,x
    clc
    adc enemy_dir,x         ; Position we're moving to
    adc enemy_dir,x
    adc enemy_dir,x
    adc enemy_dir,x         ; Look 4 pixels ahead
    jsr pixel_to_tile
    sta temp_x

    lda enemy_y,x
    clc
    adc #16                 ; Below feet
    jsr pixel_to_tile
    sta temp_y

    ; Is there ground ahead?
    jsr check_tile_solid
    beq @edge               ; No ground = edge

    clc                     ; No edge
    rts

@edge:
    sec                     ; At edge
    rts
```

## Expected Result

Enemies walk back and forth on platforms, turning at edges.

## Building

```bash
ca65 crate.asm -o crate.o
ld65 -C nes.cfg crate.o -o crate.nes
```

## Files

- `crate.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `crate.nes` - Compiled ROM
