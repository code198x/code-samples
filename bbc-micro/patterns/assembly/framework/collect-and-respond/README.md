# Move, collect and respond — bbc-micro

Move the player onto the star. The visible count changes from 0 to 1 and a short sound plays. Stay on the star: it must not score again. Press Space to restore it and return the player to the starting cell. Holding restart does not continually reset the game.

Target: **BBC Model B, MOS 1.20/BASIC II, Q/A/O/P and Space**. Type build/loader.bas into BASIC, then RUN. There is one collectible, not a level engine. This small caller makes the joints between reusable routines visible.

## Build and take the routines

Run `make` here with Asm198x available. Keep this repository's relative include layout. The Makefile produces the program in `build/`. Reused code: `../game-loop/frame.inc` (MOS display-sync wait); the new input/drawing/SOUND wrappers use MOS entry points.

`demo.asm` owns startup, state allocation and the call order. `rules.inc` supplies press/release detection, bounded movement, reset and collection; `collision.inc` supplies a reusable box-overlap test; `draw.inc` supplies the screen adapter; `sound.inc` supplies the feedback adapter. `input.inc` reads five keys without consuming buffered text.

To adapt one part, copy its include and the state/constants it references, or retain the repository layout and include it once. Include the maintained dependencies too; these wrappers do not embed private copies of the original input/audio routines. Resolve ownership before combining with a renderer, music player or IRQ handler of your own.

## Frame order and contracts

1. Wait for the next machine frame announcement.
2. Read input once and calculate held/newly pressed/released state.
3. Service the preceding sound duration where the hardware permits asynchronous playback.
4. On a new restart press, restore the initial state. Otherwise move when the repeat counter permits it, then test collection.
5. Erase the previous player cell, redraw the item if active, draw the player and update the count.

The grid is **16 × 10 cells**. `player_x` is 0–15, `player_y` is 0–9; initial position is (2,5). The item occupies (10,5). The movement counter permits one cell per six accepted updates, including while a direction is held. Diagonals move on both axes; opposing directions are processed left/right then up/down, so they can behave asymmetrically at a boundary. A game may choose cancellation or last-direction priority instead.

`previous`, `pressed` and `released` are sampled input masks. `reset_game` deliberately preserves input history: clearing it while a button is held would invent a fresh press. `item_active` is 1 or 0, and `score` is 0 or 1. Consume the item **before** triggering feedback. `old_x/old_y` belong to drawing. `move_delay` belongs to movement. Sound timing belongs to MOS. State is bytes. Do not let an interrupt or another routine write it concurrently.

Register effects across these routines: A/X/Y and flags; keep all wrappers out of IRQ code.

Resources: MODE 6 screen, program at $3000 and MOS SOUND channel 1. HIMEM reserves program space before DATA loads it. MOS keeps IRQ, keyboard and audio service. Reset to leave.

## Drawing, collision and cost

MOS VDU31 cursor positioning and ASCII text. MODE6 cells are taller than the 8×8 glyphs in the other versions. Erasing the old cell is safe because this scene has a blank background. On a tile map, restore the underlying tile rather than painting a blank. Several overlapping objects need an agreed draw order or a different renderer.

`boxes_overlap` tests half-open rectangles: touching an edge does not count. It rejects empty or reversed rectangles. Supply left, top, right and bottom in one agreed coordinate unit, and form those edges without arithmetic wrap. Here one cell is one unit, so a player at (x,y) has edges (x,y,x+1,y+1). The target occupies (10,5,11,6). The same test can use pixel coordinates for freely positioned objects.

The 8-bit versions use byte edges; the Amiga uses word edges. The NES example keeps the fixed target rectangle in ROM; move that declaration into writable state when a game needs movable targets. A multi-cell movement step can still skip a collision: a box test checks the sampled positions, not the path between them. Tile traversal or a swept test solves that different problem.

The grid version could use two coordinate-equality checks instead. The general box routine does more work but accommodates differently sized rectangles and rejects invalid bounds. A mask test can follow a cheap box rejection when the shape detail is worth the additional code, data and runtime cost. None of those choices is automatically best for the player.

No cycle-count or benchmark claim is made. The build artefact gives code/data size for this configuration; the whole build includes startup and shared routines. The Amiga plane is 10,240 bytes, NES CHR allocation is 8 KiB, and the Spectrum screen uses the existing 6,912-byte display. These storage choices do not imply equal runtime cost. Frame-based repeat gives a different wall-clock speed at 50 and 60 Hz; elapsed-time movement is a later alternative.

## Reproduce the checks

From the repository root:

```sh
python3 scripts/verify-collect-and-respond.py --only bbc --native /path/to/native/binaries --build198x /path/to/build198x
```

Use `--firmware-root` for local firmware; none is distributed. The verifier builds, starts through the stated path, drives real keys/controllers and checks idle stability, movement, all four bounds, collection once and restart while held. It captures the actual picture and PCM, then requires the same collection guard to reject a broken caller. `verification/results.json` records exact source, binary, firmware and emulator identities and limitations. Changing PCM proves output, not pitch accuracy or original-hardware conformance. Spectrum snapshot execution and tape loading are separate claims.
