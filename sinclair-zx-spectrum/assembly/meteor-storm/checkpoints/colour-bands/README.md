# Colour the storm by place

The game has always had colour. The previous program's `clear` blanked the bitmap, then wrote $47 to all 768 attribute bytes and $45 to the first 64. Each attribute byte colours one 8×8 character cell: bit 7 is FLASH, bit 6 BRIGHT, bits 5-3 the PAPER colour and bits 2-0 the INK colour. The screen has 24 rows of 32 cells, stored row by row from $5800, so the first 64 bytes are the top two rows.

| Byte | Binary | FLASH | BRIGHT | PAPER | INK |
|---|---|---|---|---|---|
| $47 | 0100 0111 | 0 steady | 1 bright | 000 black | 111 white |
| $45 | 0100 0101 | 0 steady | 1 bright | 000 black | 101 cyan |

So the whole screen was bright white on black, and the two rows that hold the time and the speed were bright cyan. That cyan band sets the readings apart from the storm, so the eye finds them without searching. The score, on row 2, was white.

Colour belongs to cells, not to objects. The meteors and the ship are drawn at any pixel position, so an object usually covers parts of three or four cells in each of two or three rows. If the game coloured an object by writing its cells, its colour would jump in 8-pixel steps as it moved, and any other object sharing one of those cells would take that colour too: colour clash. Spectrum games of the period often answered this by colouring by place instead. Each row of the screen has its own colour, and whatever passes through a row takes it on.

This program does that. `clear` now reads one byte per character row from the table `row_colours` and writes it to all 32 cells of that row:

| Rows | Byte | Colour |
|---|---|---|
| 0-1 | $45 | cyan: time and speed, as before |
| 2 | $47 | white: the score, as before |
| 3-6 | $45 | cyan |
| 7-10 | $44 | green |
| 11-14 | $46 | yellow |
| 15-19 | $42 | red |
| 20-23 | $47 | white: the ship, landed debris and the controls line |

Every byte is $40 plus an INK number: BRIGHT on, black PAPER, FLASH off. The storm runs from cool at the top to hot just above the ship. A meteor enters at row 3 cyan and turns green, yellow and red as it falls; the ship's rows stay white, the brightest colour. Blue (INK 1) is left out because it is hard to see on black.

Nothing writes attributes during play. The pixel routines only change the bitmap at $4000-$57FF, so the colours `clear` writes stay until the next `clear`. Every object in a row gets that row's INK and every cell has black PAPER, so two objects can never disagree about a cell's colour. A meteor straddling a band edge shows both colours, split along the row line, for the few updates it takes to cross. That is the band edge, which every object shares, not clash.

`clear` runs once for each screen: the title, each new run and each result. So the title and the results take the same bands, and their lines are cyan, green, yellow, red or white by where they sit. Writing 768 cells one at a time costs about 20,700 T-states, under a third of a frame and about 2,700 more than the old two fills (both a little more while the display shares that memory), once per screen and never in flight. The table sits outside the run block, so a retry cannot clear it.

The border colours are untouched: `border` still carries the red flash at contact, and every speaker write still ORs it in. Flight, collision, scoring, the course and the timing are unchanged, and the accepted keyboard routes finish with the same frames, times and scores as the previous program.

Predict, then check: colour the ship's own cell instead of its row. After `ld (ship_visible),a` in `draw_ship`, add

```asm
 ld a,(ship_x)
 rrca
 rrca
 rrca
 and 31          ; ship_x/8: the column of the ship's left cell
 add a,$80       ; row 20 starts at $5800+20*32 = $5A80
 ld l,a
 ld h,$5A
 ld (hl),$46     ; bright yellow INK on black PAPER
```

Steer left and right. Part of the ship turns yellow and the rest stays white, because the ship covers cells the colour was not written to. Every cell the ship has visited stays yellow after it leaves; on black PAPER an empty yellow cell looks black, until a meteor falls through it and turns yellow there. Remove the lines. Then subtract $40 from every byte of `row_colours`, turning BRIGHT off: the same gradient, dimmer, with white becoming grey. Finally make row 20's byte $42: the ship's top half turns red with the band above it.

Space launches; O/P steer; hold Space for 2X. One hit ends the run: the border flashes, the ship breaks apart for a second, then the result appears. At the result R retries and Q returns to the title.

Repeat: launch and leave the ship still. The first meteor falls through cyan, green, yellow and red and hits the white ship about 2.2 seconds after launch. Its lower half turns white as it crosses into row 20, and debris flying up through the red and yellow bands takes their colours.

Sources: the ZX Spectrum BASIC manual, chapter 16 (Colours) for the 24×32 character positions, one INK and one PAPER per position, the colour numbers 0-7 and ATTR's sum of 128 for FLASH, 64 for BRIGHT, 8×PAPER and INK; chapter 24 (The memory) for the attributes stored line by line from 22528 ($5800).

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
