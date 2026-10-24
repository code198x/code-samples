# Read and Update Packed Four-bit Cells on Spectrum

Sixteen tile values do not need sixteen whole bytes when each value fits in four bits.

## Use it in a project

Sixteen cells occupy eight caller-owned bytes: an even cell uses the high nibble and the following odd cell the low nibble. CELL must be 0–15. WRITE=0 reads; nonzero writes NEW_VALUE 0–15 and returns that value. Invalid requests return VALUE=0 and VALID=0 without changing packed bytes. An unused NEW_VALUE is ignored on reads.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **VALUE, VALID, CELL, WRITE, NEW_VALUE, B0, B1, B2, B3, B4, B5, B6, B7**. They occupy 13 contiguous bytes. Also reserve the private workspace: **T0, T1, T2, T3, EXPR_SAVE** (5 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `packed_nibble_map_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `packed_nibble_map_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | B0–B7 |
| Supply before service | CELL, WRITE and NEW_VALUE |
| Read after service | VALUE and VALID |

Shift the cell index once to select its byte, then use the low index bit to select a nibble. A write masks only the chosen half and preserves its neighbour.

## Machine contract

AF/BC/DE/HL may change; IX/IY are preserved. A direct CALL needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The 48K diagnostic boots through ROM tape loading and USR, disables interrupts and owns the screen. The helper performs no port or screen writes.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Write and read the final low nibble. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller passes cell zero instead of the requested cell. Reads look plausible and writes succeed, but the wrong map location changes. Keep the logical cell index separate from its packed-byte offset.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 282 code bytes; public state is 13 bytes and private scratch is 5 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Constant work, with masks and shifts in place of direct byte indexing. Byte-per-cell maps are easier to edit and can hold more values; packing pays when memory is tighter than update time.

This halves storage only when values fit 0–15. Packed writes are read-modify-write operations; an interrupt must not update the same byte concurrently without an ownership policy. Rendering and collision properties remain separate.

## Execution evidence

Four variants run on 48K PAL ROM tape load and USR, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
