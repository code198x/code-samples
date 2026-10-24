# Detect a Button Chord Once on NES

Holding two buttons together should trigger one action, not one action every frame.

## Use it in a project

REQUIRED is a nonempty mask; FORBIDDEN must not overlap it. All required bits must be held and every forbidden bit clear. ACTIVE reports that condition and PRESSED reports its rising edge against PREVIOUS. Invalid configuration clears result flags and PREVIOUS, preventing a stale active latch.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **PREVIOUS, HELD, REQUIRED, FORBIDDEN, ACTIVE, PRESSED, VALID**. They occupy 7 contiguous bytes. Also reserve the private workspace: **T0** (1 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `input_chord_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `input_chord_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | PREVIOUS |
| Supply before service | HELD, REQUIRED and FORBIDDEN |
| Read after service | ACTIVE, PRESSED and VALID |

First compute whether the chord is active as a whole. Then compare that condition with the previous snapshot. This lets the player press the required buttons one after another and still create one chord edge.

## Machine contract

A/X/status may change; Y is preserved. The 2A03 has no decimal arithmetic mode. A direct JSR needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. Scope or rename routine and field labels and allocate a separate block for each independent instance. Give each block one mutation owner.

The NROM caller owns PPU setup and background display, with NMI and DMC disabled. Table and packet sizes are bounded to fit the cartridge caller and internal RAM; the helper owns no PPU registers.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Require buttons 1 and 4 rather than buttons 1 and 2. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller clears PREVIOUS before every snapshot. A held chord becomes a new press every time. Retain the previous chord condition, rather than the previous single-key press pulse.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 166 code bytes; public state is 7 bytes and private scratch is 1 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Constant work using byte masks. More than eight buttons needs more bytes and a definition of how snapshots are collected consistently.

A chord uses a held snapshot; do not AND together separate per-button press pulses. Sequentially pressed buttons can form the chord. Strict simultaneity needs an explicit timing window.

## Execution evidence

Four variants run on NTSC NROM, background only, DMC/NMI disabled, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
