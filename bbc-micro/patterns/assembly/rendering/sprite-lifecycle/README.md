# Two BBC software objects with explicit save buffers

`make` creates `build/loader.bas`. Load/type and RUN in BBC Model B BASICII/MOS1.20. MODE4 shows two 8x8 objects, with one moving through the other's cell. The caller keeps MOS IRQs and OSBYTE19 sync, reserves HIMEM=&3000, and resets to leave.

Include background.inc with the existing masked-sprites/masked.inc. The new save_cell_to_buffer and restore_cell_from_buffer use screen_ptr=&70/&71 and a caller-selected back_ptr=&74/&75. Each object needs eight separate saved bytes AND its previous screen-cell address. They complement the existing one-save-slot example; they do not change its interface or use its global saved_background slot. The old include's unused single-slot routines/state remain available but are not used by this caller.

screen_ptr must select a complete byte-aligned 8x8 character cell in the ordinary MODE4 bitmap (&5800..&7FFF). back_ptr addresses eight readable/writable bytes, separate from bitmap, sources, code, stack and other live buffers. pairs_ptr=&72/&73 still supplies interleaved mask/image data for draw_masked_cell. A/Y/flags change; X survives. Interrupts must preserve the owned registers and user zero-page. Separate buffers allow sequential objects, not concurrent access through the shared pointers.

```asm
    ; Select A's screen cell and under_a buffer.
    jsr save_cell_to_buffer
    jsr draw_masked_cell
    ; Select B's cell and under_b, then save/draw B.
    ; Next update: select OLD B and restore B, then select OLD A and restore A.
```

The new helpers have no static save slot. Restore does not remember an address; the caller supplies it. This avoids confusing a new position with the old region that must be erased. Save/draw A then B, restore B then A. When objects share the cell, B's saved bytes contain A, so the reverse ordering is essential.

The primitives remain byte aligned and 8x8. They do not clip, shift or translate a CRTC-scrolled screen. If the world changed under an object, saved bytes are stale: restore before updating the background, or rebuild dirty tiles from world state instead. Larger objects and different modes need their own layout and qualification.

## Run the verification

From the repository root run `python3 scripts/verify-sprite-lifecycle.py --help`. Supply the released assembler, Build198x and the three native emulators. Firmware defaults to the normal per-user emulator locations and remains local. The retained record identifies source, observers, tools and firmware; cases compare complete byte results with independent composition/restoration expectations. Wrong-order and broken-operation controls must fail those same checks. Complete callers and their captures are separate checks. No original-hardware, tear-free or whole-game frame-budget claim is made.
