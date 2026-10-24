# Choose the Highest-priority Request on Amiga

A pickup chime, a warning and an explosion may all request attention in one update. Before touching a sound channel or message panel, choose which request should win. This arbiter retains the first request at the highest priority.

## Reuse

Bind these contiguous private bytes in order: PRESENT, ID, PRIORITY, REQUEST_ID, REQUEST_PRIORITY, ACCEPTED. Include component.inc once; call priority_arbiter_init, set the inputs and call priority_arbiter_step. The init entry clears every byte, including caller-input fields. Set starting values after init. Both entry points use one fixed binding; use distinct names/scopes and state blocks for independent instances. Do not include conflicting global field labels unchanged.

PRESENT says whether a request has already been selected. ID and PRIORITY hold that selection. Offer REQUEST_ID and REQUEST_PRIORITY, then step. It accepts when no selection exists or the new unsigned priority is strictly greater; equal priority retains the first request. ACCEPTED is replaced on every offer. ID zero and priority zero are valid because PRESENT carries emptiness separately.

The first three bytes retain the current selection; two request bytes are inputs; ACCEPTED reports whether this offer replaced the selection. Rejection leaves the selection untouched.



D0–D3/A0–A1/CCR may change; D4–D7/A2–A6 survive. A direct BSR/JSR uses four return-address stack bytes. The program is a 68000 implementation with no division instruction requirement.

Initialise once at the start of each arbitration round, then offer all candidates. After the offers, inspect PRESENT and dispatch ID once. Keep playback duration, channel preemption and any running effect state outside this component. Starting a new round is different from restarting a sound.

## Limits and alternatives

A rotating tie-breaker can improve fairness but changes the stable first-wins contract. Multiple hardware voices may need one arbiter per eligible channel plus ownership and preemption rules. This logical selection does not assert that an effect played or that a device accepted it.

Each offer compares one priority and may copy an ID/priority pair. A round over N requests costs N offers. There is no allocation, queue or hardware access; keeping the current winner is cheaper than sorting all candidates when only one result is needed. Measured helper extent: 96 bytes; named state: 6 bytes, excluding return addresses, code alignment and the diagnostic harness. No whole-game cycle budget is inferred.

## Build and evidence

Run make with ASM198X set to the assembler binary; Amiga also takes BUILD198X. Four maintained variants: demo, custom, deliberately wrong client, exact repair. The custom caller lowers the first request priority from eight to one. The second request, ID 9 at priority eight, now wins. In the default trace it ties and ID 7 remains selected. The wrong client clears PRESENT before every offer. Every request appears to be the first, so the final low-priority ID 5 replaces the earlier priority-eight choice. Clear once before the set of offers, then retain the winner until dispatch.

Observed rows: demo 01 07 08 05 02 00 00 00; custom 01 09 08 05 02 00 00 00; wrong 01 05 02 05 02 01 00 00. Read these as hexadecimal state bytes in the field order above, truncated/padded to eight for display; the packet retains every state byte after every call.

Native configuration: A500 OCS PAL with Kickstart 1.3 and an OFS boot disk; Asm198x 0.0.72 and Emu198x 0.44.2, with Build198x 0.2.9 for disk mastering. Ninety-six table calls per variant exercise valid boundaries and varied inputs, followed by an independent sequential client. A dirty-state init and preserved-register sentinels are checked. Tables are not exhaustive over all input combinations. configuration.json and results.json retain tool/firmware/source identities, immutable loaded bytes, native packet, helper extent and captures; restricted firmware and snapshots are not committed. Use scripts/verify-gameplay-patterns.py --topic priority-arbiter --help to refresh; check-gameplay-patterns.py and test_gameplay_patterns.py validate retained observations and reject mutations. See the independent model in cross-platform/patterns/framework/gameplay-patterns/cases.py.

The standalone boot program takes over Copper/bitplane/interrupt/DMA resources, explicitly disarms all eight sprites, and does not restore Workbench. Those are diagnostic presentation choices; the helper itself owns no chipset registers.
