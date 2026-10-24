# Sweep an Interval Along One Axis on Spectrum

A fast object can cross a wall between frames even when neither endpoint overlaps it.

## Use it in a project

Move an interval [OLD_POSITION,OLD_POSITION+SIZE) towards TARGET against [WALL_START,WALL_END). SIZE must be nonzero; both proposed endpoints plus SIZE must fit in a byte, the wall must be nonempty, and the old interval must not overlap it. Return POSITION clamped to first contact and HIT=1 when motion reaches or crosses that face. Invalid requests leave POSITION=OLD_POSITION and VALID=0.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **POSITION, HIT, VALID, OLD_POSITION, TARGET, SIZE, WALL_START, WALL_END**. They occupy 8 contiguous bytes. Also reserve the private workspace: **T0, T1** (2 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `swept_axis_collision_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `swept_axis_collision_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | none |
| Supply before service | OLD_POSITION, TARGET, SIZE and wall edges |
| Read after service | POSITION, HIT and VALID |

When moving right, test the path of the right edge against the wall’s left face. Moving left tests the object’s left edge against the wall’s right face. This avoids sampling intermediate pixels.

## Machine contract

AF/BC/DE/HL may change; IX/IY are preserved. A direct CALL needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The 48K diagnostic boots through ROM tape loading and USR, disables interrupts and owns the screen. The helper performs no port or screen writes.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Sweep leftwards towards the opposite wall face. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller passes the old position as the target. Nothing moves, so no sweep can detect contact. Keep the requested endpoint distinct from the current position.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 356 code bytes; public state is 8 bytes and private scratch is 2 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Constant work for one wall. More obstacles require a broad phase and nearest-contact selection; subdividing movement is simpler but costs more as speed increases.

This is one axis and one static obstacle, with no initial penetration. A full 2D swept solver needs the earliest contact across candidates and a policy for the remaining movement.

## Execution evidence

Four variants run on 48K PAL ROM tape load and USR, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
