# Reveal Counted Text Over Time on NES

A line of dialogue can appear a character at a time, with a button to show the rest immediately.

## Use it in a project

LENGTH is 0–255 bytes. REVEALED must not exceed it. INTERVAL must be nonzero and TICKS below it. Each service consumes one tick; on expiry reveal one byte. Nonzero SKIP reveals the whole counted string immediately and clears TICKS. DONE reflects REVEALED==LENGTH and ADDED reports new bytes this service. Completion is stable while the same LENGTH is retained. Invalid state clears transient outputs and leaves REVEALED/TICKS unchanged.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **REVEALED, TICKS, DONE, ADDED, VALID, LENGTH, INTERVAL, SKIP**. They occupy 8 contiguous bytes. Also reserve the private workspace: **none** (0 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `typewriter_text_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `typewriter_text_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | REVEALED and TICKS |
| Supply before service | LENGTH, INTERVAL and SKIP |
| Read after service | REVEALED, TICKS, DONE, ADDED and VALID |

The timer changes the exposed prefix length, while the renderer owns how that prefix looks. DONE is derived from the prefix length so a completed line stays complete without another animation state.

## Machine contract

A/X/status may change; Y is preserved. The 2A03 has no decimal arithmetic mode. A direct JSR needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The NROM caller owns PPU setup and background display, with NMI and DMC disabled. Table and packet sizes are bounded to fit the cartridge caller and internal RAM; the helper owns no PPU registers.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Reveal one byte per service and observe that further calls after completion add nothing. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong client clears the interval counter every service. With interval two the line never reveals its first character. Retain TICKS and reset only at the intended message boundary.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 187 code bytes; public state is 8 bytes and private scratch is 0 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Constant work per tick; skip changes a count rather than looping over every byte. Drawing an entire prefix on each call can still be expensive. Connect a byte span or dirty-text renderer according to the machine.

Counts refer to bytes in a caller-owned stable string, not UTF-8 characters, markup tokens or proportional glyphs. Keep layout separate and draw the newly exposed span; control codes need a token-aware variant. Changing LENGTH is not a reset protocol: initialise a new message deliberately.

## Execution evidence

Four variants run on NTSC NROM, background only, DMC/NMI disabled, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
