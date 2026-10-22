# Sinclair ZX80: reusable BASIC input and sound

Target: stock 4 KiB ROM, 1 KiB RAM, keyword entry.

## Run

No assembler is required. Enter demo.bas in BASIC and RUN.

Use the machine’s keyword keys on ZX80/ZX81 rather than typing keyword letters. The caller deliberately fits the recorded 1 KiB environment.

## Reuse

Copy the INPUT statement into your own numbered flow. It reads A; the caller decides how to use it.

Input: INPUT A is a blocking numeric reader. The nine-line caller adds the submitted A to N; it is a running total, not a validator restricted to 0 and 1. Entering 2 adds two.

Audio: The stock machine has no programmable speaker. No stock sound routine is supplied. An external sound interface would be a separate target configuration.

The caller owns its numbered program, global variables and presentation. Keep initialisation outside the repeated command path.

## Adapt

Copy the INPUT statement into your own numbered flow. Preserve N between decisions. At 1 KiB, the program and its display compete for memory.

An expansion needs its own hardware contract and tests; a silent placeholder cannot stand in for an implemented audio route.



## Error cases and limits

The records retain the observed incorrect addition or fabricated-key control; use the working source to restore the input/update path.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-zx.py --native /path/to/released-tools --only sinclair-zx80
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

Sinclair, ZX80 Operating Manual: INPUT, integer arithmetic, program/display memory and keyboard entry; stock ROM execution in the named 1 KiB configuration.
