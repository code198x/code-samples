# Commodore VIC-20: reusable BASIC input and sound

Target: unexpanded PAL VIC-20, Commodore BASIC.

## Run

No assembler is required. Enter demo.bas in BASIC and RUN.

Submit GO and Return.

## Reuse

The read-command.bas GOSUB range is 4000/4010 on Aquarius and 3000/3010 elsewhere. Reserve its global variable and line numbers. caller.bas + draw.bas + sound.bas + read-command.bas is exactly demo.bas.

Input: INPUT A$ returns a submitted line. The example accepts GO; held-key repeat during editing belongs to the ROM, not to game turns.

Audio: POKE 36878,15 changes shared master volume; POKE 36876,220 enables the third tone voice. After a blocking J loop, POKE 36876,0 stops that voice.

The caller owns its numbered program, global variables and presentation. Keep initialisation outside the repeated command path.

## Adapt

Add another string-to-action branch. Do not assume a string returned by INPUT is already a valid game command.

Change the voice register value for another tone. Preserve or explicitly own master volume when mixing effects and music; this sample leaves volume at 15.



## Error cases and limits

mistakes/stale-command.bas reuses an accepted command without reading. It advances with no input. Restore the GOSUB before validating and updating. mistakes/no-sound.bas removes the sound call while retaining the accepted action.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-basic.py --native /path/to/released-tools --only commodore-vic-20
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

Commodore, VIC-20 Programmer’s Reference Guide: BASIC INPUT/GOSUB and VIC sound registers $900A–$900E.
