# Pixel-positioned Amiga bobs with prepared phases

Build `make ASM198X=/path/to/asm198x BUILD198X=/path/to/build198x-adf` (or use the publishing default build198x adf). Boot build/demo.adf on A500 OCS PAL/KS1.3. The caller owns custom chips and a 320x256 one-plane screen; reset to exit.

Include phase.inc, ../clipped-sprites/clip.inc and ../clipped-sprites/draw.inc once, plus a generated bank in chip RAM. `draw_pixel_sprite` takes D0.w signed PIXEL X, D1.w Y, A2 screen pointer and A3 a sixteen-entry table of mask/image pointer pairs. It derives phase with the low four bits, divides X arithmetically by sixteen, then calls the existing word-aligned clipped renderer. Reload inputs as needed from your object's own state.

D0-D7/A0-A5 survive; CCR changes. The wrapper saves 36 stack bytes in addition to the nested renderer's 68, plus returns and interrupt needs. Every pointer is even; source/table/screen/code/stack are owned chip RAM and separate. Enable blitter DMA and exclude other blitter users for the whole synchronous call. No OS/interrupt/copper ownership or queue is set up by the include.

Original art is sixteen pixels wide. Each prepared phase is padded to 32x16, with separate opaque mask (1=image) and image planes, 64 bytes each. Sixteen phases use 2048 bytes, plus 128 table bytes: 2176 bytes per bank versus 64 unshifted bytes. This polarity differs from Spectrum/BBC KEEP masks. The existing clipped renderer preserves four-byte source rows and forty-byte screen rows. Fully invisible objects start no blit.

This deliberately spends chip RAM to reuse a checked word-aligned clipping path. The Amiga also has hardware A/B barrel shifters; that natural onward branch needs its own source-width, carry and edge-mask checks. See Amiga Hardware Reference Manual chapter6, Shifts and Masks: https://www.theflatnet.de/pub/cbm/amiga/AmigaDevDocs/hard_6.html. Prepared phases are an alternative, not a universal performance recommendation. A save-under buffer covers the old padded/clipped footprint (up to64bytes here), even when the logical object is only16pixels wide.

The original art is `cross-platform/patterns/rendering/pre-shifted-sprites/sprite.json`: sixteen strings of sixteen samples. `.` is transparent, `0` opaque off, `1` opaque ink. Run `make regenerate` to replace generated phases.inc, and `make check-assets` to reject a stale generated file. `prepare.py --prefix another_sprite` gives another bank distinct assembly labels; pass its table to the same runtime routine. No image packages are required.

Pre-shifting moves work to asset preparation and spends memory. The complete phase gallery is static and continues frame waits; it proves pixel placement, clipping and source preservation, not animation cadence or an entire game's frame budget. Runtime shifting, fewer stored phases or specialised hardware can be better choices under different budgets. Execution evidence is in `docs/sprite-phases/verification/`; firmware and snapshots remain local.
