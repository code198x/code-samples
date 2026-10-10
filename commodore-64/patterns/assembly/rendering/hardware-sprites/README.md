# Hardware sprite 0

A complete single-colour sprite example for PAL or NTSC C64: a white 24×21
outline with a central cross at VIC X=160, Y=120 on a black screen.

```sh
make
# Load build/demo.prg in a C64 emulator, then type RUN. Reset to leave.
make verify EMU198X_C64=/path/to/emu198x-c64 VICE=/path/to/x64sc
```

`demo.asm` is the standalone caller; `sprite.inc` contains the reusable
routine; `shape.inc` supplies all 63 shape bytes and one padding byte.
The caller takes over the screen, VIC bank, sprite state and CIA interrupt
masks. It maps out BASIC/KERNAL and does not return to BASIC. This is a
BASIC-loaded program, not a routine that can be called from BASIC safely.

`sprite0_show` takes X's low byte in A, its high bit (0 or 1) in X, and
raster Y (0–255) in Y. It preserves X and Y and clobbers A and flags. It
requires I/O visible, VIC bank 0, screen at $0400 and shape at $2000. It
sets sprite 0 to white, normal size, single-colour and foreground priority,
then enables it. Bits 1–7 of $D010/$D015/$D017/$D01B/$D01C/$D01D are preserved.
The caller must exclude simultaneous writers to these read/modify/write
sequences. Calling during display can show partially updated state; this
example initialises once before its observation loop, not as a raster-safe
movement routine.

## Verification

`verification/verify.py` builds each case with Asm198x and ACME and requires
identical PRGs. It runs five cases on Emu198x and VICE, each on PAL and NTSC:
X=160, 24, 255, 256 and 296. Cases seed other sprites' shared register bits
with $AA or $54, and start sprite 0's mode/high bits set. Blank shapes keep
those other sprites invisible. Guest code snapshots the registers after the
call. The verifier checks those bytes and every lit native screenshot pixel,
including shape, position and white colour. It does not search for an image
alignment. A mutation that omits setting X bit 8 must fail the picture check.

[Results](verification/results.json) and [execution output](verification/execution.log)
record 20 passing captures and the rejected mutation on 10 October 2026.
Source and tool hashes identify the run. The PNG reader is reused from the
adjacent sprite-multiplexing verifier; its hash is retained separately.

Tools: Asm198x v0.0.58, ACME 0.97, VICE 3.10 and Emu198x built from
`df2799e220a10de6a3bc0f14f04c6506363cb7d3` with
`cargo build --release --locked -p emu198x-c64 --no-default-features`.
Emu198x uses its configured C64 ROMs and loads through BASIC/RUN; VICE boots
to BASIC ready, then its monitor loads the same PRG and enters $0810.
The default PAL captures were visually inspected. Other cases use automated
pixel/register checks. This is configuration-specific emulator evidence,
not original-hardware verification or a measurement of DMA cycle cost.

## Hardware sources

Commodore, *Commodore 64 Programmer's Reference Guide* (1983), chapter 3,
pp. 101–104 (VIC banks and screen memory), 131–144 (sprites, pointers,
position, expansion and priority). A pointer is a 64-byte block number
relative to the selected VIC bank. Eight pointers start at screen base+$3F8.
MOS Technology, *6567 Video Interface Chip (VIC-II), Preliminary*, “System
Interface / DMA Operation”: sprite fetches require phase-2 accesses and
can stop the processor. Hardware compositing does not mean zero bus cost.
