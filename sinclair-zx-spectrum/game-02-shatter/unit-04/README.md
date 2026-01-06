# Unit 4: Paddle Movement

Move paddle with keyboard input.

## What This Unit Covers

- Reading keyboard matrix
- Erase-move-draw cycle
- Movement speed and boundaries

## Key Concepts

| Concept | Description |
|---------|-------------|
| Keyboard port | IN from port $FE with row in high byte |
| O key | Port $DFFE, bit 1 |
| P key | Port $DFFE, bit 0 |
| Movement cycle | Erase old → Update position → Draw new |

## Keyboard Reading

```asm
read_keys:
    ld bc, $DFFE        ; Row with O and P
    in a, (c)

    bit 1, a            ; O key (left)
    jr nz, check_right
    ; Move left
    ld a, (paddle_x)
    cp 8                ; Left boundary
    jr c, check_right
    sub 4               ; Move speed
    ld (paddle_x), a

check_right:
    bit 0, a            ; P key (right)
    jr nz, done_keys
    ; Move right
    ld a, (paddle_x)
    cp 224              ; Right boundary
    jr nc, done_keys
    add a, 4
    ld (paddle_x), a

done_keys:
    ret
```

## Expected Result

Paddle moves left and right with O/P keys, stops at screen edges.

## Building

```bash
pasmonext --tapbas shatter.asm shatter.tap
```

## Files

- `shatter.asm` - Assembly source
- `shatter.tap` - Tape image
