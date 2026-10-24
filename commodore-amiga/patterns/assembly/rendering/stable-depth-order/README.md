# Sort a Small Draw Order Stably on Amiga

When two sprites have the same depth, their order should not flicker from frame to frame.

## Use it in a project

COUNT 0–8 selects a prefix of eight depth bytes. Return indices I0–I7, initialised to identity, with the active prefix sorted by ascending Z. Insertion sort moves only strictly greater depths, preserving original index order for ties. Depth inputs remain unchanged. Invalid COUNT leaves order bytes unchanged and returns VALID=0.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **COUNT, VALID, Z0, Z1, Z2, Z3, Z4, Z5, Z6, Z7, I0, I1, I2, I3, I4, I5, I6, I7**. They occupy 18 contiguous bytes. Also reserve the private workspace: **T0, T1, T2, T3, T4, T5, T6, EXPR_SAVE** (8 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `stable_depth_order_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `stable_depth_order_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | none between complete sorts |
| Supply before service | COUNT and Z0–Z7 |
| Read after service | I0–I7 and VALID |

Insertion sort keeps a sorted prefix and inserts the next index into it. Equal depths never move past each other. Sorting indices also keeps the actual object records in place.

## Machine contract

D0–D3/A0–A1/CCR may change; D4–D7/A2–A6 are preserved. A direct BSR/JSR needs four return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. Scope or rename routine and field labels and allocate a separate block for each independent instance. Give each block one mutation owner.

The A500 OCS diagnostic cold-boots an OFS disk, owns the Copper and bitplane and disables interrupt/DMA sources. The helper does not take over hardware or allocate Chip RAM.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x` and `BUILD198X=/path/to/build198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Reverse the depth values while preserving stable ties. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller passes COUNT=0 for a populated scene. The identity order remains instead of the requested depth order. Pass the actual active prefix, not the capacity or an uninitialised object count.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 500 code bytes; public state is 18 bytes and private scratch is 8 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Worst-case comparisons grow quadratically: eight reverse-ordered objects require 28. Nearly sorted lists need fewer moves. Measure before choosing it for many objects.

At eight objects insertion sort has a bounded 28 comparisons in the reverse-order case. This returns an order; it does not overcome hardware sprite limits or move attributes. Larger scenes need a measured choice of bucket sorting, partial ordering or another algorithm.

## Execution evidence

Four variants run on A500 OCS PAL, Kickstart1.3 OFS cold boot, using Asm198x 0.0.72, Emu198x 0.44.2 and Build198x 0.2.9. Each executes 55 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
