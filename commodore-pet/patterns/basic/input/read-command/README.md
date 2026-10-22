# Commodore PET: reusable BASIC input and sound

Target: 40-column PET firmware configuration with emulated VIA/CB2 sound output.

## Run

No assembler is required. Enter demo.bas in BASIC and RUN.

Submit GO and Return.

## Reuse

The read-command.bas GOSUB range is 4000/4010 on Aquarius and 3000/3010 elsewhere. Reserve its global variable and line numbers. caller.bas + draw.bas + sound.bas + read-command.bas is exactly demo.bas.

Input: INPUT A$ returns a whole line; the caller recognises GO. N survives the subroutine. The ROM owns keyboard scanning and its editing buffer.

Audio: The routine programs VIA ACR, shift register and Timer 2 low byte at 59467, 59466 and 59464, waits in a BASIC loop, then clears ACR. It requires an audible CB2 sound connection or the selected emulator output; an early PET without a speaker connection is not magically given a speaker.

The caller owns its numbered program, global variables and presentation. Keep initialisation outside the repeated command path.

## Adapt

Use another string or add a dispatch table after INPUT. Changing case handling is a separate decision.

Change the Timer 2 operand to alter the output. This takes over VIA shift-register/timer configuration; it does not preserve another driver or restore a previous ACR value.



## Error cases and limits

mistakes/stale-command.bas reuses an accepted command without reading. It advances with no input. Restore the GOSUB before validating and updating. mistakes/no-sound.bas removes the sound call while retaining the accepted action.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-basic.py --native /path/to/released-tools --only commodore-pet
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

Commodore, PET/CBM documentation: BASIC INPUT and GOSUB/RETURN; MOS Technology 6522 VIA data sheet: ACR, shift-register modes and Timer 2; PET sound requires the appropriate CB2 connection.
