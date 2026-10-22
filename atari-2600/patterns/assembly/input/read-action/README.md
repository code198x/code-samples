# Atari 2600: reusable ASSEMBLY input and sound

Target: NTSC 4 KiB cartridge.

## Run

make -C atari-2600/patterns/assembly/input/read-action ASM198X=/path/to/asm198x

Load the generated cartridge through the emulator’s normal cartridge option in the recorded configuration. Keep its reset/header, display setup and stack policy with the caller. Reset to leave.

## Reuse

sample.inc is an inline sampler, not a callable subroutine: include it at the sampling point shown in demo.asm. It has no RET/RTS. Keep previous-state storage and edge decisions in the caller.

Input: INPT4 at $0C uses active-low bit 7. The inline sampler normalises it to 0/$80 in A and current byte $84. It changes A and flags; X/Y are untouched.

Audio: TIA channel 0 ($15/$17/$19), duration byte $85; trigger changes A/flags and service changes A/flags. The caller owns TIA/RIOT and the software scanline schedule.

previous=$81, current=$84; turn=$80, field clock=$82/$83

## Adapt

Change the input mask only with the correct electrical source. Paddle inputs and a second fire arrangement need different readers.

Change AUDC0/AUDF0/AUDV0 for another effect. Keep all work within the overscan budget; moving a blocking effect here can break the picture.

Hardware effects stop on the eighth service_sound call. The caller services sound in the triggering iteration too, so this does not promise eight complete elapsed display intervals. Initialise the duration byte before servicing. The supplied initialiser also mutes other channels. Protect shared device latches and global mixer/power registers.

## Error cases and limits

mistakes/no-edge.asm feeds held state to the action decision. A held action advances repeatedly; use the working caller’s previous-state comparison and update previous on release as well. mistakes/no-sound.asm is byte-identical to the executed muted negative control.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-hardware.py --native /path/to/released-tools --only atari-2600
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

Atari, Stella Programmer’s Guide: INPT4, VBLANK/WSYNC and audio registers; MOS 6507/RIOT execution.
