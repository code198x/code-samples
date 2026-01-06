# Unit 13: Sound Effects

Add beeper audio feedback.

## What This Unit Covers

- Beeper sound generation
- Pitch variation for different events
- Short, non-blocking sounds

## Key Concepts

| Concept | Description |
|---------|-------------|
| Beeper port | OUT to port $FE, bit 4 |
| Pitch | Delay between toggles |
| Duration | Number of cycles |
| Events | Wall hit, paddle hit, brick hit, ball lost |

## Beeper Routine

```asm
; Play beep: B = pitch (higher = lower note), C = duration
beep:
    ld a, %00010000     ; Beeper bit
beep_loop:
    out ($FE), a
    xor %00010000       ; Toggle beeper

    ; Pitch delay
    ld d, b
pitch_delay:
    dec d
    jr nz, pitch_delay

    dec c
    jr nz, beep_loop
    ret
```

## Sound Events

```asm
sound_wall:
    ld b, 100           ; Medium pitch
    ld c, 10            ; Short
    jp beep

sound_paddle:
    ld b, 60            ; Higher pitch
    ld c, 15
    jp beep

sound_brick:
    ld b, 40            ; High pitch
    ld c, 20
    jp beep

sound_lost:
    ld b, 200           ; Low pitch
    ld c, 50            ; Longer
    jp beep
```

## Expected Result

Different sounds for wall bounces, paddle hits, brick destruction, and ball loss.

## Building

```bash
pasmonext --tapbas shatter.asm shatter.tap
```

## Files

- `shatter.asm` - Assembly source
- `shatter.tap` - Tape image
