# Sprite movement with bounds

Move a white 24×21 sprite with joystick **port 2**, keeping its whole shape
inside the normal 40-column, 25-row display. Build within the samples checkout
so the relative includes can reuse the Hardware Sprites setup and shape:

```sh
make
# Load build/demo.prg, type RUN, and use joystick port 2. Reset to leave.
make verify EMU198X_C64=/path/to/emu198x-c64 VICE=/path/to/x64sc
```

The demo takes over the VIC bank, screen, sprites, CIA1 port directions and
CIA interrupt masks. It maps out BASIC/KERNAL and does not return to BASIC.
Both CIA1 ports are inputs, so this example does not scan the keyboard.
It is not a keyboard/joystick sharing routine or an OS-preserving subroutine.

## Contract

`read_joystick2` in `demo.asm` samples $DC00 once and returns pressed direction
bits in A: up=1, down=2, left=4, right=8. `move_sprite` in `movement.inc` takes
that mask, moves two pixels per call and writes sprite 0's VIC coordinates.
It preserves X and Y, changes A and flags, and uses four bytes of state:
`sprite_x_lo`, `sprite_x_hi`, `sprite_y`, `joy_state`.

Initial state must be inside X=24..320 and Y=50..229, inclusive. The high X
byte is 0 or 1. Each axis clamps to its edge; opposite directions cancel on
that axis, and fire/other bits do not move the sprite. Diagonals move two
pixels on each axis and are not normalised. Bits 1–7 of $D010 are preserved;
other sprites' positions, enables, colours and modes are not written.
The caller excludes competing writes to $D010 during its read/modify/write.

The demo polls raster timing and updates once per frame below the displayed
area. Its `frames`, register snapshot and `picture_ready` label are observation
points. Two pixels per frame means faster movement per second on NTSC than
PAL. No regional speed compensation or fixed CPU-cycle bound is claimed.

For inclusive visible edges 24..343 and 50..249, the last fully visible
sprite origin is 343-(24-1)=320 and 249-(21-1)=229. These limits apply to a
normal-size sprite and this display window, not expansion or border tricks.

## Verification

The verifier compares Asm198x and ACME program bytes, then executes on
Emu198x and VICE, each configured as PAL and NTSC:

- The original listing (retained with website revision/hash) reproduces
  Y=51/up staying at 51 and Y=228/down staying at 228. The fixture redirects
  only its joystick reads to a RAM byte; arithmetic and VIC writes are unchanged.
- A matrix combines eight X coordinates around both edges and the 255/256
  transition, six Y coordinates around both edges, and all 32 combinations
  of directions/fire. The host oracle computes clamped signed displacement,
  independently of the assembly's carry/branch implementation. Each case
  checks state, VIC coordinates and preservation of seeded $D010 bits.
- Removing the upper-edge clamp must fail the same matrix observer.
- A sequential port-input run covers held controls, release, both X-byte
  transitions, all edges, diagonals, opposite directions and ignored fire.
  Emu198x receives button events; VICE uses its simulated control-port pins
  (`-controlport2device io`, `jpdb`), not host keyboard joystick emulation.
  Guest frame counts establish update counts. Register state is read before
  releasing the controls for one unchanged frame, allowing the capture API
  to publish that position. Every lit pixel is then checked at fixed native
  capture offsets. No screenshot alignment search is used.

The matrix injects masks into the arithmetic routine; only the separate port
run establishes input wiring. Emu198x loads through BASIC/RUN. VICE boots to
BASIC ready, loads the same PRG through its monitor and enters $0810.
Neither route establishes physical joystick timing or original-hardware results.

`verification/results.json` records source/tool hashes, baseline failures,
corrected matrix results, mutation rejection, live observations and assembled
routine size. Shared includes and the reused PNG reader have their own hashes.
`verification/execution.log` retains the run output. Reruns write full probes,
monitor commands, memory dumps and images under `build/verification/`.

## Sources

Commodore, *Commodore 64 Programmer's Reference Guide* (1983), chapter 3,
pp. 131–144 (sprite size, pointers and positioning) and pp. 343–344
(control ports, direction switches and active-low reads). This demo's
clamping, opposite-direction policy and diagonal speed are software choices.

## Recorded run — 10 October 2026

All 6,144 matrix rows and 48 live captures passed. The old listing and the
clamp-removal mutation were rejected on both engines and both standards.
Tools: Asm198x v0.0.58, ACME 0.97, VICE 3.10, Python 3.14.3, and Emu198x
`df2799e220a10de6a3bc0f14f04c6506363cb7d3`. The retained corner captures were
visually inspected; the remaining captures were checked automatically.
