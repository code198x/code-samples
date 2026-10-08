# Sixteen sprites in two bands

Load `demo.prg` on a PAL or NTSC C64 and type `RUN`. Eight solid sprites appear
at Y=64, with eight outlines at Y=176. Each hardware sprite draws once in each
band. The final two upper sprites and first two lower sprites use X>255.

```
make
make verify ASM198X=/path/to/asm198x EMU198X_C64=/path/to/emu198x-c64
```

The verifier also needs ACME and VICE's `x64sc` on PATH, plus the emulators'
normal C64 ROMs. Python uses only its standard library. No ROMs are distributed
here. Some macOS sandboxes prevent the installed VICE process from starting;
run the verification in a normal terminal in that case.

## Contract

`multiplexer.inc` owns the raster IRQ, all eight hardware sprites, their
pointers at $07f8, and their VIC-II registers. Call `mux_init` with interrupts
disabled, RAM vectors selected ($01=$35), VIC-II bank 0 and screen $0400 set.
Then enable interrupts. The demo supplies that setup, disables CIA interrupts,
installs a minimal NMI return and selects ordinary 40-column text. It takes over
the machine; it does not return to BASIC or support cartridge interrupt owners.

- `mux_counts[0]` and `[1]` each accept 0..8. Zero disables that band without
  reading its sprite tables. A count above eight disables the band and sets its
  `mux_errors` byte to one. A subsequent valid count clears the error.
- `mux_xlo`, `mux_xhi` (zero or one), `mux_pointers` and `mux_colours` hold eight
  upper-band entries followed by eight lower-band entries. A sprite pointer
  addresses a 64-byte block inside VIC-II bank 0. Colour values are 1..15 in
  single-colour mode. The demo's two shapes occupy $2000..$207f.
- The two fixed Y values are 64 and 176. Sprites are 24×21, unexpanded and
  single-colour. Do not enable expansion, change Y, change the IRQ lines or
  alter display timing without recalculating the schedule.
- The IRQ saves A, X and Y; RTI restores the interrupted flags. It uses private
  RAM variables and no zero-page workspace. Counts are atomic single-byte
  updates, applied at the next corresponding band IRQ. Tables must remain
  unchanged while the multiplexer runs; simultaneous multi-byte updates need
  their own publication protocol.

This is a fixed two-band multiplexer, not an arbitrary-Y scheduler. It does not
sort moving sprites, resolve more than eight overlapping sprites, handle
expanded sprites or wrap a sprite through the bottom of the frame.

## Schedule and verification

Raster IRQs at 32 and 144 programme the next band before its Y comparison.
The preceding band's final line is 84 or 196, so neither setup overwrites a
sprite still being drawn. Display DMA remains enabled during verification.
For eight sprites, both tested emulators finish the register writes at lines
45 and 158 on PAL and NTSC. That leaves 19 and 18 raster lines respectively;
these are observed deadlines, not a cycle-perfect IRQ guarantee.

`verification/verify.py` checks byte equality with ACME, then inspects **every
non-black screenshot pixel**, sprite shape, position and colour consistency.
It reads the guest's completion lines and count errors. It covers counts
0, 1, 7, 8, 9 and 255, independent empty bands, and an 8→0→8 transition across
125 frames on both emulators and standards. A deliberately removed X-high-bit
write must fail the same picture check. Native capture crops differ; the
verifier names those offsets explicitly and does no alignment search.

Retained results are in `verification/results.json`; reruns write generated
programs, scripts, PNGs and observations under `build/verification/`. This is
configuration-specific emulator evidence, not an original-hardware test.

## Sources

Commodore, *Commodore 64 Programmer's Reference Guide* (1983), chapter 3,
pp. 131–140: eight 24×21 sprites, reuse through raster interrupts, pointers,
position registers and the ninth X bit. Its VIC-II register map describes
$D012, $D019 and $D01A. The complete example's schedule is verified above.
