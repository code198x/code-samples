# Dragon 32: reusable BASIC input and sound

Target: Dragon 32 PAL, stock Extended Colour BASIC.

## Run

No assembler is required. Enter demo.bas in BASIC and RUN.

Submit 1 and Return.

## Reuse

The read-command.bas GOSUB range is 4000/4010 on Aquarius and 3000/3010 elsewhere. Reserve its global variable and line numbers. caller.bas + draw.bas + sound.bas + read-command.bas is exactly demo.bas.

Input: INPUT A waits for a submitted number; the caller accepts 1. The routine reads a value and leaves the decision to its caller.

Audio: SOUND 100,2 uses the ROM sound routine and blocks while it generates the tone. Those operands are BASIC pitch/duration units, not frequency and seconds.

The caller owns its numbered program, global variables and presentation. Keep initialisation outside the repeated command path.

## Adapt

Choose another accepted number or dispatch several numeric commands. INPUT is useful when the world can wait.

Change the SOUND operands using the language manual’s ranges. A non-blocking player would need to take over the audio path and its timing.



## Error cases and limits

mistakes/stale-command.bas reuses an accepted command without reading. It advances with no input. Restore the GOSUB before validating and updating. mistakes/no-sound.bas removes the sound call while retaining the accepted action.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-basic.py --native /path/to/released-tools --only dragon-32
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

Dragon Data, Dragon 32 User Manual: INPUT, GOSUB/RETURN and SOUND; ROM sound generation.
