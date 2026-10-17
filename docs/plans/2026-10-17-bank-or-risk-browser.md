# Bank or risk browser playtest

Build an offline browser version so the user can judge the agreed game's pace,
risk and recovery while native AMOS access is unavailable. This is design
evidence, not AMOS execution or a replacement lesson.

1. Add a self-contained `commodore-amiga/amos/bank-or-risk/browser/index.html`.
   Keep limit 10, target 30 and five rounds. Show die, current total, secured
   score, remaining opportunities and stable round/session results. Support
   pointer, touch and keyboard, with fresh input at transitions.
2. Add README instructions and focused verification in that directory. Use
   built-in Node tests for the state transitions and existing browser tooling
   for desktop/mobile, keyboard, boundary, replay and accessibility checks.
   Add no dependencies. Keep prescribed rolls in tests only.
3. Supply a durable, directly openable HTML file for the user and create a
   review PR. Record the checks and their limits. Verify the pushed commit,
   stop the test server and remove the clean temporary worktree.

Use the existing Code198x browser experiment conventions. Keep the screen a
legible game board, with original geometric die artwork, explicit controls and
no timer. Optional short event tones add feedback, with all meaning available
muted. No animation, opponent, wagering, records or new difficulty settings.
