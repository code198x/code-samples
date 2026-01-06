# Unit 14: High Scores

16-bit high score comparison and persistence.

## What This Unit Covers

- 16-bit comparison for high score check
- High score storage in memory
- New high score detection
- High score display on game over
- Score persistence during session

## Building

```bash
acme -f cbm -o symphony.prg symphony.asm
```

## Running

Load `symphony.prg` in VICE or on real hardware. Your best score is tracked across games within the session.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| 16-bit compare | Compare high byte first, then low byte |
| Score persistence | Variables survive game restart |
| New high flag | Track if current game set new record |
| Conditional display | Show "NEW HIGH!" message when appropriate |

## Comparison Logic

```asm
; Compare score_hi:score_lo vs high_hi:high_lo
    lda score_hi
    cmp high_hi
    bcc not_new        ; score < high
    bne is_new         ; score > high
    lda score_lo
    cmp high_lo
    bcc not_new        ; score < high
is_new:
    ; New high score!
```

## Files

- `symphony.asm` - Assembly source
- `symphony.prg` - Compiled C64 executable
