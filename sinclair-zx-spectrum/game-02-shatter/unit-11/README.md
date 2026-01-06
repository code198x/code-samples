# Unit 11: Score Display

Track and display the player's score.

## What This Unit Covers

- Score variable (multi-byte)
- Adding points for bricks
- Printing numbers to screen

## Key Concepts

| Concept | Description |
|---------|-------------|
| Score storage | 2-3 bytes for larger scores |
| Points per brick | 10 for bottom rows, more for top |
| Number printing | Convert binary to decimal characters |
| Display position | Fixed location on screen |

## Score Handling

```asm
score_lo:   defb 0
score_hi:   defb 0

add_score:
    ; Add points in A to score
    ld b, a
    ld a, (score_lo)
    add a, b
    ld (score_lo), a
    jr nc, display
    ld a, (score_hi)
    inc a
    ld (score_hi), a

display:
    call print_score
    ret
```

## Number Printing

```asm
print_score:
    ; Convert 16-bit score to decimal
    ; Print at fixed screen position
    ld hl, (score_lo)
    ld de, SCORE_POSITION
    ; ... conversion and printing
    ret
```

## Expected Result

Score displayed on screen. Increases by 10 points per brick destroyed.

## Building

```bash
pasmonext --tapbas shatter.asm shatter.tap
```

## Files

- `shatter.asm` - Assembly source
- `shatter.tap` - Tape image
