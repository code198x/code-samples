# Runnable probe coverage

All 30 registry machines are targets. Nine currently have retained, configuration-specific execution records; 21 remain planned. This is a probe inventory, not a catalogue of complete curriculum tracks. Future catalogue systems can join as execution paths become available.

The first six qualify frame-paced callers. The three Sega callers qualify untimed turns and optional deadlines. These are different tested behaviours, not an equal-feature emulator certification.

| Machine ID | Native crate | Evidence or next check |
| --- | --- | --- |
| `acorn-atom` | `emu198x-acorn-atom` | Qualify Atom-specific firmware, keyboard input and display wait; MOS calls do not transfer. |
| `acorn-bbc-micro` | `emu198x-acorn-bbc-micro` | [Qualified frame-paced](../bbc-micro/patterns/assembly/framework/game-loop/verification/results.json) |
| `acorn-electron` | `emu198x-acorn-electron` | [Qualified frame-paced](../acorn-electron/patterns/assembly/framework/game-loop/verification/results.json) |
| `amstrad-cpc` | `emu198x-amstrad-cpc` | Start with CPC464 firmware and a typed or loaded caller; specify firmware versus direct CRTC ownership. |
| `atari-2600` | `emu198x-atari-2600` | Build a cartridge whose kernel services display and input; separate game progression from mandatory video work. |
| `atari-5200` | `emu198x-atari-5200` | Qualify BIOS cartridge entry and analogue controller ranges; do not reuse digital-only input assumptions. |
| `atari-7800` | `emu198x-atari-7800` | Qualify cartridge header, TIA/MARIA ownership and controller input. |
| `atari-800xl` | `emu198x-atari-800xl` | Specify OS/XL memory mapping, cartridge or loader entry, keyboard/joystick and display-list ownership. |
| `coleco-colecovision` | `emu198x-colecovision` | Qualify BIOS/cartridge entry and controller multiplexing before reusing TMS9918-facing code. |
| `commodore-amiga` | `emu198x-amiga` | [Qualified frame-paced](../commodore-amiga/patterns/assembly/framework/game-loop/verification/results.json) |
| `commodore-c64` | `emu198x-c64` | [Qualified frame-paced](../commodore-64/patterns/assembly/framework/game-loop/verification/results.json) |
| `commodore-pet` | `emu198x-commodore-pet` | Specify model, RAM, BASIC/KERNAL and keyboard; begin with input/output without imposing a video timer. |
| `commodore-vic-20` | `emu198x-commodore-vic-20` | Specify PAL/NTSC and RAM configuration, loader, joystick and VIA/display ownership. |
| `dragon` | `emu198x-dragon` | Specify Dragon model and BASIC/firmware, keyboard and 6809 caller; qualify load route. |
| `jupiter-ace` | `emu198x-jupiter-ace` | Qualify FORTH entry, keyboard and display servicing; add timing only under an explicit contract. |
| `mattel-aquarius` | `emu198x-mattel-aquarius` | Qualify firmware or cartridge entry and keyboard/display services. |
| `memotech-mtx` | `emu198x-memotech-mtx` | Specify firmware, banking and CTC/VDP ownership; qualify keyboard and program loading. |
| `microsoft-msx1` | `emu198x-msx` | Specify MSX1 firmware/model and cartridge-versus-BASIC route; BIOS and direct VDP ownership differ. |
| `nintendo-game-boy` | `emu198x-game-boy` | Qualify cartridge/reset, joypad selection and LCD access; deadline uses an explicit clock policy. |
| `nintendo-nes` | `emu198x-nes` | [Qualified frame-paced](../nintendo-entertainment-system/patterns/assembly/framework/game-loop/verification/results.json) |
| `oric` | `emu198x-oric-atmos` | Specify model/firmware and loading; preserve or take over OS keyboard/IRQ explicitly. |
| `sega-game-gear` | `emu198x-sega-game-gear` | [Qualified untimed-and-timed-turns](../sega-game-gear/patterns/assembly/framework/turn-deadline/verification/results.json) |
| `sega-master-system` | `emu198x-sega-master-system` | [Qualified untimed-and-timed-turns](../sega-master-system/patterns/assembly/framework/turn-deadline/verification/results.json) |
| `sega-sg-1000` | `emu198x-sega-sg-1000` | [Qualified untimed-and-timed-turns](../sega-sg-1000/patterns/assembly/framework/turn-deadline/verification/results.json) |
| `sinclair-zx-spectrum` | `emu198x-spectrum` | [Qualified frame-paced](../sinclair-zx-spectrum/patterns/assembly/framework/game-loop/verification/results.json) |
| `sinclair-zx80` | `emu198x-sinclair-zx80` | Qualify display and keyboard servicing; waiting for input must account for video generation. |
| `sinclair-zx81` | `emu198x-sinclair-zx81` | Qualify firmware/RAM and SLOW/FAST display ownership, input and loading. |
| `sord-m5` | `emu198x-sord-m5` | Qualify BIOS/cartridge entry, keyboard/controller and TMS9918 ownership. |
| `spectravideo-svi-328` | `emu198x-spectravideo-svi-328` | Qualify firmware/loading and keyboard/joystick; do not infer an MSX-compatible contract. |
| `tatung-einstein` | `emu198x-tatung-einstein` | Specify ROM/monitor versus disk OS entry, keyboard, CTC/VDP and loader. |

Validate the inventory with `python3 scripts/check-probe-coverage.py --registry /path/to/emu198x/docs/status/systems.toml`. The check requires exact registry membership and crate joins, non-empty proof for every qualified row, matching maintained source hashes and rejected negative controls. It does not rerun emulators or assert firmware availability.

Re-run frame callers with `scripts/verify-game-loops.py`; re-run the Sega turn callers with `scripts/verify-sega-turns.py --native /path/to/native/binaries`. Build-only and failed experiments must remain distinguishable from qualified behaviour.
