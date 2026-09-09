# Touchdown prototype

A replacement for the earlier vertical instrument-led game: one moving lander, a fixed uneven landscape and a four-cell landing pad. Target: stock 48K ZX Spectrum, PAL, Sinclair BASIC. The published lessons remain unchanged while this prototype is reviewed.

## Play

S launches. O and P steer one column left and right; Space fires the engine. Steering and thrust can be held together. Opposing steering keys cancel. Q quits when pressed alone, after it is released. After contact, release the controls and press R to retry or Q to quit; the selected key must be released before the transition.

The pad is marked `====`. Land with a displayed downward speed from 0 to 12. The speed uses hundredths of a character row per update, not metres per second or a hardware-independent clock. Fuel exhaustion disables thrust but leaves gravity and steering working. Negative speed is upward movement. The upper boundary stops ascent; horizontal movement stays in columns 1–30.

Each attempt starts in the same place. Terrain blocks movement: crossing into a hillside is a collision even if the craft is climbing. The craft occupies one column; either outer pad column is a valid landing position. A proposed downward move reaching or crossing the ground is resolved at its surface, so a fast fall cannot tunnel through it.

## Checkpoints

| File | Runnable change |
|---|---|
| `steps/step-01.bas` | Constant-speed falling towards flat ground |
| `steps/step-02.bas` | Gravity, unlimited thrust and a safe-speed threshold |
| `steps/step-03.bas` | A fuel reserve that does not end the attempt when empty |
| `steps/step-04.bas` | Sideways movement, simultaneous thrust, a marked pad and retry on flat ground |
| `steps/step-05.bas` | Uneven terrain drawn and checked from the same height array |
| `steps/step-06.bas` | Custom craft/flame characters and short outcome sounds |

These are prototype checkpoints, not an agreed lesson count. Stage 4 combines several changes that should become smaller teaching steps. The keyboard-port reader and custom-character construction each need their own local explanation. Earlier stages use `A` for the craft; stages 4–5 use `*` while thrusting. The final two original glyphs occupy the same cell, keeping the flame within the collision footprint.

## Representation and drawing

`h(1)` through `h(32)` hold the first solid row in each screen column. The skyline is marked with `#`; PAPER fills the terrain below it. The pad replaces four skyline characters with `=`. The flight model stores vertical position in hundredths of a row and derives the displayed row with `INT`. Rendering does not decide contact.

The loop reads controls, updates speed, proposes a position, checks contact and boundaries, updates instruments, then clears and draws the craft consecutively. No sound runs during flight: the final version has short result sounds only, after movement has ended. PAUSE is interruptible, so held input and BASIC instruction costs can affect cadence. Frame measurements are configuration-specific observations, not a promised frame rate.

## ROM entry and verification

Keep the readable spaces in every source listing. `verification/entry.py` suppresses redundant token spaces only when sending ROM keyboard events. It preserves quoted strings and compound tokens.

Run the scripts with Python 3 and a released `emu198x-spectrum` executable, configured with a lawfully supplied 48K ROM:

```sh
python3 verification/build.py --emulator /path/to/emu198x-spectrum --output /tmp/touchdown-build
python3 verification/opening.py --emulator /path/to/emu198x-spectrum --output /tmp/touchdown-opening
python3 verification/flight.py --emulator /path/to/emu198x-spectrum --tape /tmp/touchdown-build/touchdown.tap --output /tmp/touchdown-flight
python3 verification/edges.py --emulator /path/to/emu198x-spectrum --tape /tmp/touchdown-flight/touchdown.tap --output /tmp/touchdown-edges
python3 verification/capture.py --emulator /path/to/emu198x-spectrum --tape /tmp/touchdown-flight/touchdown.tap --output /tmp/touchdown-captures
```

The build uses ROM keyboard entry and ROM tape saving. The flight checks use keyboard events and read-only memory inspection; explicitly labelled starting-line edits isolate boundary cases. Scripted success does not establish human enjoyment, original-hardware behaviour or native host-keyboard acceptance. Generated tapes are local outputs.

## Observed results

On Emu198x Spectrum 0.22.1 with the configured 48K ROM, all six checkpoints ran through contact. A scripted full approach landed at speed 8 with 21 fuel remaining after 1,009 observed PAL frames (about 20.2 seconds). The stored results cover both pad edges, adjacent misses, hard and fast falls, ascending hillside contact, opposing steering, screen and ceiling limits, fuel exhaustion while thrust remains held, retry release/reset, fresh-tape loading and held-Q exit. Read-only state inspection drove the successful approach; no flight state was injected.

The user played the native prototype and reported that it works well and is quite hard. Flight tuning remains unchanged pending review of the easier stages. The final tape adds a Q-release guard; `verification/quit-equivalence.json` confirms identical stored flight code around that exit-only change. Generated tape checksums pass.

## Sources

Steven Vickers, edited by Robin Bradbeer, *ZX Spectrum BASIC Programming*, second edition (Sinclair Research, 1983): chapter 4 (FOR variables), chapters 7–8 (variable names), chapter 12 (arrays), chapter 14 (user-defined graphics), chapter 15 (PRINT AT), chapter 16 (PAPER), chapter 18 (INKEY$ and PAUSE), chapter 20 (tape saving), and chapter 23 (keyboard half-row ports and active-low key bits). The O/P and Space ports follow the manual's address formula, `254+256*(255-2^n)`, for half-rows 5 and 7. INKEY$ reports a character only when exactly one ordinary key is read, hence the separate port reads for combined flight controls.
