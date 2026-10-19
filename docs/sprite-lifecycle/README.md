# Software-object lifecycle qualification

The shared pattern links distinct implementations: Spectrum byte-oriented bitmap rectangles, BBC MODE4 cells with explicit buffers and Amiga word-aligned blitter objects. Existing masked renderers are reused; their single-object interfaces remain intact. Sources and complete callers live in each machine's patterns/assembly/rendering/sprite-lifecycle folder.

verification/results.json records seven Spectrum rectangle cases and four overlap cases, seven Amiga rectangle cases and one overlap case, and three BBC overlap cases: 22 total. Five deliberately altered variants must fail the independent output oracles: broken Spectrum saving, wrong Spectrum restoration order, broken Amiga mask operation, wrong Amiga restoration order, and wrong BBC restoration order. Source images survive unchanged where checked; rectangle save buffers and guards are compared independently.

Amiga size-encoding limits are separate small-memory cases (64 words by one row, one word by 1024 rows), not a maximum simultaneous allocation or throughput benchmark. Spectrum checks include the bitmap end and interleaving boundaries. Complete real-ROM/tape, BBC-loader and ADF callers are executed and captured separately from the stopped fixtures. Fresh Spectrum CPU-fixture checks run in CI without firmware; Amiga/BBC records require their named local firmware.

The retained-source guard verifies all source/shared-helper bindings, observer, case groups, controls and capture hashes. Its four tests reject stale or incomplete records. It performs no fresh execution itself. No original-hardware, tear-free, full-game deadline or general emulator qualification is claimed.

Save/draw A then B; restore B then A before capturing the next frame. Old buffers and old screen addresses remain paired until restoration. A background change or scroll invalidates that assumption unless old objects are removed first; dirty-tile rebuild and clean back buffers remain onward techniques. Hardware sprites on C64/NES normally have a different lifecycle because they do not paint into the playfield.
