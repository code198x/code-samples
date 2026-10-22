# Tatung Einstein: reusable ASSEMBLY input and sound

Target: TC-01 PAL, MOS 1.2, Ctrl-BREAK disk boot.

## Run

make -C tatung-einstein/patterns/assembly/input/read-action ASM198X=/path/to/asm198x

Attach build/demo.dsk, hold Control, press/release BREAK, then release Control. MOS reads the original 512-byte boot sector; no CP/M or Xtal BASIC is installed by this example.

## Reuse

sample.inc is an inline sampler, not a callable subroutine: include it at the sampling point shown in demo.asm. It has no RET/RTS. Keep previous-state storage and edge decisions in the caller.

Input: Select AY register 14 and write $FE for keyboard row 0, then select register 15 and read port $02. Space is active-low bit 6. B receives 0/$40; AF/B and the AY register selection change.

Audio: AY channel A, duration $8005. The routine sets mixer $7E, preserving the required port-A-output/port-B-input configuration. Trigger preserves AF/B; service changes AF. Both keyboard and sound share the AY address latch.

previous=$8001; turn=$8000, field clock=$8002/$8003; stack below $FFF0

## Adapt

Keep the dedicated keyboard interrupt masked as in startup, or synchronise all AY register selections. An interrupt between address and data accesses can redirect a write.

Change tone A’s period/volume without changing keyboard port directions. A shared audio driver must coordinate with keyboard scanning.

Hardware effects stop on the eighth service_sound call. The caller services sound in the triggering iteration too, so this does not promise eight complete elapsed display intervals. Initialise the duration byte before servicing. The supplied initialiser also mutes other channels. Protect shared device latches and global mixer/power registers.

## Error cases and limits

mistakes/no-edge.asm feeds held state to the action decision. A held action advances repeatedly; use the working caller’s previous-state comparison and update previous on release as well. mistakes/no-sound.asm is byte-identical to the executed muted negative control.

The examples use Emu198x 0.44.1 and Asm198x 0.0.71 where assembly is needed. These are named native-emulator observations, not original hardware, all peripherals, pitch accuracy or a whole-emulator qualification. No tape-transfer route is implied by a typed or cartridge loader.

## Reproduce

```sh
python3 scripts/verify-column-hardware.py --native /path/to/released-tools --only tatung-einstein
python3 scripts/finalise-column-evidence.py --tools /path/to/released-tools
python3 scripts/check-column-evidence.py
python3 -m unittest discover -s scripts -p test_column_evidence.py
```

The full inventory must be run before finalising all 26 routes; finalisation requires their actual records. Firmware hashes and release producer identities are retained in docs/column-expansion.json. Keep proprietary firmware outside this repository. Broad 30-machine capability records remain unchanged.

## Sources

Tatung, Einstein Hardware Manual: programmable sound generator/keyboard interface and port decoding; MOS disk boot header; General Instrument AY-3-8910 data manual.
