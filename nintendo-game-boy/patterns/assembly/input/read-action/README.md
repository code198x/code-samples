# Game Boy: reusable ASSEMBLY input and sound

Target: DMG default reset without boot ROM, 32 KiB cartridge.

## Run

make -C nintendo-game-boy/patterns/assembly/input/read-action ASM198X=/path/to/asm198x

Load the generated cartridge through the emulator’s normal cartridge option in the recorded configuration. Keep its reset/header, display setup and stack policy with the caller. Reset to leave.

## Reuse

sample.inc is an inline sampler, not a callable subroutine: include it at the sampling point shown in demo.asm. It has no RET/RTS. Keep previous-state storage and edge decisions in the caller.

Input: Writing $10 to JOYP selects action buttons. Six settling reads precede active-low bit-0 normalisation; B receives 0/1 for A. AF/B change, and the row remains selected.

Audio: Pulse channel 1, duration byte $C004. The trigger also writes shared NR50/NR51/NR52 routing, volume and power controls, so it is not safe beside an unrelated mixer. AF changes; B is preserved.

previous=$C001; turn=$C000, field clock=$C002/$C003; SP=$FFFE, interrupts disabled

## Adapt

Use another JOYP row or combine rows deliberately. Hardware switch bounce and input lost between polls are separate from the release/press filter.

Change pulse duty/frequency/envelope operands. An audio engine should initialise shared power/routing once and arbitrate channel use.

Hardware effects stop on the eighth service_sound call. The caller services sound in the triggering iteration too, so this does not promise eight complete elapsed display intervals. Initialise the duration byte before servicing. The supplied initialiser also mutes other channels. Protect shared device latches and global mixer/power registers.

## Error cases and limits

mistakes/no-edge.asm feeds held state to the action decision. A held action advances repeatedly; use the working caller’s previous-state comparison and update previous on release as well. mistakes/no-sound.asm is byte-identical to the executed muted negative control.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-hardware.py --native /path/to/released-tools --only nintendo-game-boy
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

Nintendo, Game Boy Programming Manual v1.1: P1/JOYP scan example (six action-button reads), LCDC/LY access rules and NR10–NR14/NR50–NR52.
