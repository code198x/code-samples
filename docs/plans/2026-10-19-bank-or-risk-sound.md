# Give each AMOS result one short cue

Keep the accepted rules, board, die and input. Success replaces the final bank
cue; bank/bust/success use different pitches of one explained fading tone.

1. Develop `stages/short-tone.amos` first. Use the native sine wave, explicit
   volume/envelope, and Play with zero instruction delay. Explain pitch,
   envelope phases, duration units, volume, channels and stopping. Build the
   existing Emu198x/Build198x tools offline; capture actual native audio.
2. Only after that pilot works, initialise the same sound in
   `prototype/bank-or-risk.amos`, call one result routine after the once-only
   award/session decision, and stop it at replay/quit. Preserve score, board,
   die and fresh-key source. Add event-stage copies separately for bank, then
   bust, then success, with complete sources and exact edits in stages/README.
3. Retain native scripts, hashes, screenshots and WAV evidence in a new docs
   audit. Test positive bank/bust/success cues, no repeats while waiting or
   holding keys, invalid/no-award inputs, immediate next-round/replay/quit
   responsiveness, pre-emption, and muted play. Compare audible/muted outcomes.
   Reject empty/silent recordings for positive cases; measure real sample data.
4. Update current source/probe/status records, keeping historical pins and
   persistence limits. Run source-diff/probe checks, Ruff, prose, JSON and links.
   Commit/push owning repos and update open PRs without merging. Verify remote
   commits, remove task worktrees/builds/runtime copies and stop task processes.
