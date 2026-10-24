# Allocate Slots with a Bitset on C64

Eight occupied flags can fit in one byte when objects already live in fixed slots.

## Use it in a project

USED is an eight-bit occupied mask. MODE=0 allocates the lowest free slot; MODE=1 releases REQUEST 0–7. Return RESULT=1 only for a successful allocation or release, SLOT for that slot, otherwise SLOT=255. Invalid mode or release index returns VALID=0 without changing USED.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **SLOT, RESULT, VALID, USED, MODE, REQUEST**. They occupy 6 contiguous bytes. Also reserve the private workspace: **T0, T1, T2** (3 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `bitset_slot_allocation_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `bitset_slot_allocation_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | USED |
| Supply before service | MODE and REQUEST |
| Read after service | SLOT, RESULT, VALID and updated USED |

Walk a one-bit mask from the lowest slot upwards. Release clears one occupied bit; freeing an already free slot reports no change.

## Machine contract

A/X/status may change; Y and decimal mode are preserved. Use CLD for binary arithmetic. A direct JSR needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The diagnostic PRG owns screen, font and colour RAM and disables interrupts; it does not return to BASIC. The reusable helper does none of those things.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Start with only slot zero free, then test full allocation and release. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller clears occupancy before service and can allocate the same live slot twice. Initialise once; retain USED until the object is actually released.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 245 code bytes; public state is 6 bytes and private scratch is 3 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

At most eight mask tests and one persistent byte. A free-list scales better for a much larger pool.

This stores occupancy only. Generation handles are still needed to detect stale references after slot reuse.

## Execution evidence

Four variants run on PAL stock-ROM PRG, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
