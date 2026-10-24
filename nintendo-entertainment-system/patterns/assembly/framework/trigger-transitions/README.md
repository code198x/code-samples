# Report Trigger Enter, Stay and Exit Events on NES

Standing in a doorway should not count as entering it on every update.

## Use it in a project

CURRENT is an eight-bit overlap snapshot, one bit per trigger. Compare it with retained PREVIOUS: ENTERED is current-only, EXITED is previous-only and STAYED is their intersection. Then retain CURRENT as PREVIOUS. Every bit is handled independently; the helper does not decide overlap geometry.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **ENTERED, STAYED, EXITED, PREVIOUS, CURRENT**. They occupy 5 contiguous bytes. Also reserve the private workspace: **T0** (1 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `trigger_transitions_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `trigger_transitions_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | PREVIOUS |
| Supply before service | CURRENT |
| Read after service | ENTERED, STAYED and EXITED |

An intersection reports shared occupancy, while complement-and-intersection picks the two differences. The stored mask turns static collision answers into temporal events.

## Machine contract

A/X/status may change; Y is preserved. The 2A03 has no decimal arithmetic mode. A direct JSR needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The NROM caller owns PPU setup and background display, with NMI and DMC disabled. Table and packet sizes are bounded to fit the cartridge caller and internal RAM; the helper owns no PPU registers.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Use the high trigger bit and an exit/re-entry sequence. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller clears PREVIOUS each time. Occupied triggers keep re-entering and exit events disappear. Retain the last complete snapshot for this same actor.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 50 code bytes; public state is 5 bytes and private scratch is 1 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Constant work for eight zones in one byte. More triggers can use more mask bytes or a sparse event list; neither removes the need to own the previous state per actor.

Snapshots can miss a fast pass through a narrow zone between updates. Swept geometry or substeps may be needed. Separate actors need separate previous masks; combining their snapshots changes the meaning of an event.

## Execution evidence

Four variants run on NTSC NROM, background only, DMC/NMI disabled, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
