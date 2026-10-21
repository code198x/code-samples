# oric: reusable character RAM

Define G at 24 private zero-page bytes and include `glyphs.inc`. The complete reset caller initialises video, then calls init/install/select. Replace a shared shape when all instances should change; select another code when only one cell should change. Its mailbox is optional evidence transport.

Read the [machine-specific contracts, encoding, costs, hardware references and qualification limits](../../../../../cross-platform/patterns/rendering/character-ram-ports/README.md). These allocations do not establish stock-OS coexistence. Source code and original patterns are MIT licensed.

Build with `make ASM=/path/to/asm198x`. Retained `verification/` includes full font/name/guard observations, native frames, public state and exact source/tool identities. Replay it with `scripts/check-character-ram-ports.py`; corrupt evidence is rejected independently of its hashes.
