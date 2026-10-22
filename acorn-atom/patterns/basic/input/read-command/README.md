# Atom: reusable BASIC input and sound

Target: Atom full BASIC configuration.

## Run

No assembler is required. Enter demo.bas in BASIC and RUN.

Submit 1 and Return.

## Reuse

The read-command.bas GOSUB range is 4000/4010 on Aquarius and 3000/3010 elsewhere. Reserve its global variable and line numbers. caller.bas + draw.bas + sound.bas + read-command.bas is exactly demo.bas.

Input: INPUT A replaces the numeric A after Return; only 1 is an action in the caller. The input routine preserves N.

Audio: The FOR loop toggles PPI port C bit 2 at #B002. This is a blocking software tone; J is scratch state. Other port-C bits are read and written back. Competing writers still need coordination.

The caller owns its numbered program, global variables and presentation. Keep initialisation outside the repeated command path.

## Adapt

Use another number for a different command, or add a separate test after the reader. INPUT also accepts values the game does not recognise.

Change the iteration count for a longer burst. Its pitch and length depend on interpreter/CPU execution; a tone generator or interrupt driver is a different component.



## Error cases and limits

mistakes/stale-command.bas reuses an accepted command without reading. It advances with no input. Restore the GOSUB before validating and updating. mistakes/no-sound.bas removes the sound call while retaining the accepted action.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-basic.py --native /path/to/released-tools --only acorn-atom
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

Acorn, Atom BASIC Manual: INPUT, GOSUB/RETURN, byte indirection and bitwise operators; Atom Technical Manual: 8255 port C and loudspeaker.
