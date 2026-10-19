# Group the AMOS board by the values' jobs

Keep the accepted rules, die coordinates, palette and fresh-key handling.
Sound remains a separate step.

1. Replace only BR_DRAW_STATE in `prototype/bank-or-risk.amos`: group this
   round's total/limit/award, secured score/target/current round, later or unused
   rounds, result and controls. Derive displayed later rounds from max minus
   current round; do not read stale BR_REMAIN before its scoring update.
2. Add complete `stages/round-board.amos` and `stages/challenge-board.amos`
   supplied-state snapshots, and explain exact edits in `stages/README.md`.
   Keep existing drawing routines explicit and explain their inputs/return.
3. Use the existing AMOS/Emu198x and verified work/data disk path. Inspect both
   snapshots and live ready, all faces, bank, bust, reset, success, failure,
   fifth-round completion and replay. Retain exact inputs/scripts/captures in
   the docs audit; preserve previous source pins and persistence limits.
4. Verify the game differs only in its display routine; compare stage/live
   display blocks, exact probe transformations/hashes and overwrite refusal.
   Run lint/prose/JSON/link checks, commit and push both repos, update open PRs.
   Verify remote commits and remove task worktrees, builds and local media.
