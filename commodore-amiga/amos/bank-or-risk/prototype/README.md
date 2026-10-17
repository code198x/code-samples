# Bank or risk AMOS prototype

**Prepared source, not yet executed in AMOS.** The native computer-control
connection failed before reaching an app. This listing is a proposed endpoint
for the agreed first game: limit 10, at most five rounds, target 30. Syntax,
layout, input, save/reopen and play remain unverified in the original runtime.

Use the [game brief](https://github.com/code198x/docs/blob/amiga-course-and-tooling-briefs/platforms/commodore-amiga/games/bank-or-risk/brief.md)
for the rules and acceptance requirements. No lesson sequence or new language
implementation is supplied here. This text-first version is deliberately silent.

## Source and controls

`bank-or-risk.amos` contains ASCII source, not a tokenised AMOS project. Copy it
to the mounted Tools drive as `bank.asc`, then use the editor's **Merge ASCII**
operation. Do not assume a normal tokenised-project load accepts these bytes.
Save the imported program as a native AMOS project and independently reopen it
before claiming persistence. These steps reuse the earlier checked import route;
this particular program has not completed it.

The execution baseline is AMOS Professional 2.00 from official revision
`533b4b1f5acd604814513f78e02c7b4796cb0531`, FS-UAE 3.2.35, PAL A1200/68020,
2 MB chip and 8 MB fast memory, Kickstart and Workbench 3.1. The baseline is not
a minimum hardware claim. Use the published
[AMOS setup](https://code198x.com/systems/commodore-amiga/amos/getting-started/)
and lawfully supplied firmware and OS media.

Press F1 after importing. SPACE starts; R requests a roll, B banks after a roll,
SPACE continues after a completed round, A starts a new challenge at a result,
and Q finishes. AMOS normally shows its end-of-program requester; Return returns
to the editor in the checked opening workflow. The new program's controls still
require a native run.

The source waits for release of the previous key before clearing the keyboard
buffer and accepting the next event. This is intended to prevent a held R, B,
SPACE or A from acting repeatedly or crossing a phase boundary. Verify those
cases in AMOS; reading this routine does not establish that the behaviour works.

## Random range and input sources

The [AMOS Professional manual, Maths](https://amospromanual.dev/05-03-maths.html#rnd)
defines `Rnd(n)` as including the specified upper bound. The proposed die is
therefore `Rnd(5)+1`, not `Rnd(6)+1`. `Randomize Timer` seeds the generator after
the title input; it is not a claim of physical randomness or measured fairness.

The [keyboard chapter](https://amospromanual.dev/10-01-using-the-keyboard.html)
defines `Inkey$`, `Scancode`, `Key State` and `Clear Key`. The source saves the
scan code immediately after the input loop; native testing must check key release
and any repeat/buffer behaviour on the pinned configuration.

## Native probes to run

Run `python3 prepare-probes.py <empty-output-directory>` from this directory to
generate fixed-roll copies and their expected input/result manifest. Each copy
changes only the die supplier, resets its DATA cursor at a new challenge and
appends the prescribed data. The ordinary game remains random. These copies are
test fixtures, not recordings or proof of execution.

The probes cover exact 10, overshoot, a bust preserving earlier points, recovery,
success on the fifth round and an unreachable target. Also inspect ordinary
random play, invalid input, B before the first roll, held/released keys, waiting
without action, replay and quit at every phase. Reopen a saved native project in
a fresh editor session, then play again.

Do not use the fixture generator, host rules model or file hashes as a substitute
for syntax checking and executing these programs in AMOS. Preserve actual inputs,
source identity, screenshots, outcomes and failures when the native connection
is available.
