# Buffer Turns Through a Grid on Spectrum

A maze feels kinder when a turn pressed just before a junction happens as soon as the route opens.

## Use it in a project

CELL indexes a 4×4 row-major map; zero cells are walkable and nonzero cells block. Directions are 0 still, 1 left, 2 right, 3 up, 4 down. A nonzero REQUEST replaces PENDING. Try that turn first; if blocked, retain it and try the current DIRECTION. A successful turn clears PENDING. Each call moves at most one cell. Invalid indices/directions or a blocked current cell return VALID=0 without changing movement state.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **CELL, DIRECTION, PENDING, MOVED, VALID, REQUEST, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15**. They occupy 22 contiguous bytes. Also reserve the private workspace: **T0, T1, T2, T3, T4** (5 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `grid_turn_buffer_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `grid_turn_buffer_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | CELL, DIRECTION and PENDING; map bytes |
| Supply before service | REQUEST |
| Read after service | CELL, DIRECTION, PENDING, MOVED and VALID |

Try at most two neighbouring cells: the buffered request and the existing direction. Check column boundaries before adding or subtracting one so movement cannot wrap into the next row.

## Machine contract

AF/BC/DE/HL may change; IX/IY are preserved. A direct CALL needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The 48K diagnostic boots through ROM tape loading and USR, disables interrupts and owns the screen. The helper performs no port or screen writes.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Queue a blocked upward turn at the top edge, then replace it with a downward request. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller clears the queued turn between cells. The player continues along the row instead of turning upwards when the next junction opens. Retain PENDING until a turn succeeds or a new request replaces it.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 493 code bytes; public state is 22 bytes and private scratch is 5 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

At most two map reads after validation. A larger map needs a wider index and declared dimensions; a pixel mover needs centre-line snapping and collision checks between cell boundaries.

This is logical cell movement, not pixel interpolation or a complete maze controller. Call only at a cell-step boundary; animate between those positions separately. The map is read-only during service.

## Execution evidence

Four variants run on 48K PAL ROM tape load and USR, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 45 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
