# ColecoVision: reusable ASSEMBLY input and sound

Target: NTSC ColecoVision, recorded BIOS, title-skipping cartridge.

## Run

make -C coleco-colecovision/patterns/assembly/input/read-action ASM198X=/path/to/asm198x

Load the generated cartridge through the emulator’s normal cartridge option in the recorded configuration. Keep its reset/header, display setup and stack policy with the caller. Reset to leave.

## Reuse

sample.inc is an inline sampler, not a callable subroutine: include it at the sampling point shown in demo.asm. It has no RET/RTS. Keep previous-state storage and edge decisions in the caller.

Input: The caller selects joystick mode with OUT ($C0),A. IN ($FC) then reads controller 1: left fire is active-low bit 6. The inline sampler returns 0/$40 in B and changes A/flags/B.

Audio: SN76489 tone 0 at port $FF, duration byte $6005. Trigger preserves AF and B; service changes AF. Picture initialisation mutes all channels, so the complete caller takes audio ownership.

previous=$6001; turn=$6000, field clock=$6002/$6003; stack below $63F0

## Adapt

Keep controller mode selection with the reader; keypad mode gives another meaning to the same read. Share mode changes explicitly.

Change the PSG’s ten-bit tone divisor or attenuation. Latched register writes must remain ordered; concurrent sound writers need arbitration.

Hardware effects stop on the eighth service_sound call. The caller services sound in the triggering iteration too, so this does not promise eight complete elapsed display intervals. Initialise the duration byte before servicing. The supplied initialiser also mutes other channels. Protect shared device latches and global mixer/power registers.

## Error cases and limits

mistakes/no-edge.asm feeds held state to the action decision. A held action advances repeatedly; use the working caller’s previous-state comparison and update previous on release as well. mistakes/no-sound.asm is byte-identical to the executed muted negative control.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-hardware.py --native /path/to/released-tools --only coleco-colecovision
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

Coleco, ColecoVision technical documentation: controller mode ports and cartridge vectors; Texas Instruments SN76489A data manual: latch/data writes.
