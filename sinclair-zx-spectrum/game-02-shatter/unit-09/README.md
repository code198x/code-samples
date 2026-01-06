# Unit 9: Brick Grid

Draw the brick layout.

## What This Unit Covers

- Brick grid data structure
- Drawing bricks using UDG characters
- Colour variation per row

## Key Concepts

| Concept | Description |
|---------|-------------|
| Grid size | 14 columns × 6 rows typical |
| Brick state | 1 = present, 0 = destroyed |
| UDG printing | RST $10 with character code |
| Row colours | Different attribute per row |

## Brick Grid

```asm
BRICK_COLS = 14
BRICK_ROWS = 6

brick_grid:
    ; 6 rows × 14 columns = 84 bytes
    defb 1,1,1,1,1,1,1,1,1,1,1,1,1,1  ; Row 0
    defb 1,1,1,1,1,1,1,1,1,1,1,1,1,1  ; Row 1
    defb 1,1,1,1,1,1,1,1,1,1,1,1,1,1  ; Row 2
    defb 1,1,1,1,1,1,1,1,1,1,1,1,1,1  ; Row 3
    defb 1,1,1,1,1,1,1,1,1,1,1,1,1,1  ; Row 4
    defb 1,1,1,1,1,1,1,1,1,1,1,1,1,1  ; Row 5

row_colours:
    defb %00000010  ; Red
    defb %00000110  ; Yellow
    defb %00000100  ; Green
    defb %00000101  ; Cyan
    defb %00000001  ; Blue
    defb %00000011  ; Magenta
```

## Drawing

```asm
draw_bricks:
    ld hl, brick_grid
    ld de, BRICK_START_ADDR
    ld b, BRICK_ROWS

draw_row:
    push bc
    ld b, BRICK_COLS

draw_col:
    ld a, (hl)
    or a
    jr z, skip_brick
    ; Print brick UDG here

skip_brick:
    inc hl
    inc de
    inc de              ; 2 chars per brick
    djnz draw_col
    pop bc
    djnz draw_row
    ret
```

## Expected Result

6 rows of coloured bricks at top of playfield.

## Building

```bash
pasmonext --tapbas shatter.asm shatter.tap
```

## Files

- `shatter.asm` - Assembly source
- `shatter.tap` - Tape image
