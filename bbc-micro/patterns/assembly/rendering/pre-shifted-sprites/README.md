# Pixel-positioned BBC MODE4 sprites

Build `make ASM198X=/path/to/asm198x` and type build/loader.bas on Model B MOS1.20/BASICII. The hexadecimal DATA loader reserves HIMEM=&4000, enters machine code at &4000, and uses EVAL to read generated &HH literals. The caller owns memory below the normal MODE4 bitmap at &5800, uses OSBYTE19 after drawing and requires reset to leave.

Include phase.inc, draw.inc and ../clipped-sprites/clip.inc once, plus a generated bank. Set clip_ptr ($70/$71) to 32 exclusive bytes: signed PIXEL X +0, signed Y +14 and eight-entry phase pointer table +28. X/table are consumed: they become signed byte-column X and the chosen source pointer. Reload those inputs before each call, retaining logical position elsewhere.

A/X/Y/P change; decimal mode must be clear. Own zero-page $70..$78 and context, and preserve them in interrupt users. The includes do not set up IRQs, screen mode or display timing. Source/table/context/code/stack must be disjoint from the bitmap and one another. The address mapper assumes normal unscrolled MODE4, forty byte columns and 320 bytes per eight-row character band; it handles page carries. Other CRTC starts need a different mapper.

The 24x16 prepared footprint has 96 interleaved KEEP-mask/image bytes. An entire bank is 784 bytes, including sixteen table bytes, versus 64 unshifted bytes. Each source row remains six bytes after cropping. Two source-pointer bytes are pushed per copied row, in addition to JSR returns and IRQ use. The wrapper derives phase from the low three pixel-X bits, and arithmetic division rounds negative coordinates down.

The existing 8x8 cell-save primitive is too small for this footprint. Movement needs a suitably sized background store or redraw from tile/world data. The gallery deliberately leaves erasure to its caller; it does not disguise a one-cell helper as a complete backing store.

The original art is `cross-platform/patterns/rendering/pre-shifted-sprites/sprite.json`: sixteen strings of sixteen samples. `.` is transparent, `0` opaque off, `1` opaque ink. Run `make regenerate` to replace generated phases.inc, and `make check-assets` to reject a stale generated file. `prepare.py --prefix another_sprite` gives another bank distinct assembly labels; pass its table to the same runtime routine. No image packages are required.

Pre-shifting moves work to asset preparation and spends memory. The complete phase gallery is static and continues frame waits; it proves pixel placement, clipping and source preservation, not animation cadence or an entire game's frame budget. Runtime shifting, fewer stored phases or specialised hardware can be better choices under different budgets. Execution evidence is in `docs/sprite-phases/verification/`; firmware and snapshots remain local.
