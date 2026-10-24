# Compact a Live Object Prefix on C64

A particle update can walk a dense live prefix instead of checking holes forever.

## Use it in a project

COUNT 0–8 selects paired flag/ID arrays F0–F7 and I0–I7. Keep nonzero-flag items in original order at the start, update COUNT, return REMOVED and clear the vacated portion of the original prefix. Entries beyond the original COUNT are untouched. Invalid COUNT returns VALID=0 and REMOVED=0 without changing arrays or count.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **COUNT, REMOVED, VALID, F0, F1, F2, F3, F4, F5, F6, F7, I0, I1, I2, I3, I4, I5, I6, I7**. They occupy 19 contiguous bytes. Also reserve the private workspace: **T0, T1, T2, T3, T4, EXPR_SAVE** (6 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `stable_compaction_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `stable_compaction_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | COUNT and the owned array prefix |
| Supply before service | F0–F7 and I0–I7 before compaction |
| Read after service | COUNT, REMOVED and VALID |

A read cursor scans the old prefix while a write cursor advances only for retained items. The write cursor never overtakes the read cursor, making in-place stable filtering safe.

## Machine contract

A/X/status may change; Y and decimal mode are preserved. Use CLD for binary arithmetic. A direct JSR needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The diagnostic PRG owns screen, font and colour RAM and disables interrupts; it does not return to BASIC. The reusable helper does none of those things.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Compact a shorter prefix with a different live/dead arrangement. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller uses capacity eight as the live count. A flagged item beyond the owned live prefix is pulled into the compacted set. Pass the actual live count, and preserve the meaning of unused capacity.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 225 code bytes; public state is 19 bytes and private scratch is 6 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

At most eight visits and eight paired moves, plus clearing vacated entries. A sparse fixed-slot pool avoids relocation but makes consumers scan or maintain a separate active list.

Compaction changes storage indices. External index references, sorted draw lists and parallel arrays must be updated or replaced with stable IDs/handles. Do not silently compact a pool whose public contract promises stable slot indices.

## Execution evidence

Four variants run on PAL stock-ROM PRG, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 52 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
