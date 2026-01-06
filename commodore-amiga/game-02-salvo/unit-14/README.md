# Unit 14: Score Display

Track and display the player's score.

## What This Unit Covers

- Score variable
- Blitter text rendering
- Score update on enemy kill

## Key Concepts

| Concept | Description |
|---------|-------------|
| Score storage | Long word for large scores |
| Points | 100 per enemy |
| Display | Blitter copy font to screen |
| Position | Top of screen |

## Score Handling

```asm
score:          dc.l    0
score_display:  dcb.b   8,' '   ; ASCII buffer

add_score:
    ; Add D0 to score
    add.l   d0,score
    bsr     update_score_display
    rts

update_score_display:
    ; Convert score to decimal string
    move.l  score,d0
    lea     score_display+7,a0

.convert:
    divu    #10,d0
    swap    d0
    add.b   #'0',d0
    move.b  d0,-(a0)
    clr.w   d0
    swap    d0
    tst.l   d0
    bne.s   .convert

    bsr     draw_score
    rts
```

## Blitter Text

```asm
draw_score:
    ; Use blitter to copy font characters
    ; to display at fixed position
    ; ...
    rts
```

## Expected Result

Score displayed at top of screen. Increases by 100 for each enemy destroyed.

## Building

```bash
vasmm68k_mot -Fhunkexe -o salvo salvo.asm
```

## Files

- `salvo.asm` - Assembly source
- `salvo` - Compiled executable
