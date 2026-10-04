# Let the title play itself

A title screen that waits in silence gives a passer-by nothing to look at. Arcade machines and many home computer games of the period played themselves while nobody was pressing anything: an attract mode. This program runs the first storm behind the title, without a ship, and makes the prompt flash.

Nothing new is needed to run a storm. The title clears the run's block of memory, as `new_game` does, and calls `start_storm` for the first course. Its wait loop then does on every second frame what the main loop does each update, through a new routine, `attract_step`: `advance_meteors`, `waves`, `count_objects` and one more course step in `ticks`. When the course is over and the playfield is empty, it calls `start_storm` again and the storm starts over.

There is no ship to hit. `advance_meteors` would still test every object near the bottom against `ship_x`, so the contact test now starts by reading `phase`: 0, the title, skips it. Stars fall past untouched for the same reason.

The title text is drawn once, with ordinary stores. The meteors and stars are drawn over it with `draw_sprite`, which uses XOR, as everything that moves has since unit 2: drawing a sprite and drawing it again at the same place gives back exactly what was there. While a meteor crosses METEOR STORM its pixels and the letters' combine; when it moves on, the letters return unchanged.

The prompt flashes without being redrawn. Bit 7 of an attribute byte is FLASH: the ULA swaps the cell's INK and PAPER every 16 frames. The title sets bit 7 in all 32 attribute bytes of the prompt's row with `set 7,(hl)`. A flashing row that a meteor fell through would make the meteor flash too, so the prompt moves to row 1, above the course, which starts at y=24, row 3. The voyage record moves up to row 20 in its place. Pressing Space starts `new_game`, whose `clear` repaints every row from the colour table, so the flashing stops.

Predict, then check: replace `set 7,(hl)` with `set 7,(hl)` in a loop over row 10 instead of row 1 (`ld hl,$5800+320`). What happens when a meteor falls through row 10? Then remove the three lines that skip contact on the title, and predict what the attract storm does to `hull`... the first meteor to reach X 116 at the bottom clears it, though nothing reads it until a run starts and `new_game` sets it again.

Leave the title for a while: meteors and stars fall through the title's colour bands, crossing the text and leaving it intact, and SPACE TO LAUNCH flashes at the top. About 36 seconds in, the course ends and starts again. Space launches as before, onto an empty playfield.

Sources: the ZX Spectrum BASIC manual, chapter 16 (Colours), for FLASH as 128 in an attribute and its alternation of INK and PAPER; the Zilog Z80 CPU User Manual for `SET b,(HL)`.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
