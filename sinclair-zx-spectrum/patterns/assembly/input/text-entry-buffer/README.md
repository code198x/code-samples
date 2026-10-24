# A Counted Text-entry Buffer on Spectrum

Entering a player name needs more than appending characters. Full buffers must refuse another byte, Backspace at the start must stay at zero, and the caller must know how many characters are real.

## Bind, initialise and call

Allocate the contiguous private bytes LENGTH, STATUS, KEY, MODE, BUF0, BUF1, BUF2, BUF3, BUF4, BUF5, BUF6, BUF7 in that order. Include component.inc once, call text_entry_buffer_init, then set the starting inputs/state. Init clears every named byte, including inputs. Call text_entry_buffer_step for each intended service. Use one owner; independent instances need distinct state and scoped/renamed labels. No helper owns a clock, input reader, display, allocation or interrupt controller.

The buffer reserves BUF0–BUF7. LENGTH is the number of live bytes. MODE 0 appends KEY only when it is ASCII 32–126 and room remains; MODE 1 removes the last byte and clears that slot; MODE 2 clears all eight slots and length, even if the old length is corrupt. STATUS is 1 for a change/clear, 0 for full append or empty Backspace, 2 for a rejected character, and 3 for an invalid mode/length. Apart from clear, LENGTH above TEXT_CAP rejects without touching the buffer. The maintained capacities are eight and four.

Initialise once, translate the machine’s input into a logical key/action, then call step. Draw exactly LENGTH bytes. This is a counted buffer, not a promise of a zero terminator when full. The helper does not scan a keyboard, wait for input or implement key repeat.

Four control/input/output bytes followed by eight reserved character bytes. KEY and MODE survive. Appending preserves inactive slots; Backspace clears the removed slot, and clear empties all eight. The custom smaller capacity retains eight-byte storage and changes accepted length, not the allocation.

AF/BC/DE/HL may change; IX/IY survive. A direct CALL needs two return-address stack bytes.

## Customisation and errors

The custom build lowers TEXT_CAP from eight to four and its client appends C after clearing the two-character example with Backspace. It finishes with the one-character name C. Boundary cases also exercise full/invalid lengths under the smaller capacity.

The wrong client decrements an empty length on Backspace. Zero wraps to 255, making the supposed name length exceed the entire buffer. Keep zero at zero; subsequent operations on a corrupt length must reject or explicitly clear it.

Cursor movement, insertion in the middle, key mapping, accented characters and Unicode require additional rules and often more storage. ASCII here is an interchange choice; C64 screen codes and NES tile numbers need a presentation mapping. Do not scan past the counted span looking for a terminator.

## Cost and evidence

Measured extent: 152 code bytes, 0 immutable data bytes and 12 private state bytes, excluding alignment, return-address/temporary stack, the case table and presentation machinery. Append and Backspace touch at most one slot. Clear touches the eight reserved slots. Bounds and key checks are part of the implementation; removing them creates a different trust contract and can corrupt neighbouring state.

Run make with ASM198X; the Amiga build also accepts BUILD198X. Four variants are maintained: demo, custom, deliberately wrong and exact repair. Observed rows: demo 00 00 42 01 00 00 00 00; custom 01 01 43 00 43 00 00 00; wrong FF 01 42 01 00 00 00 00. These are the first eight state bytes, padded/truncated for display. The packet records all bytes after every call.

Native configuration: Spectrum 48K with stock ROM tape loading and USR entry; Asm198x 0.0.72 and Emu198x 0.44.2. Each run covers 64 boundary/varied/error table cases plus a separate sequential client and dirty-state init. Checked source/tool/firmware identities, preserved-register sentinels, actual helper/data extents, immutable loaded bytes, independent integer packet, screenshot pixels and exact repair are retained in verification/. Restricted firmware and snapshots are not distributed. This is configuration-specific qualification, not exhaustive input coverage or original-hardware timing.

Refresh with scripts/verify-playtools.py --topic text-entry-buffer --help; check-playtools.py and test_playtools.py validate every explicit target and reject changed evidence. The shared test models are verification inputs, not runtime dependencies. The client’s checked_step wrapper calls the public text_entry_buffer_step entry; emit_state is only a diagnostic observer. In a game, call the public entry directly and consume its documented outputs.

The standalone tape program enters at $8000, disables interrupts and owns bitmap/attribute RAM. It does not restore BASIC. Those choices belong to the test program; the helper itself never takes over the display.
