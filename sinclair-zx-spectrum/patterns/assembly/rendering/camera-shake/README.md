# Keep Camera Shake out of World State on Spectrum

An impact can shake the view without moving the player, the level or the collision geometry.

## Use it in a project

TRIGGER reloads AMPLITUDE from STRENGTH 0–15 and REMAINING from DURATION. While a lifetime tick remains, map each caller-supplied noise byte into −AMPLITUDE..+AMPLITUDE, return two’s-complement OFFSET_X/Y, then decrement REMAINING. Expired shake returns zero offsets. Invalid STRENGTH clears only outputs/VALID and leaves retained lifetime/amplitude unchanged. Existing AMPLITUDE must also be 0–15 when not retriggering.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **OFFSET_X, OFFSET_Y, REMAINING, AMPLITUDE, VALID, TRIGGER, STRENGTH, DURATION, NOISE_X, NOISE_Y**. They occupy 10 contiguous bytes. Also reserve the private workspace: **T0, T1** (2 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `camera_shake_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `camera_shake_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | REMAINING and AMPLITUDE |
| Supply before service | TRIGGER, STRENGTH, DURATION and NOISE_X/Y |
| Read after service | OFFSET_X/Y and VALID |

Separate the lifetime from the world camera. Reduce noise into a bounded span, centre it around zero and leave authoritative world state untouched.

## Machine contract

AF/BC/DE/HL may change; IX/IY are preserved. A direct CALL needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The 48K diagnostic boots through ROM tape loading and USR, disables interrupts and owns the screen. The helper performs no port or screen writes.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Use the largest supported amplitude for a single-tick impulse. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller clears the lifetime on every tick. The trigger produces one offset, then shake disappears even though its configured duration has not elapsed. Retain REMAINING and apply offsets only to rendering coordinates.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 292 code bytes; public state is 10 bytes and private scratch is 2 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Modulo by subtraction takes at most 85 iterations per nonzero-amplitude axis. A lookup table or masked power-of-two distribution is faster with different storage or visual distribution. No frame budget is claimed.

The helper does not generate random values, write a camera position or fade amplitude. Noise reduction is biased when the span does not divide 256; that is an explicit visual choice, not an unbiased random-selection routine. Supply a separate visual noise stream if gameplay randomness must remain unchanged.

## Execution evidence

Four variants run on 48K PAL ROM tape load and USR, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
