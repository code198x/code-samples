# Test Sight Along a Grid Row or Column on Amiga

A sentry looking down a corridor must stop at the first wall.

## Use it in a project

On a 4×4 row-major grid, FROM and TO must be 0–15 and share a row or column. Zero grid bytes are transparent; nonzero bytes block. Exclude the observer cell and include the destination. A cell sees itself. Non-cardinal or out-of-range requests return VALID=0 and VISIBLE=0.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **FROM, TO, VISIBLE, VALID, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15**. They occupy 20 contiguous bytes. Also reserve the private workspace: **T0, T1, T2** (3 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `cardinal_sight_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `cardinal_sight_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | none inside the helper |
| Supply before service | FROM, TO and C0–C15 |
| Read after service | VISIBLE and VALID |

A shared row has stride one; a shared column has stride four. Walk from the cell after the observer to the destination, stopping at a blocker. Validating alignment prevents a row walk from wrapping into the next row.

## Machine contract

D0–D3/A0–A1/CCR may change; D4–D7/A2–A6 are preserved. A direct BSR/JSR needs four return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. Scope or rename routine and field labels and allocate a separate block for each independent instance. Give each block one mutation owner.

The A500 OCS diagnostic cold-boots an OFS disk, owns the Copper and bitplane and disables interrupt/DMA sources. The helper does not take over hardware or allocate Chip RAM.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x` and `BUILD198X=/path/to/build198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Look down the first column, with a blocker at cell eight. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller clears C2 before querying sight. A real blocker disappears and the observer sees through it. Keep the query read-only with respect to the collision grid.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 502 code bytes; public state is 20 bytes and private scratch is 3 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

At most three destination-inclusive probes on a valid 4×4 cardinal query. General line traversal needs more arithmetic and an explicit corner policy.

This is explicitly cardinal sight, not a raycaster or arbitrary-angle field of view. Use a grid line traversal for diagonal rays and choose corner visibility deliberately. A renderer does not establish whether game logic should see through a tile.

## Execution evidence

Four variants run on A500 OCS PAL, Kickstart1.3 OFS cold boot, using Asm198x 0.0.72, Emu198x 0.44.2 and Build198x 0.2.9. Each executes 50 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
