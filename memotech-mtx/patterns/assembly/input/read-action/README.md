# Memotech MTX: reusable ASSEMBLY input and sound

Target: MTX500 PAL, stock BASIC DATA/POKE/USR entry.

## Run

make -C memotech-mtx/patterns/assembly/input/read-action ASM198X=/path/to/asm198x

Enter the generated build/loader.bas through MTX BASIC and RUN. It READ/POKE-loads $E000, then enters through USR. This is a takeover until reset, not a BASIC-return routine.

## Reuse

sample.inc is an inline sampler, not a callable subroutine: include it at the sampling point shown in demo.asm. It has no RET/RTS. Keep previous-state storage and edge decisions in the caller.

Input: OUT ($05),$7F selects keyboard column 7; IN ($06) supplies the high part of its return. Space is active-low bit 0 of that read. B receives 0/1; AF/B change.

Audio: SN76489 tone 0 writes port $06, duration $DF05. Reads at $06 belong to keyboard input while writes belong to sound. Trigger preserves AF/B; service changes AF.

previous=$DF01; turn=$DF00, field clock=$DF02/$DF03; stack below $F7F0

## Adapt

Preserve the read/write distinction and column drive. This direct reader takes over the keyboard configuration rather than consuming a BASIC character.

Change the tone divisor or duration counter. The USR entry takes over until reset; it does not return to a live BASIC session.

Hardware effects stop on the eighth service_sound call. The caller services sound in the triggering iteration too, so this does not promise eight complete elapsed display intervals. Initialise the duration byte before servicing. The supplied initialiser also mutes other channels. Protect shared device latches and global mixer/power registers.

## Error cases and limits

mistakes/no-edge.asm feeds held state to the action decision. A held action advances repeatedly; use the working caller’s previous-state comparison and update previous on release as well. mistakes/no-sound.asm is byte-identical to the executed muted negative control.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-hardware.py --native /path/to/released-tools --only memotech-mtx
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

Memotech, MTX Series Operator’s Manual/technical description: keyboard matrix, sound I/O and USR; TI SN76489A data manual.
