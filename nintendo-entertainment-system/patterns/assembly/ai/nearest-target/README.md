# Select the Nearest Active Target on NES

An enemy or homing projectile needs a target-selection rule that stays predictable when candidates tie.

## Use it in a project

ACTIVE uses its low four bits for four candidates. Select the smallest Manhattan distance from unsigned byte ORIGIN_X/Y, breaking ties by lowest slot. Return a little-endian distance 0–510 and FOUND=1; no active targets returns SLOT=255, distance zero and FOUND=0. High ACTIVE bits are ignored.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **SLOT, DISTANCE_LO, DISTANCE_HI, FOUND, ACTIVE, ORIGIN_X, ORIGIN_Y, PX0, PX1, PX2, PX3, PY0, PY1, PY2, PY3**. They occupy 15 contiguous bytes. Also reserve the private workspace: **T0, T1, T2, T3, T4, T5, T6, T7** (8 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `nearest_target_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `nearest_target_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | none |
| Supply before service | ACTIVE, origin and candidate coordinates |
| Read after service | SLOT, DISTANCE_LO/HI and FOUND |

Compute two absolute coordinate differences and add them with a ninth bit. Replace the best candidate only for a strictly smaller distance, preserving the earlier slot on ties.

## Machine contract

A/X/status may change; Y is preserved. The 2A03 has no decimal arithmetic mode. A direct JSR needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The NROM caller owns PPU setup and background display, with NMI and DMC disabled. Table and packet sizes are bounded to fit the cartridge caller and internal RAM; the helper owns no PPU registers.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Select near the far corner of the coordinate range. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller only marks slot zero active, excluding a nearer candidate. Pass the actual occupancy mask and check FOUND before using SLOT.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 329 code bytes; public state is 15 bytes and private scratch is 8 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Four candidates, no multiplication or square root. Squared Euclidean distance changes the selection and needs a wider sum.

Manhattan distance favours an axis-aligned metric, not circular Euclidean distance. It ignores walls and reachability.

## Execution evidence

Four variants run on NTSC NROM, background only, DMC/NMI disabled, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
