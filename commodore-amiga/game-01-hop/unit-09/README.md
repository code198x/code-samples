# Unit 9: Lives and Scoring

Lives counter, score tracking, and HUD display.

## What This Unit Covers

- Lives counter variable
- Score accumulation
- HUD rendering with blitter
- Number-to-text conversion
- Game over detection

## Building

```bash
vasmm68k_mot -Fhunkexe -o hop hop.asm
```

## Running

Load `hop` in an emulator. Lives and score display at top of screen.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Lives variable | Starts at 3, decrements on death |
| Score storage | 32-bit for large values |
| HUD area | Top 16 scanlines reserved |
| Font blitting | Copy digit characters to screen |

## Score Display

```asm
draw_score:
    move.l  score,d0
    lea     score_buffer,a0
    moveq   #5,d7           ; 6 digits
.digit_loop:
    divu.w  #10,d0
    swap    d0
    add.b   #'0',d0
    move.b  d0,-(a0)
    swap    d0
    ext.l   d0
    dbf     d7,.digit_loop
```

## Files

- `hop.asm` - Assembly source
- `hop` - Compiled Amiga executable
