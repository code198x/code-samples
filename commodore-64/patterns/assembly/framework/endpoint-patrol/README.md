# Patrol Between Two Endpoints on C64

A guard walks to the end of a corridor, turns and comes back. The turn should happen at the endpoint, not after a step through the wall. This routine keeps that small behaviour separate from sprite drawing and collision.

## Reuse

Bind these contiguous private bytes in order: POSITION, LOWER, UPPER, DIRECTION. Include component.inc once; call endpoint_patrol_init, set the inputs and call endpoint_patrol_step. The init entry clears every byte, including caller-input fields. Set starting values after init. Both entry points use one fixed binding; use distinct names/scopes and state blocks for independent instances. Do not include conflicting global field labels unchanged.

Use unsigned byte LOWER, UPPER and POSITION with **LOWER ≤ POSITION ≤ UPPER**. DIRECTION zero means increasing, nonzero means decreasing. Step turns inward at either endpoint, takes one unit step, and normalises DIRECTION to 0 or 1. A one-point interval stays there with direction zero. There is no dwell or duplicated endpoint call.

POSITION and DIRECTION persist. LOWER and UPPER are caller-owned bounds. Altering the bounds requires moving the position into the new interval before the next call; this component does not repair arbitrary corrupt state.

A/X/flags may change; Y and decimal mode survive. **Clear decimal mode before binary arithmetic**; the standalone caller uses CLD. A direct call pushes a two-byte return address.

Initialise, then supply valid bounds and a starting position before the first step. Service the helper at your chosen movement cadence. A countdown can make a guard step less often; this helper itself does not own a clock. Pause simply omits service.

## Limits and alternatives

A multi-point route needs a waypoint index and route data. Variable-speed reflection must decide how to use leftover distance after hitting an endpoint; this one-unit routine cannot be made faster by replacing its increment with an unchecked larger addition.

There are a few byte comparisons and one increment/decrement per service, with no route scan or rendering. Keeping movement cadence outside allows several guards to share a clock without sharing their positions. Measured helper extent: 52 bytes; named state: 4 bytes, excluding return addresses, code alignment and the diagnostic harness. No whole-game cycle budget is inferred.

## Build and evidence

Run make with ASM198X set to the assembler binary; Amiga also takes BUILD198X. Four maintained variants: demo, custom, deliberately wrong client, exact repair. The custom caller extends the upper endpoint from four to six. The same initial position now moves forward before turning. The lower bound remains zero and the movement amount remains one. The wrong client steps first and only reverses after leaving the interval. Starting at the upper endpoint four, it visibly records position five before turning back. Turn before taking the next step. The wrong trace is a separate naive implementation; the valid boundary table still exercises the maintained helper.

Observed rows: demo 02 00 04 00 00 00 00 00; custom 02 00 06 01 00 00 00 00; wrong 00 00 04 01 00 00 00 00. Read these as hexadecimal state bytes in the field order above, truncated/padded to eight for display; the packet retains every state byte after every call.

Native configuration: PAL C64 with stock BASIC/KERNAL PRG startup and RUN; Asm198x 0.0.72 and Emu198x 0.44.2. Ninety-six table calls per variant exercise valid boundaries and varied inputs, followed by an independent sequential client. A dirty-state init and preserved-register sentinels are checked. Tables are not exhaustive over all input combinations. configuration.json and results.json retain tool/firmware/source identities, immutable loaded bytes, native packet, helper extent and captures; restricted firmware and snapshots are not committed. Use scripts/verify-gameplay-patterns.py --topic endpoint-patrol --help to refresh; check-gameplay-patterns.py and test_gameplay_patterns.py validate retained observations and reject mutations. See the independent model in cross-platform/patterns/framework/gameplay-patterns/cases.py.

The standalone PRG takes over screen/font/colour RAM, disables IRQ sources and does not return to BASIC. Its private diagnostic workspace is $70–$89; its packet starts at $C000.
