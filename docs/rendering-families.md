# Scrolling and sprite family coverage

Shared family entries connect machine-specific code; absence of an implementation is a gap, not a reason to define the pattern as belonging only to the first machine. Existing direct URLs are preserved. This inventory covers the exact 30-machine probe registry pinned by capability-coverage.json; it does not promote probes to complete rendering or curriculum support. Future catalogue systems remain eligible.

## Current reusable implementations and immediate gaps

- Spectrum pixel-band software scrolling: new include and complete ROM-loaded tape. Bitmap only; no attribute streamer, clipping or tear-free guarantee.
- C64 fine/coarse text scrolling: reuse the existing maintained routine and PAL memory/register evidence. Coarse-step presentation budgeting remains open.
- NES nametable scrolling: new include and complete NTSC NROM scene; 512-pixel repeating world, no endless column/attribute streaming. Retains the original website route.
- C64 hardware sprites and fixed-band multiplexer: reuse their existing per-configuration evidence. They are not arbitrary-Y scheduling or same-line over-capacity.
- Spectrum masked sprite: reuse the maintained drawing primitive with the new explicit-buffer rectangle helpers and a two-object save/draw/restore caller. Clipping, arbitrary pixel shifts and attribute restoration remain open.
- NES OAM builder: new complete-page packing, hiding, validation and optional rotation. Sixty-four slots do not remove the eight-entry scanline limit. Single-tile 8x8 objects only.
- BBC Micro MODE4 masked object: new byte-aligned 8x8 primitive, one save slot and complete MOS-synchronised caller. Other mappings/modes need separate code and checks.
- Amiga: new word-aligned one-plane blitter save/draw/restore routines and an executed A500 OCS PAL caller. The existing shifted cookie-cut and hardware-sprite-control entries remain illustrative; complete scrolling, clipped/shifted colour bobs and sprite DMA reuse remain gaps.

## Every currently probed machine

This table records reusable-family coverage, not a hardware support matrix. For rows without an implementation the next step is a manual-backed capability/constraint inventory followed by a minimal caller. No shared CPU or display chip transfers an execution claim between rows.

| Registry machine | Scrolling | Sprites |
| --- | --- | --- |
| `acorn-atom` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `acorn-bbc-micro` | Complete scrolling caller remains open; MOS loop is a scheduling building block. | MODE4 byte-aligned drawing and explicit-buffer overlapping-object lifecycle executed; pixel alignment/clipping/CRTC-aware mapping open. |
| `acorn-electron` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `amstrad-cpc` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `atari-2600` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `atari-5200` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `atari-7800` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `atari-800xl` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `coleco-colecovision` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `commodore-amiga` | Complete scrolling caller remains open; existing blitter-copy listing illustrative. | New word-aligned bob lifecycle executed; sprite-control/shifted listings remain illustrative, and DMA reuse/colour/clipping remain open. |
| `commodore-c64` | Existing fine/coarse shift: memory/register evidence; presentation budget open. | Existing hardware sprites and fixed two-band multiplexing: PAL/NTSC evidence; arbitrary-Y scheduler open. |
| `commodore-pet` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `commodore-vic-20` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `dragon` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `jupiter-ace` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `mattel-aquarius` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `memotech-mtx` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `microsoft-msx1` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `nintendo-game-boy` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `nintendo-nes` | New finite two-nametable caller and scroll routine; endless streaming/attribute updates open. | New OAM packing/rotation: NTSC execution; metasprites/reservations/scanline admission open. |
| `oric` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `sega-game-gear` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `sega-master-system` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `sega-sg-1000` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `sinclair-zx-spectrum` | Pixel-band scroll: new code and execution; full map/attribute streamer remains open. | Masked drawing plus explicit-buffer rectangle restoration executed; pre-shifting, clipping and attribute restoration remain open. |
| `sinclair-zx80` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `sinclair-zx81` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `sord-m5` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `spectravideo-svi-328` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |
| `tatung-einstein` | No dedicated implementation in this tranche; inventory and qualify the display path. | No dedicated implementation in this tranche; inventory hardware limits and software alternatives. |

## Next qualification slices

1. Qualify Amiga scrolling and extend the now-checked word-aligned bob lifecycle to shifted/clipped and colour variants; compare CPU, blitter and sprite DMA ownership rather than promising a single resource cost.
2. Add BBC character/bitmap scrolling, then CRTC start-address scrolling with wrapping; connect sprite address mapping to it. Extend Spectrum edge generation to tile/attribute streaming and clipped moving objects. Separate-buffer restoration now has its own executable component.
3. Qualify the existing NES column-feeding concept with an actual map, attribute-quadrant merging and a bounded publication queue. Add metasprite grouping and fixed-priority slot reservations before more elaborate overload policies.
4. Add separately qualified implementations on other registry machines. Share source when appropriate, but keep each loader, memory layout, display mode and execution record explicit. Use the current probe loaders as starting points, not as rendering qualification.
5. Extend to catalogue systems as runnable build/loading paths become available. These slices do not commission a bulk curriculum rewrite or imply every machine supports every branch.

## Evidence and costs

verification/results.json records independent bitmap, OAM and background-restoration results, rejected mutants and actual caller captures. The fresh NES CI check runs without firmware. A separate hash guard rejects stale sources, missing case groups or changed captures; it does not replace execution. Existing C64 and Spectrum records remain with their own routines.

Do not confuse a correct memory transformation, a running screenshot and a measured frame deadline. Account for the full update, including coarse boundaries, interrupt service, audio and object removal. Advanced branches need concrete code and their own workload evidence before being labelled implemented.
