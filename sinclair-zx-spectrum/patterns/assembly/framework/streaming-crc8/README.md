# A Streaming CRC-8 on Spectrum

A saved score or a small asset can pick up an accidental changed byte. A streaming checksum gives the loader something to compare before using the data, without needing to hold a second copy of the whole message.

## Bind, initialise and call

Allocate the contiguous private bytes CRC, DATA in that order. Include component.inc once, call streaming_crc8_init, then set the starting inputs/state. Init clears every named byte, including inputs. Call streaming_crc8_step for each intended service. Use one owner; independent instances need distinct state and scoped/renamed labels. No helper owns a clock, input reader, display, allocation or interrupt controller.

CRC is the retained eight-bit remainder and DATA is the next input byte. Initialise once per message, then call step for each byte in order. This is a non-reflected, left-shifting CRC with initial remainder zero and no final XOR; the qualified polynomials are 07 and 31, with the x⁸ term implicit. DATA survives and CRC is replaced. Producer and consumer must agree on every parameter and the exact covered bytes.

Initialise, feed the counted payload bytes one at a time and store the final CRC separately. A reader recomputes over the same span and compares with the stored value. Do not accidentally include the stored checksum in one side’s payload but exclude it on the other.

Two bytes, one persistent remainder and one input. The demonstration feeds the ASCII bytes of 123456789. It finishes at hexadecimal F4 for polynomial 07 and A2 for polynomial 31. These are this implementation’s directly checked message results, not a claim that every CRC-8 convention has the same answer.

AF/BC/DE/HL may change; IX/IY survive. A direct CALL needs two return-address stack bytes.

## Customisation and errors

The custom build uses polynomial 31 instead of 07. Both are complete specified parameter sets here; changing the polynomial on only one side makes otherwise identical payloads disagree.

The wrong client clears CRC before every byte. Only the last byte contributes to the final result, which becomes AF for the normal polynomial instead of F4. Reset once at the message boundary, then retain the remainder between calls.

An eight-bit CRC has only 256 results and cannot detect every possible change. It checks accidental corruption; it is not authentication or protection against someone deliberately editing a save. Wider CRCs, table-based updates and other parameter conventions need separate contracts and vectors. Saving atomically and validating the file length remain separate concerns.

## Cost and evidence

Measured extent: 29 code bytes, 0 immutable data bytes and 2 private state bytes, excluding alignment, return-address/temporary stack, the case table and presentation machinery. Exactly eight bit stages per input byte, with a conditional polynomial XOR in each stage. No lookup table is required. A 256-byte table can trade ROM space for fewer per-byte operations, but that is a separate implementation and is not measured here.

Run make with ASM198X; the Amiga build also accepts BUILD198X. Four variants are maintained: demo, custom, deliberately wrong and exact repair. Observed rows: demo F4 39 00 00 00 00 00 00; custom A2 39 00 00 00 00 00 00; wrong AF 39 00 00 00 00 00 00. These are the first eight state bytes, padded/truncated for display. The packet records all bytes after every call.

Native configuration: Spectrum 48K with stock ROM tape loading and USR entry; Asm198x 0.0.72 and Emu198x 0.44.2. Each run covers 64 boundary/varied/error table cases plus a separate sequential client and dirty-state init. Checked source/tool/firmware identities, preserved-register sentinels, actual helper/data extents, immutable loaded bytes, independent integer packet, screenshot pixels and exact repair are retained in verification/. Restricted firmware and snapshots are not distributed. This is configuration-specific qualification, not exhaustive input coverage or original-hardware timing.

Refresh with scripts/verify-playtools.py --topic streaming-crc8 --help; check-playtools.py and test_playtools.py validate every explicit target and reject changed evidence. The shared test models are verification inputs, not runtime dependencies. The client’s checked_step wrapper calls the public streaming_crc8_step entry; emit_state is only a diagnostic observer. In a game, call the public entry directly and consume its documented outputs.

The standalone tape program enters at $8000, disables interrupts and owns bitmap/attribute RAM. It does not restore BASIC. Those choices belong to the test program; the helper itself never takes over the display.
