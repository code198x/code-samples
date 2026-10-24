# Choose an Eight-way Direction on Spectrum

A character can face a target in eight directions without angles, trigonometry or a lookup table.

## Use it in a project

Return DIRECTION=0 when points coincide, otherwise 1 north, 2 north-east, 3 east, 4 south-east, 5 south, 6 south-west, 7 west, 8 north-west. Screen Y increases downwards. Choose a cardinal direction when its absolute displacement is at least twice the other; remaining vectors are diagonal. DX/DY return unsigned magnitudes.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **DIRECTION, DX, DY, FROM_X, FROM_Y, TO_X, TO_Y**. They occupy 7 contiguous bytes. Also reserve the private workspace: **T0, T1, T2** (3 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `eight_way_direction_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `eight_way_direction_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | none |
| Supply before service | FROM_X/Y and TO_X/Y |
| Read after service | DIRECTION and DX/DY |

Compare a magnitude with half the other to avoid overflow from doubling a byte. Two sign flags select the quadrant after choosing horizontal, vertical or diagonal.

## Machine contract

AF/BC/DE/HL may change; IX/IY are preserved. A direct CALL needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The 48K diagnostic boots through ROM tape loading and USR, disables interrupts and owns the screen. The helper performs no port or screen writes.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Face a target north-west of the origin. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller flattens the target’s vertical coordinate. DY becomes zero instead of three in the normal client; a steeper vector can also acquire the wrong facing. Preserve both coordinates.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 350 code bytes; public state is 7 bytes and private scratch is 3 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Constant work with no table. A finer angular quantiser can use a ratio table; continuous steering needs a different representation.

These sectors use a 2:1 slope threshold, not exact 22.5-degree boundaries. This selects facing; it does not normalise movement speed.

## Execution evidence

Four variants run on 48K PAL ROM tape load and USR, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
