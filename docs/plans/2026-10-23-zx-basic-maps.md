# ZX80 and ZX81 BASIC map queries

Continue the approved language-by-language Maps column expansion. Add two reusable implementations, not a drawing claim or curriculum track. Use stock ROMs with an explicitly named RAM expansion if the complete readable library needs it.

1. Reuse the existing keyword keyboard transport and map contract. Read the original manuals and test array origins and arithmetic in each ROM. Files: `sinclair-zx{80,81}/patterns/basic/rendering/tile-map/{routines.bas,room.bas,demo.bas,customise.bas,README.md}`.
2. Implement checked cell reads/writes, property lookup and non-negative world conversion. Keep single-letter global ownership and line ranges explicit. Maintain bounded wrong-stride and missing-write-guard examples under `mistakes/`.
3. Add `scripts/verify-zx-basic-map.py`, evidence checker and mutation tests; retain actual ROM output, configuration/tool/source hashes and native captures. Run both ROMs separately, including all room cells, invalid bounds/IDs, customisation and both faults. Prove empty, stale and altered evidence fails. Add a CI check following the existing map jobs.
4. Add two website entries using CodeFromFile and verified captures, shared comparison links and a website plan. Explain array indexing, arithmetic, integration, costs, alternatives and Maths for Games. Build, check content/types and inspect desktop/phone output and overflow.
5. Push source and website review PRs stacked on #170/#948, update issue #117 and the existing coverage matrix without changing unrelated cells. Verify matrix filtering/links/counts. Preserve evidence and remote commits; stop task processes and remove disposable worktrees/tools/caches before reporting.

No dependencies, schema changes or automatic merges. Verification records qualify only the named ROM, RAM and workload; they do not prove stock 1 KiB suitability or physical-hardware timing.
