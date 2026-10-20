# Tile maps and queries across the system registry

A tile map is game data. A tile query need not touch the display. This tranche supplies map/query routines across all 30 registry machines: ten numeric-array BASIC implementations and twenty native byte-map callers using four maintained CPU includes. The BASIC group adds ten machines outside the four core systems and BBC Micro, using their stock interpreter loading paths. Region drawing here uses text cells: it does not qualify native tile graphics, bitmap rendering or scrolling.

At inspected baseline 515cef62bb93fcd68b6f9703c445d8b2bc38c279 there was no dedicated tile-map Pattern Library family. Existing material to reuse and link:

- `sinclair-zx-spectrum/basic/crates/unit-03/walls.bas`: map-backed movement and walls within a complete teaching project.
- `sinclair-zx-spectrum/basic/the-caverns/unit-01/map.bas`: a complete map caller.
- `sinclair-zx-spectrum/assembly/shadowkeep/unit-04/steps/step-01.asm`: lookup and tile drawing within a game.
- `sinclair-zx-spectrum/test/tile-renderer-validation/tile-renderer-test.asm`: an existing renderer investigation, not evidence for other machines.
- `nintendo-entertainment-system/assembly/dash/unit-07/snippets/01-tile-collision.asm`: game-specific tile collision.

## All 30 systems

This table distinguishes new reusable code from an existing load path. Every registry row now links a reusable implementation; evidence levels differ deliberately. Shared CPUs do not transfer execution evidence. BASIC, assembly and FORTH remain eligible; no common language is required.

| Registry machine | Reusable implementation | Evidence scope |
| --- | --- | --- |
| `acorn-atom` | [Source and contract](../../acorn-atom/patterns/basic/rendering/tile-map/README.md) | Stock BASIC numeric map and text region |
| `acorn-bbc-micro` | [Source and contract](../../bbc-micro/patterns/assembly/rendering/tile-map/README.md) | Native byte map; original CPU/RAM diagnostic, separate stock-loader/display work |
| `acorn-electron` | [Source and contract](../../acorn-electron/patterns/assembly/rendering/tile-map/README.md) | Native byte map; original CPU/RAM diagnostic, separate stock-loader/display work |
| `amstrad-cpc` | [Source and contract](../../amstrad-cpc/patterns/basic/rendering/tile-map/README.md) | Stock BASIC numeric map and text region |
| `atari-2600` | [Source and contract](../../atari-2600/patterns/assembly/rendering/tile-map/README.md) | Native byte map; original CPU/RAM diagnostic, separate stock-loader/display work |
| `atari-5200` | [Source and contract](../../atari-5200/patterns/assembly/rendering/tile-map/README.md) | Native byte map; original CPU/RAM diagnostic, separate stock-loader/display work |
| `atari-7800` | [Source and contract](../../atari-7800/patterns/assembly/rendering/tile-map/README.md) | Native byte map; original CPU/RAM diagnostic, separate stock-loader/display work |
| `atari-800xl` | [Source and contract](../../atari-800xl/patterns/basic/rendering/tile-map/README.md) | Stock BASIC numeric map and text region |
| `coleco-colecovision` | [Source and contract](../../coleco-colecovision/patterns/assembly/rendering/tile-map/README.md) | Native byte map; original CPU/RAM diagnostic, separate stock-loader/display work |
| `commodore-amiga` | [Source and contract](../../commodore-amiga/patterns/assembly/rendering/tile-map/README.md) | Native byte map; original CPU/RAM diagnostic, separate stock-loader/display work |
| `commodore-c64` | [Source and contract](../../commodore-64/patterns/assembly/rendering/tile-map/README.md) | Native byte map; original CPU/RAM diagnostic, separate stock-loader/display work |
| `commodore-pet` | [Source and contract](../../commodore-pet/patterns/basic/rendering/tile-map/README.md) | Stock BASIC numeric map and text region |
| `commodore-vic-20` | [Source and contract](../../commodore-vic-20/patterns/basic/rendering/tile-map/README.md) | Stock BASIC numeric map and text region |
| `dragon` | [Source and contract](../../dragon-32/patterns/basic/rendering/tile-map/README.md) | Stock BASIC numeric map and text region |
| `jupiter-ace` | [Source and contract](../../jupiter-ace/patterns/assembly/rendering/tile-map/README.md) | Native byte map; original CPU/RAM diagnostic, separate stock-loader/display work |
| `mattel-aquarius` | [Source and contract](../../mattel-aquarius/patterns/basic/rendering/tile-map/README.md) | Stock BASIC numeric map and text region |
| `memotech-mtx` | [Source and contract](../../memotech-mtx/patterns/assembly/rendering/tile-map/README.md) | Native byte map; original CPU/RAM diagnostic, separate stock-loader/display work |
| `microsoft-msx1` | [Source and contract](../../msx/patterns/basic/rendering/tile-map/README.md) | Stock BASIC numeric map and text region |
| `nintendo-game-boy` | [Source and contract](../../nintendo-game-boy/patterns/assembly/rendering/tile-map/README.md) | Native byte map; original CPU/RAM diagnostic, separate stock-loader/display work |
| `nintendo-nes` | [Source and contract](../../nintendo-entertainment-system/patterns/assembly/rendering/tile-map/README.md) | Native byte map; original CPU/RAM diagnostic, separate stock-loader/display work |
| `oric` | [Source and contract](../../oric-atmos/patterns/basic/rendering/tile-map/README.md) | Stock BASIC numeric map and text region |
| `sega-game-gear` | [Source and contract](../../sega-game-gear/patterns/assembly/rendering/tile-map/README.md) | Native byte map; original CPU/RAM diagnostic, separate stock-loader/display work |
| `sega-master-system` | [Source and contract](../../sega-master-system/patterns/assembly/rendering/tile-map/README.md) | Native byte map; original CPU/RAM diagnostic, separate stock-loader/display work |
| `sega-sg-1000` | [Source and contract](../../sega-sg-1000/patterns/assembly/rendering/tile-map/README.md) | Native byte map; original CPU/RAM diagnostic, separate stock-loader/display work |
| `sinclair-zx-spectrum` | [Source and contract](../../sinclair-zx-spectrum/patterns/assembly/rendering/tile-map/README.md) | Native byte map; original CPU/RAM diagnostic, separate stock-loader/display work |
| `sinclair-zx80` | [Source and contract](../../sinclair-zx80/patterns/assembly/rendering/tile-map/README.md) | Native byte map; original CPU/RAM diagnostic, separate stock-loader/display work |
| `sinclair-zx81` | [Source and contract](../../sinclair-zx81/patterns/assembly/rendering/tile-map/README.md) | Native byte map; original CPU/RAM diagnostic, separate stock-loader/display work |
| `sord-m5` | [Source and contract](../../sord-m5/patterns/assembly/rendering/tile-map/README.md) | Native byte map; original CPU/RAM diagnostic, separate stock-loader/display work |
| `spectravideo-svi-328` | [Source and contract](../../spectravideo-svi-328/patterns/basic/rendering/tile-map/README.md) | Stock BASIC numeric map and text region |
| `tatung-einstein` | [Source and contract](../../tatung-einstein/patterns/assembly/rendering/tile-map/README.md) | Native byte map; original CPU/RAM diagnostic, separate stock-loader/display work |

## Next native paths

The native byte-map group includes the consoles, Ace and ZX80/81 without forcing a BASIC dialect on them. Their original diagnostic reset ROMs/cartridges establish CPU/RAM execution, not a stock interpreter loading path. FORTH wrappers on Ace, Sinclair BASIC wrappers and normal tape/disk loaders remain worthwhile additions. The text-map ports do not automatically supply a Spectrum, BBC, Electron or Amiga renderer.

Native drawing must qualify the actual selected display mode and loader. Separate tile IDs/properties from glyph or pattern indices, colours, attributes and any write queue. Reuse existing scrolling entries where relevant, but record map streaming, camera conversion, attribute updates, bank access and frame budgets separately. Small-RAM machines can query ROM maps and keep sparse changes rather than allocate a full writable map. That is a follow-on variant, not a claim made by the numeric-array implementation.

## Repeat and inspect the checks

`python3 scripts/check-tilemaps.py` checks retained evidence against the current source, complete registry and decoded captures. `python3 -m unittest discover -s scripts -p test_tilemaps.py -v` checks that missing machines, changed routines, incomplete controls and widened claims fail. Neither requires restricted firmware.

The original execution used Emu198x source `373c85ad2b76aa6ac765776f9840b4d6951b3aed`. Each record identifies its exact binary and any locally supplied firmware by hash. Native diagnostics built identically with Asm198x 0.0.65 and 0.0.71; the comparison is retained in `verification/assembler-compatibility.json`.

To repeat guest execution, build that emulator revision and use `scripts/verify-tilemaps.py --native /path/to/binaries` with your own stock firmware for BASIC, or `scripts/verify-native-tilemaps.py --native /path/to/binaries --assembler /path/to/asm198x` for original native fixtures. Both commands have bounded observations and failure controls. Inspect `--help` for individual-system selection.

Aquarius uses no expansion for the distributed demo; its larger verification callers use 16 KB expansion. Oric verification reads back the accepted tokenised program and repairs damaged keyboard entry through the keyboard, waiting for ROM line editing before continuing. A verification-only line disables its blinking cursor using the Atmos manual’s CHR$(17) control; the distributed caller is unchanged. These controls cannot turn a wrong query result into a pass: every completed output still has to match its independent reference.

## Native region drawing

Nine targets now have separately executed region-drawing implementations: ColecoVision, Sord M5, MTX, Einstein, MSX1, SVI-328, SG-1000, Master System and Game Gear. See [the component contract](../../cross-platform/patterns/rendering/tile-region/README.md), each machine's `tile-region` folder and `region_drawing` in the coverage inventory. The existing `native_graphics` field remains scoped to what the earlier map-query evidence proves; it does not override these separate records. Four more targets now have separately executed CPU bitmap regions: BBC Micro MODE 4, Acorn Atom monochrome, Dragon 32 PMODE 4 and Amstrad CPC MODE 1. See [the bitmap component contract](../../cross-platform/patterns/rendering/bitmap-regions/README.md). Their `executed-cpu-bitmap` records include whole-memory and native pixel comparisons plus isolated rejection checks. The remaining 17 rows stay `not-yet-qualified` for region drawing, rather than unsupported.
