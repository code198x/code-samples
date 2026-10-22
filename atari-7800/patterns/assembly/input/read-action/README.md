# Atari 7800: reusable ASSEMBLY input and sound

Target: NTSC 48 KiB cartridge, reset without BIOS authentication.

## Run

make -C atari-7800/patterns/assembly/input/read-action ASM198X=/path/to/asm198x

Load the generated cartridge through the emulator’s normal cartridge option in the recorded configuration. Keep its reset/header, display setup and stack policy with the caller. Reset to leave.

## Reuse

sample.inc is an inline sampler, not a callable subroutine: include it at the sampling point shown in demo.asm. It has no RET/RTS. Keep previous-state storage and edge decisions in the caller.

Input: Legacy INPT4 at $0C uses active-low bit 7; the inline sampler stores 0/$80 in current=$1904. It changes A/flags and does not read the second independent controller button.

Audio: Stock TIA channel 0, duration byte $1905; no cartridge POKEY is assumed. A/flags change. The caller owns MARIA display lists, TIA sound and its mode lock.

previous=$1901, current=$1904; turn=$1900, field clock=$1902/$1903

## Adapt

Add the second controller button only after handling its distinct wiring. Do not copy the 5200 bit-0 trigger mask.

Change TIA tone/noise controls; a POKEY cartridge is an expanded audio configuration with another implementation.

Hardware effects stop on the eighth service_sound call. The caller services sound in the triggering iteration too, so this does not promise eight complete elapsed display intervals. Initialise the duration byte before servicing. The supplied initialiser also mutes other channels. Protect shared device latches and global mixer/power registers.

## Error cases and limits

mistakes/no-edge.asm feeds held state to the action decision. A held action advances repeatedly; use the working caller’s previous-state comparison and update previous on release as well. mistakes/no-sound.asm is byte-identical to the executed muted negative control.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-hardware.py --native /path/to/released-tools --only atari-7800
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

Atari, 7800 Software Guide: controller/TIA interface, MARIA/MSTAT and cartridge reset; Stella audio register definitions.
