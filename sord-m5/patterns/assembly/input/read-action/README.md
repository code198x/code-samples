# Sord M5: reusable ASSEMBLY input and sound

Target: NTSC M5, monitor-started cartridge.

## Run

make -C sord-m5/patterns/assembly/input/read-action ASM198X=/path/to/asm198x

Load the generated cartridge through the emulator’s normal cartridge option in the recorded configuration. Keep its reset/header, display setup and stack policy with the caller. Reset to leave.

## Reuse

sample.inc is an inline sampler, not a callable subroutine: include it at the sampling point shown in demo.asm. It has no RET/RTS. Keep previous-state storage and edge decisions in the caller.

Input: IN ($30) reads keyboard row Y0. Space is ACTIVE-HIGH bit 6: mask $40 and keep its polarity. B receives 0/$40; AF/B change.

Audio: SN76489 tone 0 at $20, duration $7005. Trigger preserves AF/B; service changes AF. The caller owns the VDP and starts through the monitor cartridge header.

previous=$7001; turn=$7000, field clock=$7002/$7003; stack below $7FF0

## Adapt

Do not add the complement used by neighbouring Z80 machines: an idle M5 would look pressed. Other keyboard rows need their own selection/read contract.

Change the divisor or attenuation. Keep SN76489 writes separate from VDP status reads at $11; both chips need ownership, for different reasons.

Hardware effects stop on the eighth service_sound call. The caller services sound in the triggering iteration too, so this does not promise eight complete elapsed display intervals. Initialise the duration byte before servicing. The supplied initialiser also mutes other channels. Protect shared device latches and global mixer/power registers.

## Error cases and limits

mistakes/no-edge.asm feeds held state to the action decision. A held action advances repeatedly; use the working caller’s previous-state comparison and update previous on release as well. mistakes/no-sound.asm is byte-identical to the executed muted negative control.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-hardware.py --native /path/to/released-tools --only sord-m5
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

Sord BASIC-G Appendix H: I/O map; Sord M5C-01 schematic: decoding; TI SN76489A and TMS9918A data manuals. The specific Space polarity is configuration-specific executed evidence.
