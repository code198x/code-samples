# MSX1: reusable BASIC input and sound

Target: MSX1 NTSC, recorded MSX BASIC/BIOS.

## Run

No assembler is required. Enter demo.bas in BASIC and RUN.

Submit GO and Return.

## Reuse

The read-command.bas GOSUB range is 4000/4010 on Aquarius and 3000/3010 elsewhere. Reserve its global variable and line numbers. caller.bas + draw.bas + sound.bas + read-command.bas is exactly demo.bas.

Input: INPUT A$ waits for a line and replaces A$. GO is accepted by the caller. The test’s byte at 40000 mirrors the game count; it is not the input routine’s output.

Audio: BASIC SOUND writes start PSG tone A using period 100 and mixer operand 62, set volume 15, delay with J, then mute volume A. The routine blocks. Leave firmware/PSG port-direction handling to BASIC; do not transplant the mixer operand as an uncontrolled hardware write.

The caller owns its numbered program, global variables and presentation. Keep initialisation outside the repeated command path.

## Adapt

Use a different command string or connect the reader to a parser. The separate assembly loop shows physical press edges.

Change the tone period or volume; choose a serviced player when animation/music must continue. The caller lowers BASIC’s allocation ceiling below its diagnostic byte at 40000.



## Error cases and limits

mistakes/stale-command.bas reuses an accepted command without reading. It advances with no input. Restore the GOSUB before validating and updating. mistakes/no-sound.bas removes the sound call while retaining the accepted action.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-basic.py --native /path/to/released-tools --only msx
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

ASCII/Microsoft, MSX Technical Data Book: BASIC INPUT, CLEAR, SOUND, GOSUB/RETURN; PSG and BIOS ownership.
