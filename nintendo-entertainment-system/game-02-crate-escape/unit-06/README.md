# Unit 6: Jump Physics

Implement jumping with button press.

## What This Unit Covers

- Jump impulse (initial velocity)
- Variable jump height
- Jump state tracking

## Key Concepts

| Concept | Description |
|---------|-------------|
| Impulse | Negative velocity to go up |
| Variable height | Release button = reduce velocity |
| Grounded check | Can only jump when on ground |
| Edge detection | Jump on press, not hold |

## Jump Implementation

```asm
BUTTON_A     = %10000000
JUMP_IMPULSE = -8           ; Negative = upward

player_grounded:    .res 1  ; 1 = on ground
buttons_prev:       .res 1

check_jump:
    ; Only jump if grounded
    lda player_grounded
    beq @done

    ; Check A button pressed (not held)
    lda buttons
    and #BUTTON_A
    beq @done
    lda buttons_prev
    and #BUTTON_A
    bne @done               ; Was already pressed

    ; Jump!
    lda #JUMP_IMPULSE
    sta player_vel_y
    lda #0
    sta player_grounded

@done:
    rts
```

## Variable Jump Height

```asm
check_jump_release:
    ; If button released and moving up, reduce velocity
    lda player_vel_y
    bpl @done               ; Already falling

    lda buttons
    and #BUTTON_A
    bne @done               ; Still holding

    ; Cut velocity for shorter jump
    lda player_vel_y
    asr a                   ; Halve upward velocity
    sta player_vel_y

@done:
    rts
```

## Expected Result

Pressing A makes player jump. Releasing early = shorter jump.

## Building

```bash
ca65 crate.asm -o crate.o
ld65 -C nes.cfg crate.o -o crate.nes
```

## Files

- `crate.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `crate.nes` - Compiled ROM
