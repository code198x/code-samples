# Service a Logical Attack–Decay–Sustain–Release Envelope on Spectrum

A sound can swell, settle and fade instead of switching between full volume and silence.

## Use it in a project

LEVEL is 0–15; PHASE is 0 off, 1 attack, 2 decay, 3 sustain or 4 release. ATTACK, DECAY and RELEASE are per-service steps 1–15; SUSTAIN is 0–15. A rising GATE restarts from zero. A low gate sends any active phase to release. Return a clamped logical level and VALID=1; invalid parameters or state return VALID=0 without changing envelope state.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **LEVEL, PHASE, PREVIOUS, VALID, GATE, ATTACK, DECAY, SUSTAIN, RELEASE**. They occupy 9 contiguous bytes. Also reserve the private workspace: **T0** (1 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `logical_envelope_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `logical_envelope_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | LEVEL, PHASE and PREVIOUS |
| Supply before service | GATE, ATTACK, DECAY, SUSTAIN and RELEASE |
| Read after service | LEVEL, PHASE and VALID |

Gate edges choose a phase; each phase moves towards its own bound. Clamp before changing phase so a large step cannot wrap below silence or past the peak.

## Machine contract

AF/BC/DE/HL may change; IX/IY are preserved. A direct CALL needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The 48K diagnostic boots through ROM tape loading and USR, disables interrupts and owns the screen. The helper performs no port or screen writes.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Use a fast attack and release the note before the default held sequence finishes. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller clears PREVIOUS each service. A held note continually retriggers its attack and never develops the intended shape. Retain the gate edge state independently of note servicing.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 521 code bytes; public state is 9 bytes and private scratch is 1 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Constant work per service. A hardware envelope can save CPU when its behaviour fits the sound. Software envelopes offer a common control shape but need scheduled updates and machine-specific output mapping.

This is a software control envelope with linear steps per service, not an emulation of a chip’s envelope rates or curves. A backend maps LEVEL to an owned voice or mix gain. Do not overwrite shared hardware volume or a hardware-envelope mode without a deliberate audio ownership policy.

## Execution evidence

Four variants run on 48K PAL ROM tape load and USR, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
