# Jump Buffering and Coyote Time on Amiga

Press Jump just before landing and it is frustrating when the press disappears. Walk a tiny distance off a ledge and a short forgiveness window can still let the jump happen. These two timers give the game those choices without hiding the rules inside the input reader.

## Bind, initialise and call

Allocate the contiguous private bytes JUMPED, COYOTE, BUFFER, GROUNDED, PRESSED in that order. Include component.inc once, call jump_windows_init, then set the starting inputs/state. Init clears every named byte, including inputs. Call jump_windows_step for each intended service. Use one owner; independent instances need distinct state and scoped/renamed labels. No helper owns a clock, input reader, display, allocation or interrupt controller.

GROUNDED and PRESSED are caller inputs; any nonzero value is true, and PRESSED must mean a new press. Each step first decrements positive COYOTE and BUFFER timers, then reloads COYOTE from COYOTE_STEPS when grounded and BUFFER from BUFFER_STEPS on a press. If both timers are positive, it emits JUMPED = 1 and consumes both timers; otherwise JUMPED is zero. Both configured windows are 1–255 service calls. The maintained builds use four and two.

Initialise at the session/reset boundary. Update grounded state from collision, supply the new-press bit, then service once per simulation update. On JUMPED, the caller applies the chosen vertical velocity and updates its movement state. The helper grants a jump; it does not move the player or decide whether a floor contact is real.

Five bytes: JUMPED is a replaced pulse, COYOTE and BUFFER persist, GROUNDED and PRESSED are inputs. A timer of one expires at the start of this call unless its corresponding current input reloads it. A stationary grounded player with no buffered or new press does not jump.

D0–D3/A0–A1/CCR may change; D4–D7/A2–A6 survive. A direct BSR/JSR needs four return-address stack bytes.

## Customisation and errors

The custom build shortens both windows from four calls to two. In the supplied trace, a press three calls before landing is accepted with the four-call buffer and has expired with the two-call buffer. The final row alone does not count earlier jump pulses; the complete packet retains every call.

The wrong client supplies a held level as PRESSED on every call. The permission can be reissued on successive grounded updates even though the player never made another press. Feed a new-press edge and retain the timers; also update the caller’s grounded/movement state when it accepts a jump.

This is a logical permission service, not a complete platformer jump controller. Variable jump height, multiple air jumps, wall jumps and input consumption across menus need explicit additional policies. Freeze or advance the timers during pause deliberately. Respawn invulnerability is a different grace window and remains covered by damage/recovery.

## Cost and evidence

Measured extent: 136 code bytes, 0 immutable data bytes and 5 private state bytes, excluding alignment, return-address/temporary stack, the case table and presentation machinery. Two saturating decrements, input-dependent reloads and a pair of tests per update. There is no busy wait or keyboard scan. The same call-count settings represent different real durations under different service rates; choose a simulation clock before tuning them.

Run make with ASM198X; the Amiga build also accepts BUILD198X. Four variants are maintained: demo, custom, deliberately wrong and exact repair. Observed rows: demo 00 04 00 01 00 00 00 00; custom 00 02 00 01 00 00 00 00; wrong 01 00 00 01 01 00 00 00. These are the first eight state bytes, padded/truncated for display. The packet records all bytes after every call.

Native configuration: A500 OCS PAL with Kickstart 1.3 and an OFS cold-boot disk; Asm198x 0.0.72 and Emu198x 0.44.2, with Build198x 0.2.9 for disk mastering. Each run covers 64 boundary/varied/error table cases plus a separate sequential client and dirty-state init. Checked source/tool/firmware identities, preserved-register sentinels, actual helper/data extents, immutable loaded bytes, independent integer packet, screenshot pixels and exact repair are retained in verification/. Restricted firmware and snapshots are not distributed. This is configuration-specific qualification, not exhaustive input coverage or original-hardware timing.

Refresh with scripts/verify-playtools.py --topic jump-windows --help; check-playtools.py and test_playtools.py validate every explicit target and reject changed evidence. The shared test models are verification inputs, not runtime dependencies. The client’s checked_step wrapper calls the public jump_windows_step entry; emit_state is only a diagnostic observer. In a game, call the public entry directly and consume its documented outputs.

The bootable caller takes over Copper/bitplane/interrupt/DMA resources and explicitly disarms all eight sprites. It does not restore Workbench. These are caller presentation choices, not dependencies of the reusable helper.
