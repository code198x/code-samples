# Validate a Save Before Replacing Live State on C64

A damaged save should leave the current game alone rather than half-replacing it with invalid state.

## Use it in a project

C0..C7 are exactly eight already-read bytes: tag198, version1, payload length4, room0..15, horizontal position0..31, lives0..9, flags0..15, then XOR of the first seven bytes. MODE=0 validates without committing; MODE=1 validates then copies all four payload bytes to L0..L3. VALID means the mode is recognised; ACCEPTED means the entire record passes. A rejected record leaves all live fields unchanged. Physical file length must be verified as exactly eight before supplying this buffer.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **ACCEPTED, VALID, MODE, L0, L1, L2, L3, C0, C1, C2, C3, C4, C5, C6, C7**. They occupy 15 contiguous bytes. Also reserve the private workspace: **T0, T1, T2** (3 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `save_record_validation_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `save_record_validation_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | L0..L3 live state |
| Supply before service | MODE and immutable C0..C7 |
| Read after service | ACCEPTED, VALID and optionally L0..L3 |

Check the complete envelope, semantic ranges and integrity before the first live-state write. A separate validation mode allows a load screen to inspect compatibility without changing the running game.

## Machine contract

A/X/status may change; Y and decimal mode are preserved. Use CLD for binary arithmetic. A direct JSR needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The diagnostic PRG owns screen, font and colour RAM and disables interrupts; it does not return to BASIC. The reusable helper does none of those things.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Validate a different legal record without commitment, then commit the same record on a second call. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong client drops the stored checksum before validation. The otherwise valid record is rejected and live state stays intact. Supply all eight bytes, including the stored integrity byte.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 283 code bytes; public state is 15 bytes and private scratch is 3 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Seven XOR stages and four writes only after acceptance. A bigger record needs a bounded length and wider index; use the existing CRC helper when stronger error detection justifies its additional work.

XOR is intentionally small and weak: two cancelling changes can pass. The existing streaming CRC-8 gives stronger accidental-corruption detection, but neither authenticates a hostile file. Atomic disk replacement, I/O failure, migration and concurrent game-state writers are outside this in-memory transaction. Add semantic checks whenever the payload gains new rules.

## Execution evidence

Four variants run on PAL stock-ROM PRG, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
