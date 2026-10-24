# Menu Key Repeat on NES

A menu should move once when you press Down, pause briefly, then scroll while you hold it. Reading the held button every update is too fast; reading only new presses never repeats. This helper adds the delay and repeat cadence between those two choices.

## Reuse

Bind these contiguous private bytes in order: HELD, WAS_HELD, TIMER, PULSE. Include component.inc once; call input_repeat_init, set the inputs and call input_repeat_step. The init entry clears every byte, including caller-input fields. Set starting values after init. Both entry points use one fixed binding; use distinct names/scopes and state blocks for independent instances. Do not include conflicting global field labels unchanged.

Supply HELD as any nonzero value for a held control, zero for release. Step replaces PULSE, normalises WAS_HELD, and retains TIMER. The first held call pulses immediately and loads REPEAT_DELAY. Later held calls decrement a positive timer; reaching zero pulses and reloads REPEAT_RATE. Release clears the history and timer. Both configured delays must be 1–255 simulation updates.

HELD is an input. WAS_HELD and TIMER are persistent private history. PULSE is a one-call output. The helper reads no keyboard or controller and assumes a regular service cadence.

A/X/flags may change; Y and decimal mode survive. **Clear decimal mode before binary arithmetic**; the standalone caller uses CLD. A direct call pushes a two-byte return address.

Initialise once when the menu gains control. Feed a held level every update, then consume PULSE immediately. Use a separate block for each independently repeating direction. Resolve opposite directions before service, according to your menu policy.

## Limits and alternatives

A faster held-scroll stage can shorten the repeat interval after a threshold, but needs another counter and a clear acceleration policy. A real-time repeat service can use elapsed ticks instead; this version deliberately counts service calls and freezes when they stop.

One constant-size state machine runs per control per update. No busy wait or input scan occurs here. Very short intervals feel fast only if the menu is actually serviced at the intended rate. Measured helper extent: 52 bytes; named state: 4 bytes, excluding return addresses, code alignment and the diagnostic harness. No whole-game cycle budget is inferred.

## Build and evidence

Run make with ASM198X set to the assembler binary; Amiga also takes BUILD198X. Four maintained variants: demo, custom, deliberately wrong client, exact repair. The custom build changes the first delay from four to six updates and the repeat interval from two to three. The immediate press still pulses at index zero. The eight held calls now pulse at indices 0 and 6 rather than 0, 4 and 6. The wrong client clears WAS_HELD and TIMER before every held sample. Every update looks like a fresh press, so all eight updates pulse. Retain repeat history between calls; reset it only on intentional focus/session changes.

Observed rows: demo 01 01 01 00 00 00 00 00; custom 01 01 02 00 00 00 00 00; wrong 01 01 04 01 00 00 00 00. Read these as hexadecimal state bytes in the field order above, truncated/padded to eight for display; the packet retains every state byte after every call.

Native configuration: NTSC NES with a mapper-0 cartridge, CHR-ROM diagnostic font, NMI and DMC disabled; Asm198x 0.0.72 and Emu198x 0.44.2. Ninety-six table calls per variant exercise valid boundaries and varied inputs, followed by an independent sequential client. A dirty-state init and preserved-register sentinels are checked. Tables are not exhaustive over all input combinations. configuration.json and results.json retain tool/firmware/source identities, immutable loaded bytes, native packet, helper extent and captures; restricted firmware and snapshots are not committed. Use scripts/verify-gameplay-patterns.py --topic input-repeat --help to refresh; check-gameplay-patterns.py and test_gameplay_patterns.py validate retained observations and reject mutations. See the independent model in cross-platform/patterns/framework/gameplay-patterns/cases.py.

The standalone cartridge owns its background, CHR font and RAM layout. Its diagnostic packet is bounded below the end of the NES’s 2 KiB internal RAM; the component owns no PPU or audio registers.
