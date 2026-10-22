# Atari 800XL: reusable BASIC input and sound

Target: 800XL NTSC, Atari BASIC and GRAPHICS 0.

## Run

No assembler is required. Enter demo.bas in BASIC and RUN.

Submit 1 and Return.

## Reuse

The read-command.bas GOSUB range is 4000/4010 on Aquarius and 3000/3010 elsewhere. Reserve its global variable and line numbers. caller.bas + draw.bas + sound.bas + read-command.bas is exactly demo.bas.

Input: INPUT A replaces one numeric variable; the caller accepts 1 and rejects 0. It does not poll a joystick or run while the player edits a line.

Audio: SOUND channel 0 is started with frequency 100, distortion 10 and volume 15; a BASIC loop delays before SOUND 0,0,0,0 mutes it. J is scratch.

The caller owns its numbered program, global variables and presentation. Keep initialisation outside the repeated command path.

## Adapt

Validate the submitted value before moving a piece or changing a room. Keep game state out of the reader.

Choose another frequency/distortion pair. The FOR loop is a blocking CPU delay; it is not a calibrated wall clock or a POKEY music sequencer.



## Error cases and limits

mistakes/stale-command.bas reuses an accepted command without reading. It advances with no input. Restore the GOSUB before validating and updating. mistakes/no-sound.bas removes the sound call while retaining the accepted action.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-basic.py --native /path/to/released-tools --only atari-800xl
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

Atari, Atari BASIC Reference Manual: INPUT, GOSUB/RETURN and SOUND; Atari Hardware Manual: POKEY audio channels.
