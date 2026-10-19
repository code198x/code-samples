# Bank or risk AMOS prototype

**Native rules and input checks pass in the named Emu198x configuration.** The
text-first prototype implements the accepted first game's limit 10, at most five
rounds and target 30. It now includes the explained die, board and short result
cues. Human listening acceptance and remaining replacement lessons are pending.

The [native execution record](https://github.com/code198x/docs/tree/amiga-course-and-tooling-briefs/audit/2026-10-amos-bank-or-risk-emu198x)
retains scripts, input identities, captures, observations and media checks.
This qualifies AMOS Professional 2.00 on Emu198x 0.34.2 at revision
`6cc5d5f9e7fe6507a079f237bc44da0dc95fe25c`, PAL A1200, stock 2 MiB chip RAM,
no fast RAM, and the recorded Kickstart 3.1 image. It is separate from the earlier
FS-UAE baseline and does not establish minimum hardware requirements or learner
understanding.

## Source and controls

`bank-or-risk.amos` is ASCII source, not a tokenised AMOS project. Put it on a
native disk as `bank.asc` and use **Merge ASCII** (`Amiga`+`Shift`+`M`). A path
change in the requester can need Return to accept the directory and another
Return to select the file. F2 checks syntax; F1 runs it. Explain the exact disk
and keyboard route for the environment used by the lesson.

SPACE starts; R rolls, B banks after a roll, SPACE continues after a round,
A starts a fresh challenge at a final result, and Q finishes. In the checked
configuration, Return after Q completes the return to the editor; allow its
screen transition to finish. Results stay visible until the relevant new choice.

The [drawing checkpoints](../stages/README.md) separate a fixed outline and pip
from supplied faces 1–6. The game calls `BR_DRAW_DIE` with the stored last roll;
it draws no new random value and changes no score. An empty outline means no
roll yet. The numeric last roll remains visible.

The source waits for release of the previous key, clears the keyboard buffer
and accepts a fresh event. Native checks held R for 60/90 frames and B, SPACE
and A for 90 frames. Those checks did not produce duplicate rolls, awards or
actions across the tested transitions. They are observations on this setup,
not a claim about every keyboard or runtime configuration.

Game identifiers use `BR_` so they cannot begin with AMOS command words.
The original names included `READ_FRESH`, `DRAW_STATE`, `MAXTURN`, `TOTAL` and
`REMAIN`; native tokenisation exposed command-prefix collisions. The reduced
failure and successful naming probe are retained in the execution record.
See the original manual's [naming rules](https://amospromanual.dev/05-01-the-bare-bones.html).
The naming correction preserved scoring and input logic. The subsequent palette
change adds only `Palette $000,$FFF` before `Paper 0` and `Pen 1`: entry 0 is
black and entry 1 is white, so text does not inherit the editor palette.

## Native checks

At samples revision `0c55096`, four prescribed-roll copies were imported and run
through AMOS:

- Three perfect rounds secure 30 and end successfully in round 3.
- Contributions 4, 0, 6, 10, 10 recover to 30 on round 5. The bust displays 11,
  awards zero and preserves the earlier secured 4.
- Rolls 1, 6, 2, 1 display totals 1, 7, 9, 10; exact 10 banks once.
- Three busts at 12 leave the target unreachable after round 3.

Additional checks cover B and invalid input at zero, a stable result, replay,
held/released keys, ordinary random play and quit from each phase. Save As
created a 3,728-byte native `bank.amos`; the exported work disk passed filesystem
verification. A separate cold boot loaded that saved file through native Load,
ran it, rolled and banked, then returned to the editor. That persistence check at revision `0c55096`
uses the saved program, not restoration of the original edited session.

The original AMOS input disk fails a bitmap-bounds check and the first Save
attempt reported a write-protected boot volume. The successful persistence
check used a fresh filesystem with all 78 original file contents preserved,
plus this source, mounted writable in emulator memory from boot. The pass did
not isolate those two setup changes as causes of the earlier failure. Original
media was not modified or redistributed. Use a verified writable work disk for
saving; the audit gives the reproducible route and exact limits.

The [palette execution record](https://github.com/code198x/docs/tree/amiga-course-and-tooling-briefs/audit/2026-10-amos-bank-or-risk-palette)
checks the explicit black/white palette in the same native configuration at
revision `e4f86e0`. That source and two prescribed-roll copies pass syntax checking. Title,
active play, bank, bust and success screens retain readable text and numbers.
At that revision, the source diff from `0c55096` is exactly the palette statement; the historical
save/reopen result above applies to that earlier revision.

The [drawing execution record](https://github.com/code198x/docs/tree/amiga-course-and-tooling-briefs/audit/2026-10-amos-bank-or-risk-die)
checks the fixed fragment, all six supplied faces, and the game picture beside
its numeric roll. It covers clearing old pips, empty round/replay states and
retained faces at bank, bust, success and failure. The game change adds only a
drawing call and routine; the existing scoring and input source is identical.

The [board execution record](https://github.com/code198x/docs/tree/amiga-course-and-tooling-briefs/audit/2026-10-amos-bank-or-risk-board)
checks the grouped round/session display and two supplied-state snapshots.
Current total, round award and secured points stay distinct; final results
label any remaining capacity as unused rounds. Only `BR_DRAW_STATE` changes
from revision `b3998ba`; scoring, input and die drawing are identical.
The [board checkpoints](../stages/README.md#give-this-round-its-own-space) explain
the layout and exact supplied-state edits.

The [sound record](https://github.com/code198x/docs/tree/amiga-course-and-tooling-briefs/audit/2026-10-amos-bank-or-risk-sound)
retains native PCM for the tone variations and bank/bust/success events. Success
replaces the final bank cue. Seventeen required recording checks pass; the nine
muted/audible perfect-run screens are byte-identical. Held-key, waiting, invalid
input, immediate continuation and ready-prompt replay/quit windows are recorded.
The earliest ending key can be cleared by the existing fresh-choice handover;
the silent baseline does the same. The audit distinguishes those windows and
does not claim subjective sound quality or a complete latency bound.
See the [sound checkpoints](../stages/README.md#hear-one-short-tone) for the
parameter experiment and complete bank, bust and success versions.

## Random range and prescribed rolls

The [original Maths chapter](https://amospromanual.dev/05-03-maths.html#rnd)
defines `Rnd(n)` as including the upper bound. The die uses `Rnd(5)+1`.
`Randomize Timer` seeds it after the title input. The ordinary native run
observed a valid roll; neither that observation nor the prescribed copies proves
random fairness or all possible generator outputs.

Run `python3 prepare-probes.py <empty-output-directory>` to generate five
copies, including a supplied sequence covering all six die faces, and their
manifest. The generator changes only the die supplier to
`Read BR_FACE`, restores DATA at a new challenge and appends prescribed values.
The manifest records expected outcomes; actual observations belong in the audit.
Ruff and exact transformation/hash checks pass, including refusal to overwrite
a nonempty destination.

The [keyboard chapter](https://amospromanual.dev/10-01-using-the-keyboard.html)
defines `Inkey$`, `Scancode`, `Key State` and `Clear Key`. Further environments,
later graphics/sound changes and teaching stages need their own execution checks. The
separate browser playtest's acceptance does not qualify those additions.

The [endpoint persistence record](https://github.com/code198x/docs/tree/amiga-course-and-tooling-briefs/audit/2026-10-amos-bank-or-risk-persistence)
checks native Save As and independent cold-boot Load of the sound-enabled source
at revision `1fa0675`. The reopened game rolls and banks four points with its
short cue, then returns to the editor. A separately saved prescribed-roll copy
compares nine game states and bank/bank/success cues before and after saving.
The maintained source and fixed-roll copy remain distinct. Licensed media and
native saved programs are excluded from the public audit. Human listening/play
acceptance and the learner trial remain pending.
