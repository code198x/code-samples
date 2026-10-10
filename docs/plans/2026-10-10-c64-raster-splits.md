# Execute Raster Splits and qualify its timing

Scope: retain the existing two-interrupt, KERNAL-vector approach, provide
a complete caller, and establish where its colour writes become visible.
No new dependencies, architecture or emulator changes. The current page
claims an immediate colour change, a few cycles and about 70 bytes without
an executable record. CPU interrupt entry, the KERNAL prologue and VIC DMA
all occur before the write; these costs must be observed and explained.

1. Preserve the original main listing and provenance in
   `commodore-64/patterns/assembly/rendering/raster-splits/verification/`.
   Assemble it in a caller and capture PAL/NTSC output in Emu198x and VICE.
   Identify the actual transition rows before changing the teaching claims.
2. Maintain `split.inc`, `demo.asm`, `Makefile` and `README.md` in that folder.
   Keep KERNAL ROM mapped, select a known text display, disable and acknowledge
   CIA sources, and document exclusive IRQ ownership and reset-to-exit.
   Cover ordinary and badline compare values, frame progress, foreground
   register preservation and visible colours. Compare Asm198x/ACME bytes.
   A missing colour write must fail the same picture observer.
3. Record source/tool hashes and observed transition ranges, distinguishing
   raster compare, delayed colour write and horizontal stability. Replace
   unsupported cost claims with assembled size and measured conditions.
4. Update `raster-splits.mdx` through CodeFromFile, pin the execution record,
   build the website and check desktop/mobile rendering and evidence hashes.
   Commit and merge both bounded changes after local and CI checks pass.

Starting samples revision: `301cb16b1ee2df7f5d6d383ae22dd45bf9807966`.
Starting website revision: `1c67ce0af62ae3151a4639f0ac931e2679b5d245`.

## Outcome

The original two-region algorithm works. Its timing claims were unsupported:
with compare 130 the first visible blue row is raster 131; compare 131 gives
a partial blue row 132 and a full row 133. PAL/NTSC and both engines agree
on these row ranges. The retained setup/handler occupies 81 assembled bytes.
The new caller leaves CLI until after setup and checks foreground A/X/Y.

All 12 baseline and 48 maintained captures pass, and all 12 missing-colour
mutations fail the same observer. Asm198x and ACME agree for every fixture.
Ruff and the standalone make build pass. No emulator change was needed.

Two observer corrections were made before recording final results: native
frame stepping was replaced with guest-PC synchronisation, and vertical
coordinates now use hardware raster origins rather than sprite Y origins
(which include the sprite's one-line start delay). The fixed capture origins
were checked against the renderer code and VICE's documented crop constants.
