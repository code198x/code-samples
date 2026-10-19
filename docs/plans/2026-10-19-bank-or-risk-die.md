# Draw and connect the first AMOS die

Keep the accepted rules and input. Use the agreed fixed picture, then explicit
face decisions; no arrays, asset banks, animation or new mechanics.

1. Add `stages/fixed-die.amos` and `stages/match-die.amos` beside `prototype/`.
   Explain pixel coordinates, Ink/Box/Bar, and exact changes in `stages/README.md`.
   Verify the fixed pip and each supplied face 1–6 in original AMOS.
2. Add one call and a drawing routine to `prototype/bank-or-risk.amos`, selecting
   from BR_LASTROLL. Keep numeric labels; zero shows an empty outline. Verify
   unchanged rules/input source apart from those isolated drawing additions.
3. Reuse the qualified local AMOS media preparation and Emu198x replay path.
   Retain scripts, source/media hashes, inspected captures and limits in a new
   docs audit. Check all six faces, a face change that removes old pips, bank,
   bust, success, failure, round reset and replay.
4. Update current source/probe identities, teaching map and prototype status.
   Check fixture transformations, lint, prose, JSON and links. Commit and push
   both repos; leave PRs open. Remove task worktrees, builds and local media.
