# Spectravideo SVI-328: reusable BASIC input and sound

Target: SVI-328 NTSC, stock BASIC.

## Run

No assembler is required. Enter demo.bas in BASIC and RUN.

Submit GO and Return.

## Reuse

The read-command.bas GOSUB range is 4000/4010 on Aquarius and 3000/3010 elsewhere. Reserve its global variable and line numbers. caller.bas + draw.bas + sound.bas + read-command.bas is exactly demo.bas.

Input: INPUT A$ returns a line. The caller accepts GO and stores its byte count above BASIC’s lowered allocation ceiling. The mirror is diagnostic state, not an input API.

Audio: SOUND starts PSG tone A, then a blocking J loop delays before muting it. The routine owns those tone/mixer/volume settings; it does not arbitrate with music.

The caller owns its numbered program, global variables and presentation. Keep initialisation outside the repeated command path.

## Adapt

Connect the returned string to a larger command dispatcher. Keep CLEAR’s reserved address and any machine-code or asset allocations consistent.

Change the period or use another channel with an explicit mixer policy. Busy-loop duration depends on the interpreter and workload.



## Error cases and limits

mistakes/stale-command.bas reuses an accepted command without reading. It advances with no input. Restore the GOSUB before validating and updating. mistakes/no-sound.bas removes the sound call while retaining the accepted action.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-basic.py --native /path/to/released-tools --only spectravideo-svi-328
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

Spectravideo, SVI BASIC documentation: CLEAR, INPUT, SOUND, GOSUB/RETURN and PSG sound control.
