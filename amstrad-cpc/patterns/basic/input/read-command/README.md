# Amstrad CPC: reusable BASIC input and sound

Target: CPC464 PAL, Locomotive BASIC, MODE 1.

## Run

No assembler is required. Enter demo.bas in BASIC and RUN.

Submit GO and Return.

## Reuse

The read-command.bas GOSUB range is 4000/4010 on Aquarius and 3000/3010 elsewhere. Reserve its global variable and line numbers. caller.bas + draw.bas + sound.bas + read-command.bas is exactly demo.bas.

Input: INPUT A$ waits for a complete line. The caller compares A$ with the exact uppercase string GO; reading a line does not validate it.

Audio: SOUND 1,100,10,15 submits a channel-A note to the firmware sound system. This routine returns after submission, subject to the firmware queue being able to accept the command. Firmware owns subsequent playback.

The caller owns its numbered program, global variables and presentation. Keep initialisation outside the repeated command path.

## Adapt

Replace GO with a short command or dispatch several strings after the reader. Keep the line-number range free.

Change the SOUND period, duration or volume operands. Adding envelopes changes the duration contract; filling the firmware queue can make submission wait.



## Error cases and limits

mistakes/stale-command.bas reuses an accepted command without reading. It advances with no input. Restore the GOSUB before validating and updating. mistakes/no-sound.bas removes the sound call while retaining the accepted action.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-basic.py --native /path/to/released-tools --only amstrad-cpc
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

Amstrad, CPC464 User Instructions: Locomotive BASIC entries INPUT, GOSUB, RETURN and SOUND, including channel/queue behaviour.
