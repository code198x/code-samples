# Quickstep — crossing and timing prototype

Stock 48K PAL Sinclair BASIC. Cross six predictable vehicle lanes, pause on the central dotted blue strip, and reach the green exit at the top. One screen, original UDG artwork, no machine-code helper and deliberate silence.

The user agreed to prototype this direction after Drift, then found the first board too easy and too small. This revision fills 30 × 18 character cells with two banks of three lanes. This is a native play trial, not an approved endpoint or authored lesson sequence.

## Play

Load `verification/evidence/quickstep.tap` through the 48K ROM. It starts at line 10.

- **S** starts.
- **I / J / K / L** move up / left / down / right.
- **R** resets the crossing and every vehicle phase.
- **Q** quits from the title, play or result screen.

Hold a movement key to repeat. A recognised short press queues a move; another direction can replace it before the next step. Release to wait. A buffered step may still happen after release. Resting strips are safe; the lanes keep moving while you wait.

A step first checks the current vehicles, then checks again after due vehicles advance. Enter a clear gap: a vehicle leaving that cell during the same beat does not make it safe to step into yet. Collision uses the full logical rectangles, including transparent artwork corners. Only the centre exit tile wins; the rest of the top strip is safe ground.

The 15-column, nine-row board has safe ground at the start, halfway point and finish. Each lane carries three two-cell vehicles, leaving three-cell gaps. The six lanes alternate direction and advance every three, four, two, three, four and two updates from top to bottom. Stored phases and separate countdowns make retries deterministic. Vehicles wrap at the edges. A 32-frame target spaces update starts. Busy updates can take longer; the game never runs catch-up steps in a burst. The ROM key latch retains recognised presses during drawing, and each beat consumes one command.

## Build and verify

From this directory, with a current Emu198x Spectrum binary and a lawfully supplied stock 48K ROM configured:

```sh
python3 verification/build.py --emulator /path/to/emu198x-spectrum --output verification/evidence
python3 verification/check.py --emulator /path/to/emu198x-spectrum --output verification/evidence
python3 verification/frames.py --emulator /path/to/emu198x-spectrum --output verification/evidence
python3 verification/audit.py
```

`build.py` enters every line through ROM keyword keys, checks stored line identities and records SAVE output. The game loads from that tape in fresh emulator processes. Verification sends keyboard events and reads state; it does not inject positions or change simulation variables. The state-model checks use CPU statement boundaries; `frames.py` separately observes ordinary video frames, input, timing and original captures.

All artwork is original and stored in the source DATA. Each 16×16 player uses four UDGs; each 32×16 vehicle uses eight. A thirteenth UDG provides the safe-strip texture. Lane strings rotate by two characters while stored numeric phases determine collision.

The ROM key latch and frame counter are documented in Steven Vickers, edited by Robin Bradbeer, *ZX Spectrum BASIC Programming*, second edition (Sinclair Research, 1983), [chapter 25](https://worldofspectrum.org/ZXBasicManual/zxmanchap25.html). PEEK 23560 recovers a recognised key that arrived between BASIC polls; POKE clears a consumed latch. It is not a queue of every key pressed. Simultaneous keys and taps too short for ROM scanning are not guaranteed.
