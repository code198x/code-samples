# A BBC Micro software sprite with save-under

`make` creates build/loader.bas. Type/load it into BBC Model B MOS1.20/BASICII; RUN selects MODE4, installs the original program at &3000 and moves an 8x8 shape over a patterned band. Reset to leave. MODE4 has 320x256 monochrome pixels; its &5800..&7FFF bitmap stores the eight scanlines of a character cell consecutively.

Include masked.inc once. The module owns user zero-page &70..&73, saved_screen[2], saved_background[8], mask_byte and image_byte. Screen_ptr (&70/&71) addresses one byte-aligned cell wholly within the MODE4 bitmap. Pairs_ptr (&72/&73) addresses 16 readable interleaved mask/image bytes, outside the destination/stack/saved state. Mask1 keeps the background, mask0 clears it; image bits must be zero wherever mask bits are1. A/Y/flags change, X survives; decimal mode must be clear. IRQ code must preserve these owned bytes and the working registers.

```asm
    ; Set screen_ptr to the cell and pairs_ptr to mask/image data.
    jsr save_background
    jsr draw_masked_cell
    ; Before moving:
    jsr restore_background
    ; Set the NEW screen_ptr, save, then draw again.
```

restore_background restores both the saved address into screen_ptr and all eight original screen bytes. There is one live save slot; allocate independent state or redesign the interface for multiple objects. Independently saved, overlapping objects require reverse-order restoration before capturing/drawing the next frame. If the background changes meanwhile, saved bytes are stale: redraw damaged tiles from the world instead.

This is an 8x8, byte-aligned primitive. It does not clip or shift to arbitrary pixel coordinates. Larger objects, pre-shifted masks, dirty rectangles and tile redraw are useful next techniques. It also does not handle CRTC start-address scrolling: the caller must translate logical cells through any altered screen mapping/wrap.

The demo keeps MOS IRQs active and uses OSBYTE19 for vertical sync, moving one cell per eight syncs. It reserves HIMEM=&3000, owns one patterned character row and the component state. The whole demo is not reentrant and does not return to BASIC; the reusable routines have no MOS calls.

## Verification

Run `scripts/verify-rendering-families.py --help` from the repository root for the released emulator paths and local firmware options. The retained record names the exact source/observer/tool hashes, independent memory checks, failing controls and complete-caller captures. A passing CPU/memory check does not establish a tear-free display, every timing standard, original hardware or a worst-case frame budget. Firmware is not distributed.
