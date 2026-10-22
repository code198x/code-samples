# Oric Atmos: reusable BASIC input and sound

Target: Oric Atmos, stock BASIC text mode.

## Run

No assembler is required. Enter demo.bas in BASIC and RUN.

Submit 1 and Return.

## Reuse

The read-command.bas GOSUB range is 4000/4010 on Aquarius and 3000/3010 elsewhere. Reserve its global variable and line numbers. caller.bas + draw.bas + sound.bas + read-command.bas is exactly demo.bas.

Input: INPUT A waits for a numeric line. Only 1 advances the example; 0 is ignored. INPUT itself is not a one-key scanner.

Audio: PING uses the firmware’s predefined effect. The wrapper has no custom state or parameters; its timing/control belongs to the ROM effect.

The caller owns its numbered program, global variables and presentation. Keep initialisation outside the repeated command path.

## Adapt

Replace the numeric test or dispatch several commands after the read. Use a character reader for a menu that should respond before Return.

Use another documented ROM effect or write an AY routine with an explicit mixer/channel contract. PING is deliberately a small interface, not an arbitrary note player.



## Error cases and limits

mistakes/stale-command.bas reuses an accepted command without reading. It advances with no input. Restore the GOSUB before validating and updating. mistakes/no-sound.bas removes the sound call while retaining the accepted action.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-basic.py --native /path/to/released-tools --only oric-atmos
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

Oric, Atmos Manual: BASIC INPUT, GOSUB/RETURN and PING; predefined sound effects.
