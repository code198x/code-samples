# Debounce a Sampled Input Byte on Amiga

A noisy or bouncing input should settle before it changes the game’s logical state.

## Use it in a project

RAW is a sampled byte. THRESHOLD 1–255 requires that many consecutive identical samples before replacing STABLE. CANDIDATE and RUN are retained private history. CHANGED pulses only when STABLE changes. THRESHOLD=0 disables acceptance and clears RUN. RUN saturates at 255.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **STABLE, CHANGED, CANDIDATE, RUN, RAW, THRESHOLD**. They occupy 6 contiguous bytes. Also reserve the private workspace: **none** (0 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `input_debounce_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `input_debounce_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | STABLE, CANDIDATE and RUN |
| Supply before service | RAW and THRESHOLD |
| Read after service | STABLE and CHANGED |

A new candidate begins a run of one. Repeated samples grow that run until the threshold is reached; only a difference from the accepted stable value emits CHANGED.

## Machine contract

D0–D3/A0–A1/CCR may change; D4–D7/A2–A6 are preserved. A direct BSR/JSR needs four return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The A500 OCS diagnostic cold-boots an OFS disk, owns the Copper and bitplane and disables interrupt/DMA sources. The helper does not take over hardware or allocate Chip RAM.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x` and `BUILD198X=/path/to/build198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Use immediate acceptance at threshold one. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller clears the consecutive-sample count before every service. A threshold above one is never reached. Retain CANDIDATE and RUN between samples.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 212 code bytes; public state is 6 bytes and private scratch is 0 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Constant work per sample. Latency is threshold samples, so the caller’s sampling frequency is part of the interface.

The entire byte must settle together. Independently bouncing buttons need separate instances or per-bit counters. The routine is useful for raw noisy inputs, not a substitute for normal press-edge detection.

## Execution evidence

Four variants run on A500 OCS PAL, Kickstart1.3 OFS cold boot, using Asm198x 0.0.72, Emu198x 0.44.2 and Build198x 0.2.9. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.
