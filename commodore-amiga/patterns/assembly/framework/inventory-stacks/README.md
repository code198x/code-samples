# Add and Remove Inventory Stacks on Amiga

Picking up a stack should either fit completely or leave the inventory as it was.

## Use it in a project

Four count slots each have caller-selected CAP 1–255. SLOT must be 0–3 and its current count at most CAP. REMOVE=0 adds, nonzero subtracts. AMOUNT=0 succeeds without a change. SUCCESS reports the complete transaction; insufficient capacity or stock is a valid but unsuccessful request. Invalid slot, cap or current count rejects before indexing or writing.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **SLOT, AMOUNT, REMOVE, CAP, SUCCESS, VALID, C0, C1, C2, C3**. They occupy 10 contiguous bytes. Also reserve the private workspace: **T0, T1, EXPR_SAVE** (3 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `inventory_stacks_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `inventory_stacks_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | C0–C3 |
| Supply before service | SLOT, AMOUNT, REMOVE and CAP |
| Read after service | SUCCESS and VALID |

Check the room left before adding, or the stock available before subtracting. These comparisons avoid using wrapped byte arithmetic as an overflow test.

## Machine contract

D0–D3/A0–A1/CCR may change; D4–D7/A2–A6 are preserved. A direct BSR/JSR needs four return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. Scope or rename routine and field labels and allocate a separate block for each independent instance. Give each block one mutation owner.

The A500 OCS diagnostic cold-boots an OFS disk, owns the Copper and bitplane and disables interrupt/DMA sources. The helper does not take over hardware or allocate Chip RAM.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x` and `BUILD198X=/path/to/build198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Use a stack cap of seven rather than nine. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller labels a pickup as REMOVE. The helper correctly refuses missing stock or subtracts from an existing stack. Keep the meaning of the request separate from whether a button was pressed.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 334 code bytes; public state is 10 bytes and private scratch is 3 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Constant work for a known slot. Finding a matching item or distributing a stack needs a bounded search and a separate transaction policy.

Slots represent item kinds, not objects with metadata. This neither finds a free slot nor automatically spreads a pickup across stacks. Those policies can be layered over a read-only capacity check or a multi-slot transaction.

## Execution evidence

Four variants run on A500 OCS PAL, Kickstart1.3 OFS cold boot, using Asm198x 0.0.72, Emu198x 0.44.2 and Build198x 0.2.9. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
