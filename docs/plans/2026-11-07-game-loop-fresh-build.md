# Record game loops from a fresh checkout

The measurement setup reproduced `FileNotFoundError: build/demo.sym` because
`run()` reads symbols before `build()` creates them. Its output-directory
creation also assumes `build/` already exists. The clock measurements used an
explicit prebuild and remain separate local evidence.

1. Add fresh-temporary-tree and build-failure controls to the existing
   CI-discovered `scripts/test_capability_coverage.py` suite. Show the fresh-tree
   case fail against the existing recorder ordering.
2. In `scripts/verify-game-loops.py`, move the symbol read and output-directory
   creation after the existing `build()` helper. Keep commands and guards.
   Rerun the tests, including propagation of a failed build.
3. Inspect capability/probe inventories and recorder references. Update only
   the current `verification_tools` entry in `docs/capability-coverage.json`.
   Preserve all historical observer/source hashes, observations and captures.
4. Run both complete inventories and relevant tests using the pinned tools,
   and a fresh actual recorder run. Compare generated program bytes and
   observations to the existing records. Push a separate PR, require current
   CI and obtain review before merge. Keep clock measurements out of the commit.
