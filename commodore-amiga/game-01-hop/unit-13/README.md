# Unit 13: High Score Table

Score persistence and high score display.

## What This Unit Covers

- High score comparison
- Score table storage
- Table sorting
- Name entry (optional)
- High score display

## Building

```bash
vasmm68k_mot -Fhunkexe -o hop hop.asm
```

## Running

Load `hop` in an emulator. High scores persist during session.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Score table | Array of top scores |
| Comparison | Check if current beats any entry |
| Insertion | Shift lower scores down |
| Display format | Rank, score, position |

## High Score Check

```asm
check_high_score:
    move.l  score,d0
    lea     high_scores,a0
    moveq   #4,d7           ; 5 entries
.check_loop:
    cmp.l   (a0)+,d0
    bhi.s   .new_high
    dbf     d7,.check_loop
    rts                     ; Not a high score
.new_high:
    ; Insert score at position d7
    ...
```

## Files

- `hop.asm` - Assembly source
- `hop` - Compiled Amiga executable
