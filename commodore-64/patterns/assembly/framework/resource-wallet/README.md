# Resource Counters on C64

An empty magazine should refuse a shot, not turn into 255 rounds. A full energy meter should stay full when you collect another recharge. This small counter gives those two operations different rules: refill saturates at 255; spending succeeds in full or leaves the balance alone.

## Reuse

Bind these contiguous private bytes in order: BALANCE, AMOUNT, MODE, OK. Include component.inc once; call resource_wallet_init, set the inputs and call resource_wallet_step. The init entry clears every byte, including caller-input fields. Set starting values after init. Both entry points use one fixed binding; use distinct names/scopes and state blocks for independent instances. Do not include conflicting global field labels unchanged.

Set BALANCE to the current unsigned amount, AMOUNT to the requested change and MODE to **0 for refill** or **1 for spend**. Call step, then read OK: 1 means the operation was accepted, 0 means an unaffordable spend or an unknown mode. A zero-amount refill or spend is valid and succeeds. Other MODE values leave BALANCE alone and clear OK. AMOUNT and MODE survive.

BALANCE is persistent resource state; AMOUNT and MODE are caller inputs; OK is replaced on every call.

A/X/flags may change; Y and decimal mode survive. **Clear decimal mode before binary arithmetic**; the standalone caller uses CLD. A direct call pushes a two-byte return address.

Initialise once, then set the starting balance. Try a spend before creating the effect; consume OK immediately. A rejected request leaves all the resource available for a later affordable action. The helper does not spawn a projectile, reserve an object slot or coordinate another writer.

## Limits and alternatives

For a smaller capacity, clamp refills to an explicit capacity instead of 255 and qualify both the new cap and the initial-balance invariant. Multiple resource types need separate state. Transactions involving both ammo and object slots need an explicit reservation/commit policy; OK is not a lock.

Refill and spend take bounded branch paths, with no search or loop. Two output bytes can change. A simple decrement is smaller when running out is impossible, but cannot enforce affordability. Measured helper extent: 51 bytes; named state: 4 bytes, excluding return addresses, code alignment and the diagnostic harness. No whole-game cycle budget is inferred.

## Build and evidence

Run make with ASM198X set to the assembler binary; Amiga also takes BUILD198X. Four maintained variants: demo, custom, deliberately wrong client, exact repair. The custom caller changes the first spend from five units to two. It succeeds from a balance of three; the later refill still saturates and the later unaffordable spend is still rejected. The wrong client labels every request as a refill by replacing MODE with zero. Spending now increases the balance, so an emptying sequence ends at 255. Preserve the requested operation and let the affordability check decide whether to spend.

Observed rows: demo 05 06 01 00 00 00 00 00; custom 05 06 01 00 00 00 00 00; wrong FF 06 00 01 00 00 00 00. Read these as hexadecimal state bytes in the field order above, truncated/padded to eight for display; the packet retains every state byte after every call.

Native configuration: PAL C64 with stock BASIC/KERNAL PRG startup and RUN; Asm198x 0.0.72 and Emu198x 0.44.2. Ninety-six table calls per variant exercise valid boundaries and varied inputs, followed by an independent sequential client. A dirty-state init and preserved-register sentinels are checked. Tables are not exhaustive over all input combinations. configuration.json and results.json retain tool/firmware/source identities, immutable loaded bytes, native packet, helper extent and captures; restricted firmware and snapshots are not committed. Use scripts/verify-gameplay-patterns.py --topic resource-wallet --help to refresh; check-gameplay-patterns.py and test_gameplay_patterns.py validate retained observations and reject mutations. See the independent model in cross-platform/patterns/framework/gameplay-patterns/cases.py.

The standalone PRG takes over screen/font/colour RAM, disables IRQ sources and does not return to BASIC. Its private diagnostic workspace is $70–$89; its packet starts at $C000.
