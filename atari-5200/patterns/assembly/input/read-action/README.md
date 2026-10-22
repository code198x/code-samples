# Atari 5200: reusable ASSEMBLY input and sound

Target: NTSC 32 KiB cartridge, recorded BIOS handover.

## Run

make -C atari-5200/patterns/assembly/input/read-action ASM198X=/path/to/asm198x

Load the generated cartridge through the emulator’s normal cartridge option in the recorded configuration. Keep its reset/header, display setup and stack policy with the caller. Reset to leave.

## Reuse

sample.inc is an inline sampler, not a callable subroutine: include it at the sampling point shown in demo.asm. It has no RET/RTS. Keep previous-state storage and edge decisions in the caller.

Input: GTIA TRIG0 at $C010 uses active-low bit 0. The inline sampler stores 0/1 in current=$1004, leaving the edge decision to its caller; A/flags change.

Audio: POKEY channel 1 at $E800/$E801, duration byte $1005. The trigger also sets global AUDCTL and SKCTL; it is not isolated from other POKEY users. A/flags change.

previous=$1001, current=$1004; turn=$1000, field clock=$1002/$1003

## Adapt

This reads the fire trigger only. The 5200’s analogue axes require their own sampling/calibration policy.

Change the frequency/distortion values after deciding who owns global POKEY configuration. A cartridge must retain the BIOS entry contract.

Hardware effects stop on the eighth service_sound call. The caller services sound in the triggering iteration too, so this does not promise eight complete elapsed display intervals. Initialise the duration byte before servicing. The supplied initialiser also mutes other channels. Protect shared device latches and global mixer/power registers.

## Error cases and limits

mistakes/no-edge.asm feeds held state to the action decision. A held action advances repeatedly; use the working caller’s previous-state comparison and update previous on release as well. mistakes/no-sound.asm is byte-identical to the executed muted negative control.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-hardware.py --native /path/to/released-tools --only atari-5200
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

Atari, 5200/GTIA hardware documentation: trigger inputs; POKEY data sheet: AUDF/AUDC/AUDCTL/SKCTL; ANTIC VCOUNT.
