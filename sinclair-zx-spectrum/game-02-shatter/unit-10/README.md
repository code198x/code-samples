# Unit 10: Brick Collision

Detect and remove bricks when hit.

## What This Unit Covers

- Converting ball position to grid coordinates
- Checking brick state
- Removing brick on hit

## Key Concepts

| Concept | Description |
|---------|-------------|
| Grid mapping | Ball X,Y → brick column,row |
| Collision check | Is brick present at that cell? |
| Removal | Set grid cell to 0, erase from screen |
| Bounce | Reverse ball direction on hit |

## Grid Mapping

```asm
check_brick_collision:
    ; Convert ball Y to row
    ld a, (ball_y)
    sub BRICK_TOP_Y
    jr c, no_brick          ; Above brick area
    cp BRICK_AREA_HEIGHT
    jr nc, no_brick         ; Below brick area

    ; A = row offset in pixels
    srl a
    srl a
    srl a                   ; Divide by 8 = row number
    ld d, a                 ; D = row

    ; Convert ball X to column
    ld a, (ball_x)
    sub BRICK_LEFT_X
    srl a
    srl a
    srl a
    srl a                   ; Divide by 16 = column
    ld e, a                 ; E = column

    ; Check grid
    call get_brick
    or a
    jr z, no_brick

    ; Hit! Remove brick
    call remove_brick
    call bounce_vertical

no_brick:
    ret
```

## Expected Result

Ball destroys bricks on contact. Brick disappears and ball bounces.

## Building

```bash
pasmonext --tapbas shatter.asm shatter.tap
```

## Files

- `shatter.asm` - Assembly source
- `shatter.tap` - Tape image
