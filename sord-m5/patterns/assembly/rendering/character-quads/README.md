# Four-tile characters on sord-m5

Build `demo.asm` with `make ASM198X=/path/to/qualified/asm198x`. `customise.asm` changes the source shape, slot allocation and origin; `build.py --variant customise` builds it independently. The unchanged native video/reset/ports from this machine's adjacent custom-glyphs caller remain explicit in caller.inc.

See [the shared contract](../../../../../cross-platform/patterns/rendering/character-quads/README.md) for inclusion, init/install/place, G/Q state, accepted ranges, video ownership, customisation, wrong/fixed row stride, work/storage costs and exact evidence scope. `verification/results.json` binds this machine's separately executed retained observations to source and tools. No manufacturer firmware, stock-OS coexistence or original-hardware timing is implied.
