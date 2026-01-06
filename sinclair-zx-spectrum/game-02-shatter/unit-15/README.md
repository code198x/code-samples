# Unit 15: Level Progression

Multiple levels with different layouts.

## What This Unit Covers

- Level data storage
- Level completion detection
- Increasing difficulty

## Key Concepts

| Concept | Description |
|---------|-------------|
| Level complete | All bricks destroyed |
| Level data | Different brick patterns |
| Difficulty | Faster ball, fewer power-ups |
| Level counter | Track current level |

## Level Data

```asm
level_number:   defb 1

level_1:
    defb 1,1,1,1,1,1,1,1,1,1,1,1,1,1
    defb 1,1,1,1,1,1,1,1,1,1,1,1,1,1
    defb 1,1,1,1,1,1,1,1,1,1,1,1,1,1
    defb 1,1,1,1,1,1,1,1,1,1,1,1,1,1
    defb 1,1,1,1,1,1,1,1,1,1,1,1,1,1
    defb 1,1,1,1,1,1,1,1,1,1,1,1,1,1

level_2:
    defb 1,0,1,0,1,0,1,0,1,0,1,0,1,0
    defb 0,1,0,1,0,1,0,1,0,1,0,1,0,1
    defb 1,0,1,0,1,0,1,0,1,0,1,0,1,0
    defb 0,1,0,1,0,1,0,1,0,1,0,1,0,1
    defb 1,0,1,0,1,0,1,0,1,0,1,0,1,0
    defb 0,1,0,1,0,1,0,1,0,1,0,1,0,1
```

## Level Completion

```asm
check_level_complete:
    ld hl, brick_grid
    ld bc, BRICK_ROWS * BRICK_COLS
    xor a                   ; Looking for any 1

check_loop:
    cp (hl)
    jr nz, not_complete     ; Found a brick
    inc hl
    dec bc
    ld a, b
    or c
    jr nz, check_loop

    ; All bricks gone!
    call next_level
    ret

not_complete:
    ret
```

## Expected Result

Clearing all bricks advances to next level with new pattern and faster ball.

## Building

```bash
pasmonext --tapbas shatter.asm shatter.tap
```

## Files

- `shatter.asm` - Assembly source
- `shatter.tap` - Tape image
