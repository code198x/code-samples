# A Saturating 16-bit Score on Spectrum

A coin worth 300 points should still be worth 300 when the low byte fills up. This binary score uses two bytes and keeps the carry between them. It also makes the top of the range deliberate: the score stops at its cap instead of wrapping back to zero.

## Reuse

Bind these contiguous private bytes in order: SCORE_LO, SCORE_HI, ADD_LO, ADD_HI, CLIPPED. Include component.inc once; call score_counter_init, set the inputs and call score_counter_step. The init entry clears every byte, including caller-input fields. Set starting values after init. Both entry points use one fixed binding; use distinct names/scopes and state blocks for independent instances. Do not include conflicting global field labels unchanged.

SCORE_LO and SCORE_HI hold an unsigned little-endian score; ADD_LO and ADD_HI hold an unsigned award. The current score must be **0 through SCORE_CAP**. Step adds the award with a wide intermediate, clamps to SCORE_CAP and sets CLIPPED to 1 only when the sum exceeds the cap. An exact hit on the cap leaves CLIPPED zero. The award bytes survive.

The two SCORE bytes persist; the two ADD bytes are inputs; CLIPPED is a replaced overflow/cap pulse. Byte order is explicit on every CPU, including the big-endian 68000.

AF/BC/DE/HL may change; IX/IY survive. A direct CALL uses two return-address stack bytes. This score helper also saves HL with PUSH/POP during the cap comparison: allow two more temporary stack bytes, four bytes in total for the helper call excluding its caller and interrupts.

Initialise at the start of a new session. Set both award bytes before each call; an award of 300 is low byte 44, high byte 1. Keep the score in binary for arithmetic and format a separate display copy. Call once for each scoring event, not once per overlapping frame unless that is the scoring rule.

## Limits and alternatives

A BCD score can simplify decimal display on some CPUs, but the NES CPU does not implement decimal arithmetic. Wider binary counters or milestone rewards need their own carry, cap and event policies. Saturation deliberately loses later awards; games that need lifetime totals should choose a wider representation.

The addition and cap comparison use bounded paths. On 6502 the carry joins two byte additions; the Z80 uses a word addition and carry; the 68000 forms a long intermediate. Rendering and decimal conversion are separate costs. Measured helper extent: 55 bytes; named state: 5 bytes, excluding return addresses, code alignment and the diagnostic harness. No whole-game cycle budget is inferred.

## Build and evidence

Run make with ASM198X set to the assembler binary; Amiga also takes BUILD198X. Four maintained variants: demo, custom, deliberately wrong client, exact repair. The custom build sets SCORE_CAP to 999 instead of 65,535. It uses the same two-byte representation and enforces the smaller cap. The native case table keeps every starting score inside the chosen cap. The wrong client clears ADD_HI before awarding points. A 300-point award becomes 44; a 65,535-point award becomes 255. Supply both bytes together. Merely changing a display width cannot restore points that the arithmetic never received.

Observed rows: demo FF FF FF FF 01 00 00 00; custom E7 03 FF FF 01 00 00 00; wrong 25 02 FF 00 00 00 00 00. Read these as hexadecimal state bytes in the field order above, truncated/padded to eight for display; the packet retains every state byte after every call.

Native configuration: Spectrum 48K with stock ROM tape loading and USR entry; Asm198x 0.0.72 and Emu198x 0.44.2. Ninety-six table calls per variant exercise valid boundaries and varied inputs, followed by an independent sequential client. A dirty-state init and preserved-register sentinels are checked. Tables are not exhaustive over all input combinations. configuration.json and results.json retain tool/firmware/source identities, immutable loaded bytes, native packet, helper extent and captures; restricted firmware and snapshots are not committed. Use scripts/verify-gameplay-patterns.py --topic score-counter --help to refresh; check-gameplay-patterns.py and test_gameplay_patterns.py validate retained observations and reject mutations. See the independent model in cross-platform/patterns/framework/gameplay-patterns/cases.py.

The standalone tape program starts at $8000, disables interrupts and owns bitmap/attribute RAM. It does not return to BASIC. The helper itself never disables interrupts or touches the display.
