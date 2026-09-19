# Night Patrol — native stealth trial

A 30 × 18 archive in stock 48K PAL Sinclair BASIC. Take the file and return to
the entrance without entering the guard's amber field of view. Narrow patrol
corridors connect wider corners; recesses offer cover behind walls.

- S starts; I/J/K/L move up/left/down/right. Hold to repeat.
- R restores the trial; Q quits to BASIC.
- The patrol continues while you stand still. At each corner, the guard stops
  to look back, then checks the next corridor before moving. Its arrow and fan
  show each change in facing.
- Both entering its current sight and being reached by its next sight cause
  capture. Guard contact also causes capture.
- Results freeze the world. Release the last key before retrying or quitting.

The fan extends up to five cells forward and widens with distance. Walls block
sight, including diagonals touching wall corners. Amber backgrounds show the
actual detection mask, not a decorative approximation. The file and entrance
have distinct glyphs. There are no lives, score, sound or random layouts.

## BASIC performance and level data

The logical map owns collision. A string mask owns current visibility. Screen
attributes display that mask; the game never reads screen colour for collision
or detection. The guard advances every second player update, with at least eight
PAL frames between completed updates. BASIC work adds to that wait.

`verification/level.py` prepares ordinary DATA statements for this fixed map and
patrol. Each record gives the guard position, facing, visible count and cells
entering or leaving sight. Positive cells enter, negative cells leave; a cell
is encoded as `32 * row + column`. At runtime BASIC changes just those mask
characters and screen attributes. No host program or machine code runs the game.
The initial sight has its own record; 60 walking and scanning phases then repeat.
Each corner scan changes facing without moving the guard. Each facing lasts
one guard interval (two player updates).

This is a prototype performance choice, not an agreed lesson sequence. The
geometry generator remains inspectable and must be rerun when the map, patrol
or fan changes. The map is prepared once at startup and reused on retry.

## Reproduce

Set `EMU198X_SPECTRUM` to the native executable with a configured 48K ROM, then
run from this directory:

```sh
python3 verification/level.py
python3 verification/model.py
python3 verification/build.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence
python3 verification/check.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence
python3 verification/capture.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence
python3 verification/audit.py
"$EMU198X_SPECTRUM" --machine spectrum_48k --tape verification/evidence/night-patrol.tap --autoload-tape --scale 3
```

The builder enters source through ROM keyword keys and records
`SAVE "patrol" LINE 10`. Native checks load the tape fresh, drive ordinary keys
and read BASIC state without writing it. They compare every map cell's visibility
and game transitions with the coordinate model. Route search assists verification;
it does not establish difficulty or enjoyable play. The audit checks generated
DATA, source/tape identities, stored tokens and TAP checksums.

The checker advances against the ROM interrupt counter after CPU stepping because
mixing debug stepping and frame runs did not advance execution consistently in
the recorded binary. Captures are diagnostic evidence; inspect before public use.
The debug-stepped PNGs can be blank in this binary; `capture.py` produces
`live-frames.png` using ordinary frame advancement. That capture has been inspected.
The user approved this corner-scanning prototype. Preserve it as the gameplay
endpoint for lesson planning. No lessons or publication are included.
