# Runnable probe coverage

All **30 registry machines** have retained, configuration-specific execution records. Six callers are frame-paced; three Sega callers cover untimed turns and optional deadlines; thirteen use blocking BASIC/FORTH input; eight keep display service running while a new press advances a turn.

This is a qualification inventory, not thirty complete curriculum tracks or an equal-feature emulator certification. The four core teaching priorities remain unchanged. Future catalogue machines can join when their execution paths are available.

## Loading and dependencies

- **MTX:** the original caller now loads through stock BASIC using DATA/READ/POKE and USR. Its supplementary ROM-socket diagnostic is not the qualified loading path. Cassette loading remains open in [#261](https://github.com/emu198x/emu198x/issues/261) and [#263](https://github.com/emu198x/emu198x/issues/263).
- **Einstein:** stock MOS loads the original disk and executes its boot program after Ctrl-BREAK. This depends on [the runtime/native BREAK correction, PR #1872](https://github.com/emu198x/emu198x/pull/1872), commit `57a7453eeb3452d9f2be7ba4a453c13baa521a58`; it is not a CP/M application claim.
- **Atom:** the spaced BASIC listing needs [PR #1863](https://github.com/emu198x/emu198x/pull/1863), commit `7b16f8b7f86ae8f37ab3f1bf69f9b0d23a89fbb4`.
- **SVI-328:** the typed listing needs [PR #1865](https://github.com/emu198x/emu198x/pull/1865), commit `ab2e82189561dbd09150952f6818ef47278353f6`.

Firmware and native executable hashes are recorded for each run. A locally passing record against a fix branch does not claim that fix is already released. The registry is pinned independently of these executable revisions.

## Named configurations

| Machine ID | Caller | Evidence |
| --- | --- | --- |
| `acorn-atom` | [command-driven](../acorn-atom/patterns/basic/framework/command-loop/README.md) | [Execution record](../acorn-atom/patterns/basic/framework/command-loop/verification/results.json) |
| `acorn-bbc-micro` | [frame-paced](../bbc-micro/patterns/assembly/framework/game-loop/README.md) | [Execution record](../bbc-micro/patterns/assembly/framework/game-loop/verification/results.json) |
| `acorn-electron` | [frame-paced](../acorn-electron/patterns/assembly/framework/game-loop/README.md) | [Execution record](../acorn-electron/patterns/assembly/framework/game-loop/verification/results.json) |
| `amstrad-cpc` | [command-driven](../amstrad-cpc/patterns/basic/framework/command-loop/README.md) | [Execution record](../amstrad-cpc/patterns/basic/framework/command-loop/verification/results.json) |
| `atari-2600` | [input-driven-with-frame-service](../atari-2600/patterns/assembly/framework/input-loop/README.md) | [Execution record](../atari-2600/patterns/assembly/framework/input-loop/verification/results.json) |
| `atari-5200` | [input-driven-with-frame-service](../atari-5200/patterns/assembly/framework/input-loop/README.md) | [Execution record](../atari-5200/patterns/assembly/framework/input-loop/verification/results.json) |
| `atari-7800` | [input-driven-with-frame-service](../atari-7800/patterns/assembly/framework/input-loop/README.md) | [Execution record](../atari-7800/patterns/assembly/framework/input-loop/verification/results.json) |
| `atari-800xl` | [command-driven](../atari-800xl/patterns/basic/framework/command-loop/README.md) | [Execution record](../atari-800xl/patterns/basic/framework/command-loop/verification/results.json) |
| `coleco-colecovision` | [input-driven-with-frame-service](../coleco-colecovision/patterns/assembly/framework/input-loop/README.md) | [Execution record](../coleco-colecovision/patterns/assembly/framework/input-loop/verification/results.json) |
| `commodore-amiga` | [frame-paced](../commodore-amiga/patterns/assembly/framework/game-loop/README.md) | [Execution record](../commodore-amiga/patterns/assembly/framework/game-loop/verification/results.json) |
| `commodore-c64` | [frame-paced](../commodore-64/patterns/assembly/framework/game-loop/README.md) | [Execution record](../commodore-64/patterns/assembly/framework/game-loop/verification/results.json) |
| `commodore-pet` | [command-driven](../commodore-pet/patterns/basic/framework/command-loop/README.md) | [Execution record](../commodore-pet/patterns/basic/framework/command-loop/verification/results.json) |
| `commodore-vic-20` | [command-driven](../commodore-vic-20/patterns/basic/framework/command-loop/README.md) | [Execution record](../commodore-vic-20/patterns/basic/framework/command-loop/verification/results.json) |
| `dragon` | [command-driven](../dragon-32/patterns/basic/framework/command-loop/README.md) | [Execution record](../dragon-32/patterns/basic/framework/command-loop/verification/results.json) |
| `jupiter-ace` | [key-driven-forth](../jupiter-ace/patterns/forth/framework/command-loop/README.md) | [Execution record](../jupiter-ace/patterns/forth/framework/command-loop/verification/results.json) |
| `mattel-aquarius` | [command-driven](../mattel-aquarius/patterns/basic/framework/command-loop/README.md) | [Execution record](../mattel-aquarius/patterns/basic/framework/command-loop/verification/results.json) |
| `memotech-mtx` | [input-driven-with-frame-service](../memotech-mtx/patterns/assembly/framework/input-loop/README.md) | [Execution record](../memotech-mtx/patterns/assembly/framework/input-loop/verification/results.json) |
| `microsoft-msx1` | [command-driven](../msx/patterns/basic/framework/command-loop/README.md) | [Execution record](../msx/patterns/basic/framework/command-loop/verification/results.json) |
| `nintendo-game-boy` | [input-driven-with-frame-service](../nintendo-game-boy/patterns/assembly/framework/input-loop/README.md) | [Execution record](../nintendo-game-boy/patterns/assembly/framework/input-loop/verification/results.json) |
| `nintendo-nes` | [frame-paced](../nintendo-entertainment-system/patterns/assembly/framework/game-loop/README.md) | [Execution record](../nintendo-entertainment-system/patterns/assembly/framework/game-loop/verification/results.json) |
| `oric` | [command-driven](../oric-atmos/patterns/basic/framework/command-loop/README.md) | [Execution record](../oric-atmos/patterns/basic/framework/command-loop/verification/results.json) |
| `sega-game-gear` | [untimed-and-timed-turns](../sega-game-gear/patterns/assembly/framework/turn-deadline/README.md) | [Execution record](../sega-game-gear/patterns/assembly/framework/turn-deadline/verification/results.json) |
| `sega-master-system` | [untimed-and-timed-turns](../sega-master-system/patterns/assembly/framework/turn-deadline/README.md) | [Execution record](../sega-master-system/patterns/assembly/framework/turn-deadline/verification/results.json) |
| `sega-sg-1000` | [untimed-and-timed-turns](../sega-sg-1000/patterns/assembly/framework/turn-deadline/README.md) | [Execution record](../sega-sg-1000/patterns/assembly/framework/turn-deadline/verification/results.json) |
| `sinclair-zx-spectrum` | [frame-paced](../sinclair-zx-spectrum/patterns/assembly/framework/game-loop/README.md) | [Execution record](../sinclair-zx-spectrum/patterns/assembly/framework/game-loop/verification/results.json) |
| `sinclair-zx80` | [numeric-running-total](../sinclair-zx80/patterns/basic/framework/command-loop/README.md) | [Execution record](../sinclair-zx80/patterns/basic/framework/command-loop/verification/results.json) |
| `sinclair-zx81` | [numeric-running-total](../sinclair-zx81/patterns/basic/framework/command-loop/README.md) | [Execution record](../sinclair-zx81/patterns/basic/framework/command-loop/verification/results.json) |
| `sord-m5` | [input-driven-with-frame-service](../sord-m5/patterns/assembly/framework/input-loop/README.md) | [Execution record](../sord-m5/patterns/assembly/framework/input-loop/verification/results.json) |
| `spectravideo-svi-328` | [command-driven](../spectravideo-svi-328/patterns/basic/framework/command-loop/README.md) | [Execution record](../spectravideo-svi-328/patterns/basic/framework/command-loop/verification/results.json) |
| `tatung-einstein` | [input-driven-with-frame-service](../tatung-einstein/patterns/assembly/framework/input-loop/README.md) | [Execution record](../tatung-einstein/patterns/assembly/framework/input-loop/verification/results.json) |

## Re-run and extend

Validate retained coverage with:

```sh
python3 scripts/check-probe-coverage.py --registry /path/to/emu198x/docs/status/systems.toml
python3 -m unittest discover -s scripts -p test_probe_coverage.py -v
```

The check requires exact registry membership and crate joins, non-empty identified sources, unchanged maintained source hashes and rejected negative controls. It does not rerun emulators or assert firmware availability. CI checks those retained claims; it does not ship private firmware.

Rerun the frame callers with `scripts/verify-game-loops.py`; Sega callers with `scripts/verify-sega-turns.py`; BASIC command callers with `scripts/verify-command-loops.py`; hardware input callers with `scripts/verify-hardware-input-loops.py`; Ace with `scripts/verify-ace-command-loop.py`; and ZX80/ZX81 with `scripts/verify-zx-command-loops.py`. These drivers take native executable and firmware paths; each caller README gives its build/startup contract.

Choose the next probe by the capability a program needs. Add joystick/analogue ranges, richer drawing, audio, storage, alternative firmware/model variants and deadline policies explicitly rather than inferring them from one passing caller. A turn-based game can have a deadline; an input/output game can have no game clock at all. Mandatory video service does not make an idle turn advance.
