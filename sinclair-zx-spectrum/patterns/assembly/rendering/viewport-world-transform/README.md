# Project World Points into a Viewport on Spectrum

A world can be larger than the screen even when the drawing routine expects byte-sized screen coordinates.

## Use it in a project

World and camera positions are unsigned little-endian words. WIDTH/HEIGHT are 1–255 logical units. A point is visible only when world−camera is nonnegative on each axis and strictly below the corresponding extent. Return byte SCREEN_X/Y and VISIBLE=1; hidden points return zero coordinates. Zero extents return VALID=0. Preserve inputs.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **SCREEN_X, SCREEN_Y, VISIBLE, VALID, WORLD_X_LO, WORLD_X_HI, WORLD_Y_LO, WORLD_Y_HI, CAMERA_X_LO, CAMERA_X_HI, CAMERA_Y_LO, CAMERA_Y_HI, WIDTH, HEIGHT**. They occupy 14 contiguous bytes. Also reserve the private workspace: **T0, T1, T2, T3** (4 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `viewport_world_transform_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `viewport_world_transform_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | none |
| Supply before service | world/camera words and WIDTH/HEIGHT |
| Read after service | SCREEN_X/Y, VISIBLE and VALID |

First reject negative differences with full-word comparisons. Subtract each low byte and borrow into its high byte, then accept only a zero high difference and a low difference inside the viewport.

## Machine contract

AF/BC/DE/HL may change; IX/IY are preserved. A direct CALL needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The 48K diagnostic boots through ROM tape loading and USR, disables interrupts and owns the screen. The helper performs no port or screen writes.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Project a point near the maximum word coordinate into a two-unit viewport. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller drops the world X high byte. A point just beyond 255 appears behind the camera instead of eleven units to its right. Preserve both bytes through the coordinate transform.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 424 code bytes; public state is 14 bytes and private scratch is 4 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Constant work with no division. Subtracting in the world representation before narrowing avoids byte wrap; fixed-point world coordinates additionally need an explicit fractional-bit conversion.

This projects points, not partly visible sprites or rectangles. Extents are at most 255, so a 256-unit viewport needs a wider extent representation. Camera coordinates do not wrap and the routine does not write display registers.

## Execution evidence

Four variants run on 48K PAL ROM tape load and USR, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
