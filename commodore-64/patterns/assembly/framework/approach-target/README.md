# Approach a Target Without Overshoot on C64

An enemy can move towards a waypoint without orbiting it forever. Move by the smaller of the remaining distance and your allowed step, then report arrival. That last short step matters when the target is not an exact multiple of the speed.

## Reuse

Bind these contiguous private bytes in order: POSITION, TARGET, STEP, ARRIVED. Include component.inc once; call approach_target_init, set the inputs and call approach_target_step. The init entry clears every byte, including caller-input fields. Set starting values after init. Both entry points use one fixed binding; use distinct names/scopes and state blocks for independent instances. Do not include conflicting global field labels unchanged.

POSITION, TARGET and STEP are unsigned bytes. Step moves POSITION towards TARGET by at most STEP, without wrapping or overshooting, and replaces ARRIVED with 1 exactly when the resulting position equals TARGET. STEP zero stops movement but still reports an already reached target. TARGET and STEP survive.

POSITION persists. TARGET and STEP are inputs. ARRIVED describes the resulting position and stays true on repeated calls at the target; it is not a one-time arrival event. Detect its edge if an action should occur only once.

A/X/flags may change; Y and decimal mode survive. **Clear decimal mode before binary arithmetic**; the standalone caller uses CLD. A direct call pushes a two-byte return address.

Initialise, then set the position, target and allowed step. Call once per simulation update. Change TARGET to follow a moving goal, or choose the next waypoint only after ARRIVED. Use another state block for the second axis if independent axis movement is the intended policy.

## Limits and alternatives

Signed coordinates, wider worlds and fixed-point subpixels need wider arithmetic and explicit bounds. Moving both axes by the same maximum gives faster diagonal travel in Euclidean distance; normalisation or an axis budget is a separate movement policy. Collision may still block a proposed position.

One comparison chooses direction, then a distance comparison chooses a full or short step. No multiplication, division or path search occurs. This is straight-axis pursuit, not obstacle-aware navigation. Measured helper extent: 66 bytes; named state: 4 bytes, excluding return addresses, code alignment and the diagnostic harness. No whole-game cycle budget is inferred.

## Build and evidence

Run make with ASM198X set to the assembler binary; Amiga also takes BUILD198X. Four maintained variants: demo, custom, deliberately wrong client, exact repair. The custom caller reduces STEP from ten to two. Starting at 250 with target 255, the two calls end at 254 without arrival; a later call would take the last one-unit step. The wrong client replaces the helper with an unconditional byte addition. Starting at 250, adding ten wraps to 4, then 14, moving away from target 255. Compare the remaining distance before adding or subtracting; increasing the target tolerance does not fix byte overflow.

Observed rows: demo FF FF 0A 01 00 00 00 00; custom FE FF 02 00 00 00 00 00; wrong 0E FF 0A 00 00 00 00 00. Read these as hexadecimal state bytes in the field order above, truncated/padded to eight for display; the packet retains every state byte after every call.

Native configuration: PAL C64 with stock BASIC/KERNAL PRG startup and RUN; Asm198x 0.0.72 and Emu198x 0.44.2. Ninety-six table calls per variant exercise valid boundaries and varied inputs, followed by an independent sequential client. A dirty-state init and preserved-register sentinels are checked. Tables are not exhaustive over all input combinations. configuration.json and results.json retain tool/firmware/source identities, immutable loaded bytes, native packet, helper extent and captures; restricted firmware and snapshots are not committed. Use scripts/verify-gameplay-patterns.py --topic approach-target --help to refresh; check-gameplay-patterns.py and test_gameplay_patterns.py validate retained observations and reject mutations. See the independent model in cross-platform/patterns/framework/gameplay-patterns/cases.py.

The standalone PRG takes over screen/font/colour RAM, disables IRQ sources and does not return to BASIC. Its private diagnostic workspace is $70–$89; its packet starts at $C000.
