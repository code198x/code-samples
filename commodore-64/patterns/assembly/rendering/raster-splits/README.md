# Raster Splits

A complete C64 program with a black upper background and a blue lower
background. Build with `make`, load `build/demo.prg`, then type `RUN`.
Reset to leave. Asm198x is the default assembler; the verifier also requires
ACME, Python 3 and the native Emu198x C64 and VICE `x64sc` executables.

`split.inc` retains the original pattern's KERNAL-vector approach. Call
`split_init` with IRQs masked, KERNAL and I/O visible, CIA2 sources disabled,
and a normal text display selected. It changes A and flags, preserves X/Y,
installs the vector at `$0314`, disables CIA1 sources and enables only the
VIC raster IRQ. The caller enables CPU interrupts after setup. The handler
uses the KERNAL entry's saved registers and exits through `$EA81`.

This caller owns the screen at `$0400`, VIC bank 0, sprite enable, video
mode, colours, IRQ vector and CIA interrupt masks. KERNAL ROM remains mapped
with `$01=$37`, but the normal keyboard scan and software clock service
are no longer called. There is no BASIC return or RESTORE-key interface.
Do not issue BRK, replace the IRQ vector, enable another interrupt source,
or mask IRQs across the scheduled split. The foreground loop checks A/X/Y
survival and counts frames; it is not a game framework.

## Compare time and write time

Writing `$D012` sets the low eight bits of the compare value. Reading it
returns the current raster line. Bit 7 of `$D011` has the same read/write
distinction for bit 8. Both scheduled lines here are below 256.

The interrupt request is followed by CPU interrupt entry, the KERNAL
prologue and our handler instructions. Display DMA can add further delay.
The default compare is 130; in the tested caller the first blue displayed
line is **131** on both PAL and NTSC in both engines. With compare 131,
which is a badline in this display mode, line **132** is partly blue and
line **133** is fully blue. Raster lines use the hardware raster counter,
not sprite Y coordinates or screenshot row numbers.

These observations are specific to this caller and its configuration. The
routine does not stabilise the horizontal write cycle. Moving it, changing
the foreground instruction stream, enabling sprites or changing the display
mode can change timing. It is a useful two-region demonstration, not a
cycle-stable status-panel or scrolling implementation.

The assembled setup and handler occupy **81 bytes**, excluding the caller
and ROM routines. The caller has two diagnostic bytes. No universal cycle
bound is claimed. Resetting the background near line 0 hides that change
above the normal display window; it does not make the lower split immediate.

## Verification

```sh
make verify EMU198X_C64=/path/to/emu198x-c64 VICE=/path/to/x64sc
```

`verification/verify.py` reuses the movement example's execution helpers
and the multiplexer example's dependency-free PNG reader. Keep the samples
checkout's directory structure. Each built program must have identical
Asm198x and ACME output.

The record in `verification/results.json` contains:

- Twelve captures of the original listing in the same caller. They show
  that the colour change is delayed even though the two-region output works.
- Forty-eight maintained-example captures: compare lines 64, 130, 131 and
  200, both engines, PAL and NTSC, three separated frames per configuration.
- Foreground frame progress and A/X/Y preservation checks. Emu198x is
  synchronised to completed guest instructions; VICE uses conditional breakpoints.
  Emu198x then runs normally for two frames to emit a fresh screenshot.
- Every blue pixel checked: no colour outside the lower display window,
  no holes, one blue colour, and transition rows matching the reference
  fixture. Per-column transition runs retain the partial-line boundary.
- A PAL/NTSC capture control patches blue to black while running. Debug-only
  screenshots must reproduce the stale blue frame; normal running must emit
  black, and restoring the write must bring blue back.
- Twelve negative captures where the blue write is deliberately replaced
  with black. The same picture observer must reject each one.

The native capture origins are fixed from the renderers: Emu198x starts
at raster 0; normal VICE PAL and NTSC crops start at 16 and 28 respectively.
No image alignment search is performed. Pictures establish the displayed
result, not the precise CPU bus cycle of the register write. The sampled
frames do not establish the full jitter range under arbitrary foreground
loads. Original-hardware verification remains separate.

Primary source: Commodore Semiconductor Group, *6567 Video Interface Chip
Specification Sheet*, drawing 318014, sheets 11 (raster and IRQ registers)
and 15 (system interface and DMA). Also Commodore, *Commodore 64
Programmer's Reference Guide* (1983), pp. 150–152 (raster/IRQ registers).

Recorded tools: Asm198x 0.0.58, ACME 0.97, Emu198x revision
`df2799e220a10de6a3bc0f14f04c6506363cb7d3` and VICE 3.10. The tested
models are PAL 6569 and NTSC 6567R8, with the normal C64 ROM environment.
Tool executable hashes are included in the record.
