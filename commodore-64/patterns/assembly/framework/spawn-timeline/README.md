# Service a Small Spawn Timeline on C64

A wave can have deliberate pauses without burying every spawn in the main loop.

## Use it in a project

COUNT is 1–4 and INDEX must be below it. E0–E3 are event IDs and L0–L3 are delay ticks before each event. WAIT is retained elapsed delay. Each call with WAIT below the current delay increments it without firing; otherwise emit that event, reset WAIT and advance INDEX. At the final event DONE latches. At most one event fires per call, even when delays are zero.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **EVENT, FIRED, INDEX, WAIT, COUNT, DONE, VALID, E0, E1, E2, E3, L0, L1, L2, L3**. They occupy 15 contiguous bytes. Also reserve the private workspace: **T0** (1 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `spawn_timeline_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `spawn_timeline_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | INDEX, WAIT and DONE |
| Supply before service | COUNT, E0–E3 and L0–L3 |
| Read after service | EVENT, FIRED and VALID |

A cursor selects the event and its delay. Emitting at most one event bounds per-update work and makes zero-delay entries consecutive updates rather than an unbounded burst.

## Machine contract

A/X/status may change; Y and decimal mode are preserved. Use CLD for binary arithmetic. A direct JSR needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The diagnostic PRG owns screen, font and colour RAM and disables interrupts; it does not return to BASIC. The reusable helper does none of those things.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Use two different events and move the opening delay. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller rewinds INDEX each update, so the first event keeps firing and the rest of the wave never arrives. Retain the cursor and waiting state until a deliberate timeline restart.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 194 code bytes; public state is 15 bytes and private scratch is 1 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Constant work per tick with four caller-owned event/delay pairs. A larger asset-backed timeline needs bounds checks on its record count and a policy for reading data.

Events are requests: the caller owns actual spawning, pool capacity and what to do when an event cannot be accepted. This helper advances after emission, so a reliable deferred-spawn policy must retain or queue rejected work explicitly.

## Execution evidence

Four variants run on PAL stock-ROM PRG, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
