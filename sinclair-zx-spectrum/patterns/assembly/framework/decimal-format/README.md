# Format a 16-bit Decimal Number on Spectrum

A binary score is good for adding points. People would rather read 12345 than its two storage bytes. This formatter turns any unsigned 16-bit value into five decimal characters, ready for a text routine to place or translate into tile numbers.

## Reuse

Bind these contiguous private bytes in order: VALUE_LO, VALUE_HI, DIGIT0, DIGIT1, DIGIT2, DIGIT3, DIGIT4, WORK_LO, WORK_HI. Include component.inc once; call decimal_format_init, set the inputs and call decimal_format_step. The init entry clears every byte, including caller-input fields. Set starting values after init. Both entry points use one fixed binding; use distinct names/scopes and state blocks for independent instances. Do not include conflicting global field labels unchanged.

VALUE_LO/VALUE_HI contain an unsigned little-endian integer 0–65,535 and survive the call. Step writes exactly five ASCII bytes DIGIT0–DIGIT4 with leading zeroes, no terminator, and finishes with WORK_LO/WORK_HI zero. The work bytes belong to the helper, not to a second caller running concurrently.

Two input bytes, five output characters and two scratch bytes. For example 65,535 produces ASCII bytes 36 35 35 33 35 in hexadecimal. Read DIGIT0–DIGIT4 as a counted five-byte span; there is no trailing zero to scan for.

On this Z80 the live remainder stays in HL; WORK_LO/WORK_HI only receive the final zero. They are retained in this example’s nine-byte binding, not required by the CPU arithmetic. A smaller target-specific variant can remove those two fields and their init/final stores, but that changes the binding and needs fresh records; it is not a measured seven-byte version here.

AF/BC/DE/HL may change; IX/IY survive. A direct CALL uses two return-address stack bytes.

Bind all nine contiguous bytes, set the two value bytes and call step. Render the five output bytes afterwards. ASCII is a logical output contract: the C64 demo uses a prepared hex font and NES normally needs tile-number mapping, so these five bytes do not automatically become screen characters on either machine.

## Limits and alternatives

Packed BCD can trade conversion work for more expensive score updates, and lookup tables trade ROM space for conversion speed. A divide-based implementation suits some CPUs better. Signs, decimal points and values beyond 65,535 need a different contract and output width.

Five digit stages subtract 10,000, 1,000, 100, 10 and 1. Each stage needs at most nine successful subtractions, so 45 is a safe upper bound for successful subtractions, plus five terminating comparisons. There is no hardware division or screen write. Convert when the displayed value changes rather than every frame if that saves useful work. Measured helper extent: 126 bytes; named state: 9 bytes, excluding return addresses, code alignment and the diagnostic harness. No whole-game cycle budget is inferred.

## Build and evidence

Run make with ASM198X set to the assembler binary; Amiga also takes BUILD198X. Four maintained variants: demo, custom, deliberately wrong client, exact repair. The custom caller formats 4,096 instead of 65,535, producing 04096. To hide leading zeroes, choose a presentation policy after formatting while keeping at least the final zero for a value of zero. The wrong client clears VALUE_HI before formatting. The number 65,535 becomes 255, displayed as 00255. Copy both bytes from the score or counter; a correct formatter cannot recover a lost high byte.

Observed rows: demo FF FF 36 35 35 33 35 00; custom 00 10 30 34 30 39 36 00; wrong FF 00 30 30 32 35 35 00. Read these as hexadecimal state bytes in the field order above, truncated/padded to eight for display; the packet retains every state byte after every call.

Native configuration: Spectrum 48K with stock ROM tape loading and USR entry; Asm198x 0.0.72 and Emu198x 0.44.2. Ninety-six table calls per variant exercise valid boundaries and varied inputs, followed by an independent sequential client. A dirty-state init and preserved-register sentinels are checked. Tables are not exhaustive over all input combinations. configuration.json and results.json retain tool/firmware/source identities, immutable loaded bytes, native packet, helper extent and captures; restricted firmware and snapshots are not committed. Use scripts/verify-gameplay-patterns.py --topic decimal-format --help to refresh; check-gameplay-patterns.py and test_gameplay_patterns.py validate retained observations and reject mutations. See the independent model in cross-platform/patterns/framework/gameplay-patterns/cases.py.

The standalone tape program starts at $8000, disables interrupts and owns bitmap/attribute RAM. It does not return to BASIC. The helper itself never disables interrupts or touches the display.
