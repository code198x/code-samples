# Unit 15: Time Limit

Timer mechanics for added challenge.

## What This Unit Covers

- Frame-based timer
- Timer display bar
- Time bonus scoring
- Timeout death
- Timer reset on respawn

## Building

```bash
vasmm68k_mot -Fhunkexe -o hop hop.asm
```

## Running

Load `hop` in an emulator. A timer bar depletes; reach home before it empties.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Frame counter | Decrement each frame |
| Timer bar | Visual width based on time left |
| Time bonus | More points for faster completion |
| Timeout | Death when timer reaches zero |

## Timer Display

```asm
update_timer:
    tst.w   timer
    beq.s   .timeout
    subq.w  #1,timer
    ; Draw timer bar
    move.w  timer,d0
    lsr.w   #2,d0           ; Scale to pixels
    jsr     draw_timer_bar
    rts
.timeout:
    jsr     death
```

## Time Bonus

| Time Remaining | Bonus |
|----------------|-------|
| > 75% | 1000 |
| > 50% | 500 |
| > 25% | 200 |
| > 0% | 100 |

## Files

- `hop.asm` - Assembly source
- `hop` - Compiled Amiga executable
