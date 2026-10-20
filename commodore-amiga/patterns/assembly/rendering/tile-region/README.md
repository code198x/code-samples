# Amiga A500: native region drawing

Use `region_draw` to copy a checked region of byte-map IDs into A500 PAL, two bitplanes; CPU and blitter. A cell is 16×8 pixels; the selected logical destination is 20×32 cells.

Read the [shared contract, hardware differences, costs and sources](../../../../../cross-platform/patterns/rendering/region-architectures/README.md). The maintained routine is [m68000 source](../../../../../cross-platform/patterns/rendering/region-architectures/m68000.inc). `demo.asm` supplies working initialisation, memory symbols/context, assets and a complete original reset diagnostic. Bring those allocations into your own project, include the routine once, set the six request bytes as in `case_0`, call it, then check valid at +6. The contracts differ by CPU; they do not form a shared binary ABI.

The caller owns display configuration, context, source/assets, destination and interrupt policy. Requests which do not fit are rejected before writing; clipping, transparency and live-display queues require other variants. Keep the source and display state stable across preflight and drawing.

```sh
make
```

This creates `build/fixture.bin`, an original reset fixture, not a stock-OS application. No manufacturer firmware is included. The shared observer runs it with released Emu198x/Asm198x; `verification/` retains exact sources, complete memory, native images, isolated rejected calls and completed failing controls. Read the shared contract for the precise qualification and remaining hardware/OS/timing boundaries.
