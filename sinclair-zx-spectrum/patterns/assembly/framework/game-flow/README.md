# Game states and restart on Spectrum

Only AF changes; BC/DE/HL/IX/IY survive. The five named component fields follow the code in private writable RAM. A direct call uses a two-byte return address.

The 48K PAL standalone caller enters through ROM tape loading and BASIC USR at $8000, then disables interrupts, owns the bitmap/attributes/border and uses ROM glyphs for diagnostics. Mutable fields and output follow its code. It remains in its hold loop rather than restoring BASIC.

Include the maintained flow helper once, reserve five private bytes, call flow_init at startup and supply events before flow_step. State0 Title,1 Play,2 Over,3 Pause; events1 Start,2 Pause,4 Loss,8 Restart. Loss wins Pause; Over/Restart wins Start. One transition/update. CHANGED is an entry pulse, FRESH requests one session reset, ERROR1 invalid state or2 upper event bits; invalid input preserves state. Consume pulses before the next step. The helper does not reset payload or input history.

Reset score/health on FRESH only. Paused session and previous-held input survive transitions. Old-state simulation runs before the decision; no new-state update consumes the same event. Callers must diagnose errors before rendering/indexing state. Single owner; no IRQ mutation, callbacks or locking.

Measured 139 code bytes +5 state bytes at supplied layout, bounded decision path, no wait/scan. Caller payload, sampling history and diagnostic buffers are separate. Demo row04 02 01 02 03 06 01 00; custom health5 changes fifth field; wrong resets every Playing entry and shows00 03 01 02 03 02 01 00. Exact repair restores working executable.

Native verification uses scripts/verify-pools-and-states.py --topic game-flow --system sinclair-zx-spectrum with pinned tool/firmware arguments. Each of four variants emits1405bytes:64 state/event pairs,252 invalid states,12 illegal-event cases and15 logical updates. This is scripted logic execution, not a new physical input-reader check. Build with the local Makefile; check both scripts/check-pools-and-states.py and unittest test_pools_and_states.py. See verification records for source/tool/configuration identities; no firmware-bearing snapshots distributed.
