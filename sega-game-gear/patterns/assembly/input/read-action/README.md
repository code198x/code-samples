# Game Gear: reusable ASSEMBLY input and sound

Target: NTSC stock Game Gear cartridge configuration.

## Run

make -C sega-game-gear/patterns/assembly/input/read-action ASM198X=/path/to/asm198x

Load the generated cartridge through the emulator’s normal cartridge option in the recorded configuration. Keep its reset/header, display setup and stack policy with the caller. Reset to leave.

## Reuse

sample.inc is an inline sampler, not a callable subroutine: include it at the sampling point shown in demo.asm. It has no RET/RTS. Keep previous-state storage and edge decisions in the caller.

Input: IN ($DC) reads the pad. Active-low bit 4 is button 1; B receives 0/$10. AF/B change. START is not part of this sampler.

Audio: SN76489-compatible tone 0 at $7F, duration $C005. Trigger preserves AF/B; service changes AF. No stereo-panning interface is provided here.

previous=$C001; turn=$C000, field clock=$C002/$C003; stack below $C3F0

## Adapt

Add other pad bits after defining your game’s mask. START and stereo routing are Game Gear-specific extensions, not Master System aliases.

Change the tone divisor or attenuation. A stereo effect needs a separate routing contract as well as a tone.

Hardware effects stop on the eighth service_sound call. The caller services sound in the triggering iteration too, so this does not promise eight complete elapsed display intervals. Initialise the duration byte before servicing. The supplied initialiser also mutes other channels. Protect shared device latches and global mixer/power registers.

## Error cases and limits

mistakes/no-edge.asm feeds held state to the action decision. A held action advances repeatedly; use the working caller’s previous-state comparison and update previous on release as well. mistakes/no-sound.asm is byte-identical to the executed muted negative control.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-hardware.py --native /path/to/released-tools --only sega-game-gear
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

Sega, Game Gear hardware/software reference: controller ports, stereo routing and PSG; TI SN76489A latch/data format.
