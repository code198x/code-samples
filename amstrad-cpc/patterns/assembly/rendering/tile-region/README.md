# Amstrad CPC: redraw a bitmap region

Use `region_draw` for an 8×8-tile rectangle in MODE 1. The reusable z80 source is [the shared CPU include](../../../../../cross-platform/patterns/rendering/bitmap-regions/z80.inc); the complete [calling contract, layout, costs, sources and alternatives](../../../../../cross-platform/patterns/rendering/bitmap-regions/README.md) applies.

`demo.asm` supplies the compile-time symbols, original tile data, low/high scanline tables and a separate reset driver. Define those in your own memory layout, include the CPU routine once, set the six bytes in `case_0`, call `region_draw`, and check `NR+6`. Your renderer owns the bitmap and tables. Keep them stable during the call; reserve 32 context bytes and stack space. The routine neither configures video nor changes interrupt state.

The selected bitmap is 320×200, 40×25 cells, with 2 byte(s) per tile scanline and horizontal address step 2. Its base is $C000. The code is opaque replacement, with bounds/ID rejection rather than clipping or masking.

```sh
make
```

This creates an original diagnostic ROM under `build/`, not a stock-OS application. The builder supplies the machine's required ROM envelope/vectors. No manufacturer firmware is included. Full execution and capture instructions are in the shared contract.

`verification/` retains all 18-case output, fifteen isolated rejected calls, two deliberately broken controls, bitmap memory and captures. The qualification is released Emu198x 0.39.0 and Asm198x 0.0.71; it is not a hardware timing or firmware-coexistence claim.
