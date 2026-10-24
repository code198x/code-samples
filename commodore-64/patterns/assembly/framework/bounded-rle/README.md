# Decode Bounded RLE Data on C64

Repeated tiles or pixels can be stored as a count followed by a value. Decoding is small, but trusting a damaged run count can overwrite the next object in RAM. This version checks both ends and tells the caller exactly how much output was produced.

## Bind, initialise and call

Allocate the contiguous private bytes WRITTEN, ERROR, INPUT_START, INPUT_END, OUTPUT_LIMIT, BUF0, BUF1, BUF2, BUF3, BUF4, BUF5, BUF6, BUF7 in that order. Include component.inc once, call bounded_rle_init, then set the starting inputs/state. Init clears every named byte, including inputs. Call bounded_rle_step for each intended service. Use one owner; independent instances need distinct state and scoped/renamed labels. No helper owns a clock, input reader, display, allocation or interrupt controller.

INPUT_START and INPUT_END are byte offsets into caller-owned rle_stream, with INPUT_START ≤ INPUT_END ≤ STREAM_BYTES. OUTPUT_LIMIT is 0–8 for the reserved eight-byte output buffer. Step replaces WRITTEN and ERROR, preserves the input parameters and decodes count/value pairs. ERROR 0 means the selected input span finished; 1 means invalid input/output bounds; 2 means a truncated pair; 3 means a zero run; 4 means output capacity was reached before the selected stream finished. WRITTEN counts only bytes actually stored.

Initialise once, set the selected encoded span and available output length, then service. Check ERROR before accepting an asset as complete. On a decoding error the buffer contains a valid decoded prefix of length WRITTEN; it is not rolled back. Bytes after that prefix are preserved. A consumer that wants an all-or-nothing asset should decode into staging memory and commit only on success.

Five control/input/output bytes followed by BUF0–BUF7. The sample has thirteen immutable input bytes, including malformed examples. Count zero is rejected; there is no terminator convention or implicit end beyond INPUT_END. A zero-length selected span succeeds with zero output. The routine can stop partway through a run when capacity is exhausted.

A/X/flags may change; Y and decimal mode survive. Clear decimal mode before binary arithmetic; the caller uses CLD. A direct call needs two return-address stack bytes. Saving Y and the input offset adds up to two temporary stack bytes: allow four bytes for the helper call, excluding its caller and interrupts.

## Customisation and errors

The normal caller decodes the first six input bytes into AAABBC, six output bytes. The custom caller offers only five output slots: AAABB is produced and ERROR 4 reports the unfinished selected stream. Treating capacity as the amount written would hide the normal caller’s two unused slots.

The wrong client replaces WRITTEN with OUTPUT_LIMIT after decoding. The normal six-byte asset is now advertised as eight bytes, including two bytes the decoder never produced. Publish the returned length, and check the returned error; capacity is not output length.

This is a local classic count/value codec example, not a new project-wide asset format. Longer assets need an appropriately sized output span and possibly wider offsets, plus independently checked bounds. Packed literals, streaming continuation and precompressed build-tool assets are separate extensions. Do not turn zero runs into an unchecked infinite loop or infer success from a full buffer.

## Cost and evidence

Measured extent: 128 code bytes, 13 immutable data bytes and 13 private state bytes, excluding alignment, return-address/temporary stack, the case table and presentation machinery. Work is bounded by the selected input span and output capacity. Each pair consumes two input bytes; each produced byte advances the output count. The qualified output has at most eight stores, with no allocation or hidden display upload. Compression trades encoded storage against decode work and may make alternating data larger.

Run make with ASM198X; the Amiga build also accepts BUILD198X. Four variants are maintained: demo, custom, deliberately wrong and exact repair. Observed rows: demo 06 00 00 06 08 41 41 41; custom 05 04 00 06 05 41 41 41; wrong 08 00 00 06 08 41 41 41. These are the first eight state bytes, padded/truncated for display. The packet records all bytes after every call.

Native configuration: PAL C64 with stock BASIC/KERNAL PRG startup and RUN; Asm198x 0.0.72 and Emu198x 0.44.2. Each run covers 64 boundary/varied/error table cases plus a separate sequential client and dirty-state init. Checked source/tool/firmware identities, preserved-register sentinels, actual helper/data extents, immutable loaded bytes, independent integer packet, screenshot pixels and exact repair are retained in verification/. Restricted firmware and snapshots are not distributed. This is configuration-specific qualification, not exhaustive input coverage or original-hardware timing.

Refresh with scripts/verify-playtools.py --topic bounded-rle --help; check-playtools.py and test_playtools.py validate every explicit target and reject changed evidence. The shared test models are verification inputs, not runtime dependencies. The client’s checked_step wrapper calls the public bounded_rle_step entry; emit_state is only a diagnostic observer. In a game, call the public entry directly and consume its documented outputs.

The standalone PRG owns screen/font/colour RAM, disables interrupt sources and does not restore BASIC. Its private scratch uses $70–$76 and the state binding starts at $80; its diagnostic output starts at $C000.
