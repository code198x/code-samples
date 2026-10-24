# Carry a Supported Passenger on NES

A passenger should inherit a moving platform’s displacement without changing the platform’s own position.

## Use it in a project

PASSENGER, PLATFORM_OLD and PLATFORM_NEW are unsigned byte coordinates on one axis. MINIMUM/MAXIMUM bound the passenger’s allowed coordinate. If SUPPORTED is nonzero, add the signed platform displacement and clamp at those limits; otherwise keep PASSENGER. Return POSITION, CLAMPED and VALID. Reversed limits or an already out-of-range passenger return POSITION=PASSENGER and VALID=0.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **POSITION, CLAMPED, VALID, PASSENGER, PLATFORM_OLD, PLATFORM_NEW, SUPPORTED, MINIMUM, MAXIMUM**. They occupy 9 contiguous bytes. Also reserve the private workspace: **T0, T1** (2 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `moving_platform_carry_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `moving_platform_carry_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | none |
| Supply before service | passenger, platform coordinates, support and bounds |
| Read after service | POSITION, CLAMPED and VALID |

Choose the displacement sign by comparing platform coordinates. Check byte carry or borrow before applying world bounds, so arithmetic wrapping cannot put the passenger on the opposite side of the level.

## Machine contract

A/X/status may change; Y is preserved. The 2A03 has no decimal arithmetic mode. A direct JSR needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The NROM caller owns PPU setup and background display, with NMI and DMC disabled. Table and packet sizes are bounded to fit the cartridge caller and internal RAM; the helper owns no PPU registers.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Carry left past the lower world limit and observe the clamp. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller overwrites the old platform coordinate with the new one. Its measured displacement becomes zero and the passenger stays behind. Keep both positions until passenger carry is complete.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 259 code bytes; public state is 9 bytes and private scratch is 2 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Constant work for one axis. A wider fixed-point position preserves subpixel platform motion; this byte version assumes both coordinates share the same unit and do not wrap.

SUPPORTED comes from the caller’s contact test. Carry alone does not resolve walls or crush situations; after moving the platform, apply carry once and resolve the passenger against other geometry. A clamp can break relative alignment, which needs a game policy.

## Execution evidence

Four variants run on NTSC NROM, background only, DMC/NMI disabled, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
