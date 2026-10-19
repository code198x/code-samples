# An Amiga bob lifecycle with the blitter

`make` builds `build/demo.adf` using Asm198x and Build198x. Boot on A500 OCS PAL/Kickstart1.3. Two word-aligned 32x16 one-bitplane objects overlap; one moves in 16-pixel steps. The program takes over the custom chips and does not return to the OS; reset to leave. This uses blitter objects (bobs), not hardware sprite DMA channels.

Include bob.inc once. Callers provide every buffer; the module has no static save slots. D0=width in 16-bit words (0..64), D1=height (0..1024), D2=screen row stride in bytes. Zero width/height is a no-op, not the hardware maximum-size encoding. Non-empty sizes require even stride, 2*width<=stride<=32766, even pointers and every accessed byte in owned chip RAM. All ranges fit chip RAM without wrap and buffers do not overlap code, stack, sources or each other. Packed source/save rows contain 2*width bytes each.

- bob_save: A0=screen rectangle; A1=packed save buffer.
- bob_restore: A0=packed save buffer; A1=screen rectangle at its OLD position.
- bob_draw: A0=opaque mask; A1=image; A2=screen rectangle. A mask bit1 selects the image, bit0 keeps the background. This is the opposite mask convention from the Spectrum/BBC keep masks.

All three change D0,D3-D5,A5 and CCR; D1,D2/A0-A2 survive. Each non-empty operation waits for the previous blit before programming registers and waits for its own completion before returning. The caller enables blitter/master DMA and owns the blitter for the entire operation; different buffers do not make concurrent blitter callers safe. If integrating with AmigaOS, use its blitter ownership protocol rather than the demo's takeover startup.

The rectangle copy uses A/D and mintermF0. Drawing uses A=mask, B=image, C=old screen, D=screen with mintermCA. Modulos bridge the packed source rows and the screen stride. Width64/height1024 are encoded as zero in BLTSIZE only after the software no-op checks. First/last word masks are all ones; shifts are zero. No clipping or partial-word positioning is provided.

```m68k
    lea under_b,a0
    move.l old_b,a1
    moveq #2,d0         ; 32 pixels
    moveq #16,d1
    moveq #40,d2        ; 320-pixel bitplane stride
    bsr bob_restore
    ; Restore A next; then change positions and save/draw A followed by B.
```

Each live object needs its previous rectangle address and width*2*height saved bytes PER bitplane. Loop over planes for a colour bob, keeping the same silhouette mask and separate old backgrounds; that extension is not implemented by this one-plane caller. A changed background invalidates saved bytes. Remove old objects first, update the world/background, then capture/draw the next frame, or use a dirty-tile/back-buffer approach.

The demo owns all custom chips, its copper list, plane and chip-RAM data. It uses the existing VERTB polling wait. Blitter bandwidth is shared with other DMA users; a successful memory result does not qualify a full game's deadline. Arbitrary-X shifted bobs, clipping, asynchronous job queues and hardware-sprite reuse remain separate techniques.

Hardware basis: Amiga Hardware Reference Manual, chapter6 (blitter channels, minterms, size, modulos and busy wait): https://www.theflatnet.de/pub/cbm/amiga/AmigaDevDocs/hard_6.html . The code is original Code198x implementation.

## Run the verification

From the repository root run `python3 scripts/verify-sprite-lifecycle.py --help`. Supply the released assembler, Build198x and the three native emulators. Firmware defaults to the normal per-user emulator locations and remains local. The retained record identifies source, observers, tools and firmware; cases compare complete byte results with independent composition/restoration expectations. Wrong-order and broken-operation controls must fail those same checks. Complete callers and their captures are separate checks. No original-hardware, tear-free or whole-game frame-budget claim is made.
