# Filter Collision Pairs by Layer on C64

A projectile can cross its owner without hitting them, while still hitting an opponent in the same patch of screen.

## Use it in a project

GROUP_A/B are eight-bit membership sets; MASK_A/B say which groups each object accepts. Both directions must accept the pair. Return PAIR_KIND=0 when either rejects it, 1 for an accepted sensor pair, or 2 when both accepted objects have nonzero SOLID flags. Preserve all inputs. This classifies policy; a separate spatial test must establish actual contact.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **PAIR_KIND, GROUP_A, MASK_A, GROUP_B, MASK_B, SOLID_A, SOLID_B**. They occupy 7 contiguous bytes. Also reserve the private workspace: **T0** (1 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `collision_layer_filter_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `collision_layer_filter_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | none |
| Supply before service | GROUP_A/B, MASK_A/B and SOLID_A/B |
| Read after service | PAIR_KIND |

Intersect each object’s membership with the other’s acceptance mask. Requiring both intersections avoids one-sided friendly-fire rules. Solidity is considered only after acceptance.

## Machine contract

A/X/status may change; Y and decimal mode are preserved. Use CLD for binary arithmetic. A direct JSR needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The diagnostic PRG owns screen, font and colour RAM and disables interrupts; it does not return to BASIC. The reusable helper does none of those things.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Make an accepted pair a sensor by clearing one solidity flag. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller accepts every group for A. A pair excluded by MASK_A=2 becomes a solid candidate. Preserve the intended mask; overlapping objects do not automatically have permission to interact.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 106 code bytes; public state is 7 bytes and private scratch is 1 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Two set intersections and bounded branches. Filter inexpensive policy before expensive shape tests; for a large object set, still use a broad phase to reduce candidate pairs.

A zero group or mask disables the relevant acceptance. This is neither collision detection nor damage response, and the eight group bits are a game-owned convention rather than hardware sprite-collision bits.

## Execution evidence

Four variants run on PAL stock-ROM PRG, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
