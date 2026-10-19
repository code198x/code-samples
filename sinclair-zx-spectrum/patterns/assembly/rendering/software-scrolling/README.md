# Scroll a Spectrum bitmap band

`make` creates `build/demo.tap`; LOAD "" on a 48K Spectrum. A 48-line tiled band moves left, with new edge pixels generated each update. Reset to leave.

Include `scroll.inc` and `../bitmap-addressing/bitmap-addressing.inc` once. Pass HL pointing to one readable edge byte per scanline (bit 0 only), D=top pixel row and B=height. Height zero is a no-op. Otherwise top+height must be <=192. The routine scrolls the full 256-pixel width left by one pixel, injecting each supplied edge bit at X=255. Input data must not overlap the bitmap or active stack.

HL advances by height. AF/BC/DE change, IX/IY survive. No writable static state is used; temporary stack depth is eight bytes in addition to the caller return address and any interrupt stack use. The screen bitmap changes; attributes, border, ROM and interrupts do not. The caller owns synchronisation and must prevent another renderer from modifying the same band concurrently.

```z80
    ld hl,next_edge
    ld d,72
    ld b,48
    call scroll_band_left
```

The operation visits 32*height bitmap bytes on every call. Reducing height reduces that work directly. It deliberately scrolls pixels without scrolling attributes: uniform colours suit the demo; coloured tile worlds need a separate coarse attribute policy. Faster approaches include character steps, pre-shifted tile columns, narrower playfields and specialised unrolled routines, each with different memory and code costs.

The demo uses a ROM IM1 frame interrupt, owns the bitmap/attributes and private stack at $FF00, and runs from $8000. It does not return to BASIC. Include the pure routine in a different caller when those ownership choices do not suit your game.

## Verification

Run `scripts/verify-rendering-families.py --help` from the repository root for the released emulator paths and local firmware options. The retained record names the exact source/observer/tool hashes, independent memory checks, failing controls and complete-caller captures. A passing CPU/memory check does not establish a tear-free display, every timing standard, original hardware or a worst-case frame budget. Firmware is not distributed.
