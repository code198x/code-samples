# Reject Stale Object Handles on C64

A reused pool slot should not let an old reference suddenly name a different enemy.

## Use it in a project

Four slots use ACTIVE bits 0–3 and one generation byte each. MODE=0 allocates the lowest free slot and increments its generation modulo 256. MODE=1 frees a live SLOT with matching GENERATION; MODE=2 queries that handle. RESULT=1 returns OUT_SLOT/OUT_GENERATION; failure returns 255/0. ACTIVE above 15, unknown mode or out-of-range handle index returns VALID=0; ordinary full/stale requests are valid failures.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **RESULT, OUT_SLOT, OUT_GENERATION, VALID, MODE, SLOT, GENERATION, ACTIVE, G0, G1, G2, G3**. They occupy 12 contiguous bytes. Also reserve the private workspace: **T0, T1, T2, EXPR_SAVE** (4 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `generation_handles_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `generation_handles_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | ACTIVE and G0–G3 |
| Supply before service | MODE, SLOT and GENERATION |
| Read after service | RESULT, OUT_SLOT, OUT_GENERATION and VALID |

An index says where storage is; a generation says which lifetime occupies it. Releasing clears the live bit, while allocating advances the lifetime before returning a new reference.

## Machine contract

A/X/status may change; Y and decimal mode are preserved. Use CLD for binary arithmetic. A direct JSR needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The diagnostic PRG owns screen, font and colour RAM and disables interrupts; it does not return to BASIC. The reusable helper does none of those things.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Exercise a generation-byte wrap from 255 to zero. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller throws away the generation part of each reference. Free/query requests fail or eventually identify the wrong lifetime. Store and pass both parts of the returned handle.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 342 code bytes; public state is 12 bytes and private scratch is 4 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Allocation scans at most four slots; validated query/free uses at most three mask shifts. Stable indices avoid moving object records, at the cost of live flags and generation storage.

A byte generation eventually wraps: a sufficiently old handle can alias after 256 allocations of that slot. Wider generations reduce that risk but do not create eternal uniqueness. This validates identity, not object type, ownership or thread safety.

## Execution evidence

Four variants run on PAL stock-ROM PRG, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
