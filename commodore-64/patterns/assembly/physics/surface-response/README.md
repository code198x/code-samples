# Reflect a Surface-normal Speed with Restitution on C64

A bounce can lose speed along a wall’s normal while keeping its sideways motion.

## Use it in a project

NORMAL_IN is an unsigned incoming speed magnitude. DIRECTION_IN is 0 or 1 for its sign along the chosen axis. RESTITUTION is 0–4 quarters. Return NORMAL_OUT=floor(NORMAL_IN*RESTITUTION/4), reverse the direction, and copy the encoded tangent byte unchanged. Invalid direction/restitution returns zero outputs and VALID=0. The caller supplies a surface-aligned basis and establishes a genuine incoming contact.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **NORMAL_OUT, DIRECTION_OUT, TANGENT_OUT, VALID, NORMAL_IN, DIRECTION_IN, TANGENT_IN, RESTITUTION**. They occupy 8 contiguous bytes. Also reserve the private workspace: **T0, T1, T2, T3** (4 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `surface_response_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `surface_response_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | none |
| Supply before service | incoming normal magnitude/direction, tangent encoding and restitution |
| Read after service | NORMAL_OUT, DIRECTION_OUT, TANGENT_OUT and VALID |

Split speed into quotient and remainder on division by four. Multiply those small parts by at most four before combining them, retaining the full result without overflowing a byte product.

## Machine contract

A/X/status may change; Y and decimal mode are preserved. Use CLD for binary arithmetic. A direct JSR needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The diagnostic PRG owns screen, font and colour RAM and disables interrupts; it does not return to BASIC. The reusable helper does none of those things.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Use a perfectly elastic bounce at the largest byte speed. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller forces perfectly elastic restitution. A speed of eleven returns eleven instead of eight, so the intended energy loss disappears. Preserve the material’s chosen coefficient.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 163 code bytes; public state is 8 bytes and private scratch is 4 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

At most four accumulation stages. The 68000 can use word multiplication and a shift; the explicit byte decomposition makes the small-machine representation visible. Repeated bounces lose an extra fraction through integer rounding.

The coefficient is a speed ratio, not an energy ratio. This is an axis/surface-basis response, not arbitrary-angle collision detection, friction, penetration resolution or mass exchange. For zero normal speed, the returned direction bit is immaterial.

## Execution evidence

Four variants run on PAL stock-ROM PRG, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
