# A Bounded Event Queue on Spectrum

When three things happen before the game gets around to handling them, one event byte can only remember the last one. A small FIFO keeps their order. This queue has an explicit full result, so a burst cannot silently overwrite an event that still matters.

## Reuse

Bind these contiguous private bytes in order: HEAD, TAIL, COUNT, VALUE, MODE, OK, B0, B1, B2, B3. Include component.inc once; call event_queue_init, set the inputs and call event_queue_step. The init entry clears every byte, including caller-input fields. Set starting values after init. Both entry points use one fixed binding; use distinct names/scopes and state blocks for independent instances. Do not include conflicting global field labels unchanged.

HEAD and TAIL are indices into contiguous B0–B3. COUNT is the number of occupied entries. MODE **1 pushes VALUE**, MODE **2 pops into VALUE**; other modes do nothing. OK is replaced with 1 on success or 0 on rejection. A full push and an empty pop preserve the queue and VALUE. Use only state produced by init/step: indices are below QUEUE_CAP, COUNT is 0–QUEUE_CAP and TAIL equals (HEAD + COUNT) modulo capacity.

Six control/input/output bytes precede four reserved buffer bytes. A queue stores byte event IDs, not payloads or pointers. Popped buffer cells retain stale data; COUNT decides which entries are live. Head equals tail can mean either empty or full, so COUNT must be retained.

AF/BC/DE/HL may change; IX/IY survive. A direct CALL uses two return-address stack bytes.

Initialise once, then offer each event and check OK. If a push fails, choose a game policy: retry, discard a dispensable effect, or stop producing work. Do not pretend the event was queued. Pop until OK becomes zero, with a per-update work budget if producers could keep adding events.

## Limits and alternatives

Larger queues need wider indices or a bounded capacity and updated storage. A power-of-two capacity can use a mask to wrap, but this version uses comparison so its policy is visible. An IRQ producer and foreground consumer need a separately designed single-producer/single-consumer protocol or critical section; this is a single-owner queue.

Each push/pop touches one buffer cell and a few counters, without moving the other entries. This buys constant work at the cost of indices, count and explicit overflow handling. Draining the entire queue is a caller loop and needs its own budget. Measured helper extent: 121 bytes; named state: 10 bytes, excluding return addresses, code alignment and the diagnostic harness. No whole-game cycle budget is inferred.

## Build and evidence

Run make with ASM198X set to the assembler binary; Amiga also takes BUILD198X. Four maintained variants: demo, custom, deliberately wrong client, exact repair. The custom build lowers QUEUE_CAP from four to two while retaining the four-byte storage layout. A third push is rejected, and the two original events still pop in order. This demonstrates a capacity limit rather than a RAM-saving layout change. The wrong client resets HEAD, TAIL and COUNT before every push. The later event replaces the history of earlier submissions. The first pop now returns 51 instead of 17. Initialise at session creation or an intentional flush, not when submitting an event.

Observed rows: demo 03 03 00 33 02 01 11 22; custom 00 00 00 22 02 00 11 22; wrong 01 01 00 33 02 00 33 00. Read these as hexadecimal state bytes in the field order above, truncated/padded to eight for display; the packet retains every state byte after every call.

Native configuration: Spectrum 48K with stock ROM tape loading and USR entry; Asm198x 0.0.72 and Emu198x 0.44.2. Ninety-six table calls per variant exercise valid boundaries and varied inputs, followed by an independent sequential client. A dirty-state init and preserved-register sentinels are checked. Tables are not exhaustive over all input combinations. configuration.json and results.json retain tool/firmware/source identities, immutable loaded bytes, native packet, helper extent and captures; restricted firmware and snapshots are not committed. Use scripts/verify-gameplay-patterns.py --topic event-queue --help to refresh; check-gameplay-patterns.py and test_gameplay_patterns.py validate retained observations and reject mutations. See the independent model in cross-platform/patterns/framework/gameplay-patterns/cases.py.

The standalone tape program starts at $8000, disables interrupts and owns bitmap/attribute RAM. It does not return to BASIC. The helper itself never disables interrupts or touches the display.
