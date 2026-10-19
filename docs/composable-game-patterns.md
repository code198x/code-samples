# Collect, respond, reuse

Five small games connect input, press detection, bounded movement, box collision,
drawing and sound. Each starts with a player, one collectible and a score. Move
over the collectible to score once and hear a sound; press the action button to
restart. The implementations own different resources because the machines do.

| Machine | Controls | Display | Sound | Timing |
| --- | --- | --- | --- | --- |
| C64 | Joystick port 2, fire | Character cells and colour RAM | SID voice 1 | Raster boundary |
| Spectrum 48K | QAOP, Space | Software glyphs in the bitmap | ULA beeper | Interrupt/HALT |
| Amiga | Digital joystick port 2, fire | CPU-written single bitplane | Paula channel 0 | Vertical blank |
| NES | D-pad, A | Nametable tiles, CHR ROM | Pulse 1 | NMI handoff |
| BBC Micro | QAOP, Space | MOS MODE 6 text cells | MOS SOUND channel 1 | MOS vertical sync |

The source directories are `patterns/assembly/framework/collect-and-respond`
under each machine. Start with their README and `demo.asm`. Follow the includes:
`rules.inc`, `collision.inc`, `draw.inc` and `sound.inc`. Existing frame, input
and sound routines are reused. Machine READMEs document registers, memory,
initialisation, calls and interrupt/resource ownership.

`boxes_overlap` uses half-open rectangles: touching edges do not overlap and
empty/reversed boxes are rejected. Coordinates are cells here; the routine can
also compare pixels. This example does not require pixel masks. A larger game
can use boxes to reject most pairs before a more expensive shape test.

The frame order is input → new presses → rules → drawing → sound service.
Movement repeats every six updates. Restart preserves previous input, avoiding
repeated resets while the button is held. Collection clears its active flag
before awarding a point or triggering sound. The Spectrum beep briefly blocks;
the other compositions service or queue sound without waiting for it to end.
These are explicit trade-offs, not interchangeable timing guarantees.

## Thirty configurations, different contracts

[`capability-coverage.json`](capability-coverage.json) records all 30 machines in
the pinned Emu198x registry. Alongside the five compositions are 25 smaller
`patterns/{assembly,basic,forth}/capabilities/input-drawing-sound` probes.
They establish a starting point for future library entries and curriculum;
they do not announce new taught system tracks.

The BASIC and FORTH programs retain their command/key-driven contracts. They
are not renamed real-time game loops. ZX80 and ZX81 use stock 1 KiB configurations
with no sound hardware. PET evidence captures the VIA CB2 signal; early PETs
need an external speaker. The 7800 retains the existing BIOS/startup limitation.
MTX uses a BASIC DATA/POKE/USR caller; Einstein uses a MOS boot sector. Neither
proves every cassette or CP/M loading path.

Two emulator fixes are required for the recorded frontier builds:
[Jupiter Ace speaker latch](https://github.com/emu198x/emu198x/pull/1882) and
[ZX80 quote typing](https://github.com/emu198x/emu198x/pull/1883). Exact executable
hashes and source commits are recorded per machine. These are configuration-
specific native-emulator observations, not original-hardware qualification,
whole-emulator conformance, pitch accuracy or a performance benchmark.

## Run and inspect

Use the existing `asm198x`, `build198x` and native Emu198x executables. Supply your
own legally obtained firmware in the documented Emu198x ROM layout. No firmware
is distributed here. `--native` is a directory containing the native binaries.

```sh
python3 scripts/verify-collect-and-respond.py --native /path/to/native --build198x /path/to/build198x --tape
python3 scripts/verify-collect-and-respond.py --native /path/to/native --build198x /path/to/build198x --only electron
python3 scripts/verify-basic-capabilities.py --native /path/to/native
python3 scripts/verify-hardware-capabilities.py --native /path/to/native
python3 scripts/verify-ace-capabilities.py --native /path/to/native
python3 scripts/verify-zx-capabilities.py --native /path/to/native
```

The Spectrum composition additionally passed fresh-ROM TAP loading; its main
behaviour check uses a RAM snapshot. Other startup paths and firmware hashes are
recorded in each result. Positive checks use real emulated input. Negative cases
break collection, drawing, sound or accepted-input behaviour and must be rejected.
The BASIC sound check compares against keyboard-only audio so a key click cannot
stand in for the program's sound. The TIA drawing control preserves instruction
cost and redirects only the playfield write, avoiding a false result caused by
changing field timing.

Each `verification/results.json` identifies its source and observer. Retained
PNG captures and short, unmodified WAV excerpts live in `verification/evidence`.
The inventory gives each excerpt's offset and the original full WAV hash. They
are review aids; the checker does not pretend to rerun an emulator:

```sh
python3 scripts/check-capability-coverage.py
python3 -m unittest discover -s scripts -p test_capability_coverage.py -v
```

CI checks retained identities and negative-control records without private ROMs.
Fresh execution is a separate step using the commands above. Future promotion
into the taught curriculum still needs its own explanation, user-facing build
path and tool-version qualification.
