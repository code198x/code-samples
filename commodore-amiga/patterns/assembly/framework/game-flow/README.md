# Game states and restart on Amiga

D0/CCR may change; D1–D7/A0–A6 survive. The five component fields are bytes in private writable RAM in the relocated Hunk. A direct call uses a four-byte return address. There is no status result in carry: read the explicit error/pulse bytes.

The A500 OCS/PAL caller cold-boots an OFS ADF with Kickstart1.3, then takes over IRQ, DMA, Copper and its private bitplane. Code and writable fields are relocated from a Hunk; it does not return to the OS.

Include the maintained flow helper once, reserve five private bytes, call flow_init at startup and supply events before flow_step. State0 Title,1 Play,2 Over,3 Pause; events1 Start,2 Pause,4 Loss,8 Restart. Loss wins Pause; Over/Restart wins Start. One transition/update. CHANGED is an entry pulse, FRESH requests one session reset, ERROR1 invalid state or2 upper event bits; invalid input preserves state. Consume pulses before the next step. The helper does not reset payload or input history.

Reset score/health on FRESH only. Paused session and previous-held input survive transitions. Old-state simulation runs before the decision; no new-state update consumes the same event. Callers must diagnose errors before rendering/indexing state. Single owner; no IRQ mutation, callbacks or locking.

Measured 214 code bytes +5 state bytes at supplied layout, bounded decision path, no wait/scan. Caller payload, sampling history and diagnostic buffers are separate. Demo row04 02 01 02 03 06 01 00; custom health5 changes fifth field; wrong resets every Playing entry and shows00 03 01 02 03 02 01 00. Exact repair restores working executable.

Native verification uses scripts/verify-pools-and-states.py --topic game-flow --system commodore-amiga with pinned tool/firmware arguments. Each of four variants emits1405bytes:64 state/event pairs,252 invalid states,12 illegal-event cases and15 logical updates. This is scripted logic execution, not a new physical input-reader check. Build with the local Makefile; check both scripts/check-pools-and-states.py and unittest test_pools_and_states.py. See verification records for source/tool/configuration identities; no firmware-bearing snapshots distributed.
