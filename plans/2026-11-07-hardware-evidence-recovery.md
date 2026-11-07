# Finish the hardware capability evidence batch

Continue approved batch 8b from #455 on current main after Sega #459 without changing the
approved observations, captures, sound excerpts or emulator-version rulings.

1. Replay #455's three commits on a fresh branch. Resolve only the
   overlapping `plans/2026-11-07-evidence-recorders.json` inventory entries,
   retaining main's input-loop and Sega entries and the capability recorder entry.
2. Run `scripts/test_capability_coverage.py`,
   `scripts/check-capability-coverage.py` and
   `scripts/check-probe-coverage.py` against the pinned registry; run Ruff
   on changed Python and `git diff --check`. Confirm operand and forged
   program changes fail and comments pass.
3. Compare the final hardware records, excerpts and capability manifest
   byte for byte with #455, push the replacement branch, and open a PR.
   Fresh CI must pass before a merge. Remove this recovery worktree once
   its commits are verified on the remote and all unique files are saved.

The game-loop and collect-and-respond groups remain separate work.
