# Crates: three-room prototype

A three-room investigation for stock 48K ZX Spectrum, PAL, Sinclair BASIC. The six legacy lesson samples are unchanged. The three-room game and visual direction are accepted after native play. This prototype is the behavioural reference for the replacement course, not its lesson sequence.

## Play

Load the generated `crates1.tap` in a 48K Spectrum emulator; it starts at line 10. Press S at the instructions. I moves up, J left, K down and L right. R restarts or replays the room, and Q quits. No Enter is needed. Press and release for each step. Uppercase and lowercase commands work.

Push the wooden crate onto the cyan target ring. The white figure is the player. Delivered crates turn green; a player standing on a target retains its ring and turns cyan. Brickwork marks the walls. The counter counts successful player steps, including pushes; blocked actions and unrelated keys do not count. After rooms one and two, N continues to the next room. After room three, N starts a new game from room one. R replays the current room and Q quits; movement cannot dismiss the result. The game is silent.

The first one-crate room is deliberately introductory. It tests whether the controls, push rule, target display and recovery are clear. A short solution is expected. Room two requires a sideways reposition before the crate can approach its target. A legal push into the right-hand nook leaves it trapped, so the player must inspect access before pushing. Human play must judge whether that choice is clear and enjoyable.

## Model and display

`g(row,column)` holds floor 0, wall 1, target 2, crate 3, or crate-on-target 4. `pr` and `pc` hold the player separately. The source constructs three known valid rooms with explicit assignments; there is no DATA loader or map-format validator yet.

Walking checks bounds and the destination. Pushing additionally checks bounds and the cell beyond the crate before changing either cell. A failed move preserves the whole grid, player and move count. Moving a crate off a target restores code 2. The player overlay leaves the underlying grid value unchanged. No ATTR or screen colour is used for collision or victory.

The cell routine draws the stored value and then overlays the player. Both movement and a complete redraw use it. Twenty original UDGs form 16×16-pixel brick, target, crate and player tiles. DATA defines the graphics; the room itself still uses explicit assignments. Colours can change without changing the rules. The remaining-target count is initialised once per room and adjusted when a crate moves onto or off a target. Ordinary walking does not scan the board. Restart rebuilds the room and clears the count and completion state. Input remembers the previous INKEY$ value. An empty reading clears it; a different key is accepted immediately, without an extra release wait. Holding the same direction produces one step. Simultaneous ordinary keys report an empty string. Very short taps entirely within a drawing operation can still be missed: this is polled BASIC input, not a queued keyboard.

The first room starts at player `(6,3)`, crate `(5,4)` and target `(3,5)`, with internal walls `(3,4)` and `(4,4)`. Perimeter cells are walls. The verification solution is `I L K L I I`: six player steps, three pushes. It is a correctness example, not a displayed par or a claim about human difficulty.

The second room starts at player `(6,5)`, crate `(5,5)` and target `(3,5)`. Its internal walls are `(3,6)`, `(4,5)`, `(4,6)` and `(5,7)`. A breadth-first search finds `L I J K J I I J I L`: ten steps, four pushes. The runner executes that solution in BASIC. It also executes `J I L`, independently exhausts the reachable states to establish that the resulting position cannot be solved, then checks restart. These are authoring checks; neither solutions nor warnings are shown during play.

The third room has two targets in a narrow aisle at `(2,4)` and `(3,4)`, two crates at `(4,4)` and `(5,4)`, and the player at `(6,4)`. Rows 2 and 3 are walls except for the aisle. The lower area is open within the perimeter. A crate occupies the standing space needed to push its neighbour, so the player must make room before delivering them. The solver finds `J I L I I K L L K J K J I I`: fourteen steps, six pushes. The runner checks that the initial pair cannot be pushed, that one occupied target does not complete the room or allow N to advance, and that both occupied targets do. Restart restores both crates and both targets.

## Reproduce

With a released Emu198x Spectrum binary and a configured, lawfully supplied 48K ROM:

```sh
python3 verification/verify.py --emulator /path/to/emu198x-spectrum --output /tmp/crates-prototype
```

Source is entered through ROM keyboard events. The output directory retains a tape and hash-checked record of that ROM-entered program, so repeating a run can load those same stored bytes without typing the whole listing again. The runner independently computes expected grid transitions and compares all 64 cells, player coordinates, count and completion state. Screen and numeric/array memory reads are observations only. Test fixtures are explicit ROM-entered replacements for lines 60, 70 and 80, restored before saving. Tape creation uses ROM SAVE; a fresh emulator loads it, solves all three rooms, restarts the current room, replays, starts a new game and exits.

Execution passed on Emu198x Spectrum 0.25.0 with the configured 48K ROM. The fifteen check groups, configuration hashes and input trace are recorded in `verification/results.json`; thirteen visually inspected captures and their manifest are in `captures/`. Scripted keyboard events do not establish native host input, human enjoyment or original-hardware compatibility. Three fixed valid maps do not establish a loader's validation behaviour. Undo, a map loader and sound are not implemented.

## Response time

`verification/timing.py` measures a three-frame key press through return to the BASIC input loop, including drawing. For the two-room source hash recorded in `verification/timing.json`, on the 48K PAL configuration, the initial upward walk takes 26 frames (0.52 seconds) and the following push 37 frames (0.74 seconds). The initial prototype took 78 and 88 frames respectively under the same method. This samples those two actions, not every move or native host latency; BASIC still has a noticeable processing pause. Hashes and observations are in `verification/timing.json`.

```sh
python3 verification/timing.py --emulator /path/to/emu198x-spectrum --tape /tmp/crates-prototype/crates1.tap --output /tmp/crates-prototype/timing.json
```

## Sources and licence

Steven Vickers, edited by Robin Bradbeer, *ZX Spectrum BASIC Programming*, second edition (Sinclair Research, 1983): chapters 4–6 (loops, routines and DATA), 7–9 (variables and expressions), 12 (arrays), 14–16 (UDGs, display and colour), 18, page 131 (INKEY$ and release/press loops), and 20 (tape). The room layout, program and character graphics are original material under this repository's MIT licence. The five-state grid is adapted from the existing Crates samples; the ROM-entry helper is adapted from the verified Sonar helper.
