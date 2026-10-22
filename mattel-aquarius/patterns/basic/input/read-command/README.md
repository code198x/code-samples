# Mattel Aquarius: reusable BASIC input and sound

Target: stock Aquarius BASIC with an array-backed USR sound helper.

## Run

No assembler is required. Enter demo.bas in BASIC and RUN.

Submit GO and Return.

## Reuse

The read-command.bas GOSUB range is 4000/4010 on Aquarius and 3000/3010 elsewhere. Reserve its global variable and line numbers. caller.bas + draw.bas + sound.bas + read-command.bas is exactly demo.bas.

Input: GOSUB 4000 replaces A$ with the submitted line. The caller recognises GO. The 4000 range deliberately leaves the existing 3000-range sound DATA intact.

Audio: The caller creates all its scalar variables before DIM Z(16), locates that array storage and installs a 22-byte Z80 helper plus USR vector. GOSUB 2000 calls it. It toggles output port $FC with a CPU delay and returns, preserving AF/BC. The routine blocks and uses W/J/B/X plus the Z array and USR vector.

The caller owns its numbered program, global variables and presentation. Keep initialisation outside the repeated command path.

## Adapt

Reserve the complete numbered ranges. Reusing line 3000 for INPUT replaces a sound DATA line; the native fault run fails before the game starts. The repaired program uses 4000/4010.

Keep the array/vector setup with the sound routine. Adding variables or changing array layout can move its storage; do not reuse a stale pointer. A ROM-independent allocator/driver would need a different storage contract.



## Error cases and limits

mistakes/stale-command.bas reuses an accepted command without reading. It advances with no input. Restore the GOSUB before validating and updating. mistakes/no-sound.bas removes the sound call while retaining the accepted action.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-basic.py --native /path/to/released-tools --only mattel-aquarius
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

Mattel/Radofin, Aquarius BASIC documentation: INPUT, DATA/READ, DIM and USR; machine-code helper bytes and port behaviour are identified by this configuration’s executed source.
