# Fixed-ROM display patterns — 21 October 2026

1. Verify and rebase-merge Emu198x #1912 and samples #144 at their reviewed heads, retaining complete check results. Rerun website #885 browser CI after source merge; merge only when all applicable checks pass. Verify deployed article bodies and capture hashes.
2. Inventory existing PET/Aquarius character-region and ZX80/ZX81 display routines. Read primary display references and current emulator paths. Use real stock repertoires and explicit display/refresh ownership; no invented pixel or character-RAM APIs.
3. Add reusable fixed-ROM/coarse-graphics routines and complete include/init/call examples for the four machines, source contracts and measured sizes. Verify native memory, output frames, boundaries and deliberate faults under named configurations. Fix any observed emulator bugs before claiming execution.
4. Add CodeFromFile website explanations, native images, Maths for Games grid/quantisation links and meaningful content checks. Build using pinned tools and run relevant tests.
5. Update the source-backed 30-machine matrix, separating published pages, review pages, probe evidence and missing entries. Push review branches, attach PRs, update existing trackers.
6. Preserve evidence and remotely retained commits, remove owned disposable worktrees/builds and stop owned processes before reporting.

Exact file targets will follow the inventory; expected source family: cross-platform/patterns/rendering/fixed-rom-displays/, per-machine patterns/assembly/rendering/, scripts/*fixed-rom*. Website: src/content/patterns/{commodore-pet,mattel-aquarius,sinclair-zx80,sinclair-zx81}/assembly/rendering/. Matrix: existing pattern-coverage-matrix.html plus regenerated evidence JSON.
