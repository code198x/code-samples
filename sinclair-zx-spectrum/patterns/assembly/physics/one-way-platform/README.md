# Land on a One-way Platform on Spectrum

A fast-falling character can cross a thin platform between two updates without ever having its feet exactly on the top. Compare the old and proposed bottom edges, then snap the feet to the surface when the downward path crosses it.

## Bind, initialise and call

Allocate the contiguous private bytes LANDED, SNAP, ACTOR_X, ACTOR_W, PREV_BOTTOM, NEW_BOTTOM, PLATFORM_X, PLATFORM_W, PLATFORM_Y, DROP in that order. Include component.inc once, call one_way_platform_init, then set the starting inputs/state. Init clears every named byte, including inputs. Call one_way_platform_step for each intended service. Use one owner; independent instances need distinct state and scoped/renamed labels. No helper owns a clock, input reader, display, allocation or interrupt controller.

ACTOR_X/ACTOR_W and PLATFORM_X/PLATFORM_W describe unsigned horizontal half-open intervals. Each span includes X and stops just before X + width, so touching edges alone do not overlap. Width zero rejects contact; widened endpoints may reach 510. PREV_BOTTOM and NEW_BOTTOM are unsigned old/proposed bottom coordinates, increasing downwards. Landing requires horizontal overlap and PREV_BOTTOM ≤ PLATFORM_Y ≤ NEW_BOTTOM, with DROP zero. LANDED is replaced with 1 on contact; SNAP becomes PLATFORM_Y on contact and otherwise NEW_BOTTOM. Stationary feet exactly on top count as contact. All inputs survive.

Initialise once, supply the old and proposed geometry, then service before committing a fall. On LANDED, place the bottom at SNAP and let the caller decide vertical velocity and grounded state. Test each candidate platform as needed; selecting among several surfaces requires the nearest valid top along the path, not an arbitrary last result.

Ten bytes, with LANDED and SNAP first for inspection. Both horizontal intervals use widened arithmetic. The vertical coordinates do not wrap: crossing the byte coordinate seam is outside this contract and needs a wider world representation.

AF/BC/DE/HL may change; IX/IY survive. A direct CALL needs two return-address stack bytes.

## Customisation and errors

The custom caller sets DROP to 1. The same downward crossing now passes through the platform, returning LANDED zero and SNAP equal to the proposed bottom 110. The caller decides how long drop-through remains active.

The wrong client retains a contact only when the proposed bottom equals the platform top. It discards the correctly detected 90→110 crossing of top 100, so a fast fall misses the surface. Compare the interval crossed, not just equality at the endpoint.

This tests a horizontal one-way top, not walls, ceilings, slopes or a full swept-AABB solver. Teleports and large coordinate jumps need an explicit policy. Moving platforms also need relative motion and carried movement. The static rectangle-overlap routines remain useful for other contact tests.

## Cost and evidence

Measured extent: 117 code bytes, 0 immutable data bytes and 10 private state bytes, excluding alignment, return-address/temporary stack, the case table and presentation machinery. Two horizontal interval comparisons and two vertical comparisons, with no per-pixel stepping. On 6502/Z80 a carry from an endpoint addition represents an endpoint beyond 255; 68000 uses widened words. The caller’s search over platforms is additional work.

Run make with ASM198X; the Amiga build also accepts BUILD198X. Four variants are maintained: demo, custom, deliberately wrong and exact repair. Observed rows: demo 01 64 14 10 5A 6E 0A 40; custom 00 6E 14 10 5A 6E 0A 40; wrong 00 6E 14 10 5A 6E 0A 40. These are the first eight state bytes, padded/truncated for display. The packet records all bytes after every call.

Native configuration: Spectrum 48K with stock ROM tape loading and USR entry; Asm198x 0.0.72 and Emu198x 0.44.2. Each run covers 64 boundary/varied/error table cases plus a separate sequential client and dirty-state init. Checked source/tool/firmware identities, preserved-register sentinels, actual helper/data extents, immutable loaded bytes, independent integer packet, screenshot pixels and exact repair are retained in verification/. Restricted firmware and snapshots are not distributed. This is configuration-specific qualification, not exhaustive input coverage or original-hardware timing.

Refresh with scripts/verify-playtools.py --topic one-way-platform --help; check-playtools.py and test_playtools.py validate every explicit target and reject changed evidence. The shared test models are verification inputs, not runtime dependencies. The client’s checked_step wrapper calls the public one_way_platform_step entry; emit_state is only a diagnostic observer. In a game, call the public entry directly and consume its documented outputs.

The standalone tape program enters at $8000, disables interrupts and owns bitmap/attribute RAM. It does not restore BASIC. Those choices belong to the test program; the helper itself never takes over the display.
