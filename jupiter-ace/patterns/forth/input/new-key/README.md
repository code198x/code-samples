# Jupiter Ace: reusable FORTH input and sound

Target: stock 3 KiB Ace, recorded FORTH ROM.

## Run

Enter demo.fth in the Ace, in its listed order; its last line starts TURNS.

Press 1. Release it before another action; other keys are ignored by this caller.

## Reuse

Compile new-key.fth and click.fth before the caller. NEWKEY adds one character to the data stack; CLICK preserves the existing stack.

Input: NEWKEY has stack effect ( -- c ). It waits for INKEY to return zero, then waits for a nonzero character. A key held at entry must be released before it can become a new action. It preserves everything already below its result on the data stack.

Audio: CLICK has stack effect ( -- ). It supplies 478 and 120 to ROM BEEP, which consumes both operands and blocks for the generated tone. The running turn count below them stays on the stack.

The caller owns its numbered program, global variables and presentation. Keep initialisation outside the repeated command path.

## Adapt

Change the character comparison after NEWKEY. Keep release-then-press when an action must happen once per physical press; raw INKEY is useful for held-state controls instead.

Change CLICK’s two BEEP operands using the manual’s pitch/duration rules. Their units are not interchangeable with BASIC SOUND on other machines.



## Error cases and limits

The records retain the observed incorrect addition or fabricated-key control; use the working source to restore the input/update path.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-forth.py --native /path/to/released-tools
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

Jupiter Cantab, Jupiter Ace User Manual: INKEY, ?DUP, conditional loops and BEEP; chapter on the loudspeaker and music.
