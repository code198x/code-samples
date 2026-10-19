# From one round to a challenge

The finished challenge gives us five rounds to secure 30 points. A bank keeps
the round's total, exactly 10 banks automatically, and a bust awards zero.
Earlier secured points survive a later bust. These checkpoints build that
session from the [checked one-round opening](../opening/README.md).

Use a blank AMOS Professional project for each separately named source: Merge
ASCII its `.asc` copy, F2 to check syntax, F1 to run. Replace the previous listing
when changing files; Merge ASCII adds to an existing project. Q quits wherever
the displayed controls offer it. Allow the native End prompt to appear before
Return completes the editor transition. The
[native record](https://github.com/code198x/docs/tree/amiga-course-and-tooling-briefs/audit/2026-10-amos-bank-or-risk-session)
pins the configuration, actions and observed results. These are complete
authoring checkpoints, not published replacement lessons or learner findings.

## Keep one value while clearing another

Run [keep-secured.amos](keep-secured.amos). This is an explicitly supplied trace,
not a program that plays those rounds. Expect first total 4 and secured 4,
then a new round total of 0 with secured still 4. The supplied bust total is 11,
its award is 0, and secured stays 4. A key finishes the trace.

`BR_BANKED` stores points already secured. `BR_TOTAL` stores this round's total;
`BR_AWARD` is what that finished round contributes. The assignment
`BR_BANKED=BR_BANKED+BR_AWARD` adds the contribution to the old secured score.
Resetting BR_TOTAL does not reset BR_BANKED: each name stores its own value.
The bust total remains 11 while its award becomes zero. Do not make the display
lie about the roll by resetting the total to zero to represent a lost award.

**Predict:** What survives if a later round rolls 6 then 5? Its total is 11,
award zero, and the earlier secured 4 remains. Only the next round's setup
clears the current total. This distinction will matter in the live session.

## Give the repeated input block a name

The opening's one-round program contains the same fresh-key work in active
play and before leaving its result. Run [read-fresh.amos](read-fresh.amos).
It still plays just one round. Its rules, die, text and accepted controls are
unchanged; it names that repeated input work.

In the opening source, replace each complete input block, from
`If BR_LASTSC>=0` through `BR_LASTSC=Scancode`, with:

```text
Gosub BR_READ_FRESH
```

Indent the active-play call with the surrounding loop. After the drawing
routine's final Return, add `BR_READ_FRESH:` followed by one unindented copy of
the removed block, then a final `Return`. The complete file shows both calls
and the new routine. End still prevents ordinary execution falling into labels.

A Gosub visits the labelled block and Return resumes after that particular call.
This routine reads BR_LASTSC to require release of the earlier key, clears
buffered repeats, waits for a new character, and changes BR_K$ and BR_LASTSC.
It does not roll, redraw, award points or decide what a key means. The caller
inspects BR_K$ after the routine returns. The scan value stays available for
its next call. No new input algorithm is hidden behind the name.

Check B and X at zero, roll once, bank, and finish with a fresh key. A supplied
roll of 4 makes comparison repeatable: replace only `BR_FACE=Rnd(5)+1` with
`BR_FACE=4` in both versions. Restore the random supplier afterwards. The native
record compares the same game pictures before and after extracting the routine.

## Start another round before adding a session score

Run [next-round.amos](next-round.amos). It is round practice: finish a round,
read its total and award, then press Space for another. Q leaves. There is no
secured session score, round limit or target yet. Banking a small amount forever
is practice, not the finished challenge's decision pressure.

The existing round setup and play loop now sit inside another Repeat block.
On each visit, total, last roll, award and finished flag reset; the initial
message returns. After the result, another input loop accepts Space or Q.
`Until BR_K$="Q"` ends the outer practice loop only for Q. An active-play Q
still restores the pointer and ends immediately, as in the opening.

The result display reads stored values without changing them. It remains visible
while a key is held or an unrelated key is received. Space starts a clean round,
not another roll in the finished round. BR_LASTSC is deliberately retained so
holding Space cannot carry its buffered repeats into the new prompt.

The display places the round message on text row 14 and controls on row 17,
below the die. This reuses Locate from the opening; it keeps longer labels away
from the picture. Cls clears pixels and Locate 0,0 resets each text redraw.
The die routine and input routine retain the contracts already explained.

## Add each award once

[award-once.amos](award-once.amos) adds a secured score to that practice loop.
Add `BR_BANKED=0` before the **outer** Repeat. Immediately after the **inner**
`Until BR_HANDFIN`, add:

```text
BR_BANKED=BR_BANKED+BR_AWARD
```

Add `Print "Secured: ";BR_BANKED` after the active last-roll line and after
the result last-roll line. The complete file includes both display edits.
Those are the changes from next-round. Initialising BR_BANKED inside the outer
Repeat would erase earlier rounds. Updating it inside a key-wait or display
loop would award the same result more than once.

For a supplied check, use `BR_FACE=4`. Roll once and bank: total 4, round award
4, secured 4. Wait, hold B, or press X: secured stays 4. Space begins the next
round at total 0 with secured still 4. Three new rolls of 4 produce total 12,
award 0 and secured 4. The total and the award have different jobs. Restore the
random supplier for ordinary practice.

**Repair:** A result adds points while we wait. Inspect where the secured-score
assignment sits. It belongs after the round finishes and before waiting, not
beside a Print or inside BR_READ_FRESH. Move it back, then check banking, waiting,
an invalid key, a new round and a bust. Checking one bank alone misses the fault.

## Count completed rounds

[count-rounds.amos](count-rounds.amos) bounds practice at five completed rounds.
It adds `BR_MAXTURN=5` as a setting and `BR_DONE=0` beside the session score's
initialisation, before the outer Repeat. Immediately after adding the award,
add `BR_DONE=BR_DONE+1`. This records a finished round, including a bust;
a roll, ignored key or redraw is not a completed round.

The active display shows completed rounds and the maximum. During the first
round, zero rounds have finished; its result advances that count to one. The result also
shows `BR_MAXTURN-BR_DONE`, the opportunities left. After two completed rounds,
that is `5-2=3`. Read this subtraction separately from the secured score.

The continuation decision now asks `If BR_DONE<BR_MAXTURN`. If true, the familiar
Space/Q loop can start another round. Otherwise the footer says all five rounds
are complete and accepts Q to leave. The outer loop ends when the maximum is
reached or Q is chosen. Read those branches in the complete source before
changing them. There is still no target or early impossibility rule.

With the supplied roll 4, bank once in each of five rounds. Expect secured
4, 8, 12, 16 and 20 while completed rounds advance 1 through 5. After the second
result, three opportunities remain. The fifth result offers no sixth round.
A bust also advances the count once even though it contributes zero points.

## Stop when the target is reached

[recognise-success.amos](recognise-success.amos) adds `BR_GOAL=30` and a session
result value, `BR_SESSIONFIN=0`, at session initialisation. Zero means success
has not been recorded; 1 means success. At this intermediate step the five-round
counter can also end a missed challenge while this result value stays zero.

After adding the award and counting the round, this block recognises success:

```text
If BR_BANKED>=BR_GOAL
   BR_SESSIONFIN=1
   BR_MSG$="Target reached. You made it!"
End If
```

`>=` admits equality as well as exceeding the target. The continuation decision
now requires **both** another allowed round and no session ending:
`BR_DONE<BR_MAXTURN And BR_SESSIONFIN=0`. And combines those conditions. The outer
round loop can also finish when the session result is nonzero. At an ending,
the footer accepts Q rather than another round. If all five rounds finish below
30, this intermediate version reports the missed target; it has no early
impossibility test yet.

Inside the structured continuation branch, use another If/Else/End If to choose
the terminal wording. AMOS does not allow the earlier single-line If/Then form
inside a structured test. The native check reports `No THEN in a structured
test.` for that mixture. This is a syntax restriction, not a scoring rule.

Use supplied roll 5. Two fresh rolls make a perfect round of 10; repeat for
three rounds. Expect secured 30, completed 3 and two **unused** rounds, then
success. Those opportunities are unused because the challenge is over. Waiting,
R, Space or X must not roll, award again or offer round 4. Restore the supplier.

## Stop when the target cannot be reached

In [recognise-impossibility.amos](recognise-impossibility.amos), add this Else
branch before the success block's final End If:

```text
Else
   If BR_BANKED+BR_CAP*(BR_MAXTURN-BR_DONE)<BR_GOAL
      BR_SESSIONFIN=-1
      BR_MSG$="Target out of reach this time."
   End If
```

Success is checked first. Otherwise, imagine every remaining round earns the
maximum 10. Add that best possible future contribution to the secured score.
If even this upper bound is below 30, continuing cannot reach the target.
Parentheses calculate remaining rounds before multiplication. The result value
-1 now means failure, 1 success, and 0 still playing. Testing `<>0` means either
ending; the printed message explains which one.

With supplied roll 6, two rolls bust each round at total 12. After two opening
busts, secured is 0 and three rounds remain: `0+10*3=30`. Equality is still
possible, so the test must use `<`, not `<=`. Space must still offer round 3.
After the third bust, only two opportunities remain and the upper bound is 20.
Expect failure in round 3 with secured 0, total 12, award 0 and two unused rounds.
No fourth round should be offered. Recheck three perfect rounds as the success
case; adding failure must not break equality success.

**Explain:** We banked 4 and then busted. Does losing the round erase the 4?
No: the bust's award is zero and the session score is the previous score plus
zero. The completed-round count still increases because that opportunity was
used. Reset only the round values before continuing.

## Start the challenge again

[replay.amos](replay.amos) adds one outer application loop. The initial settings,
random seed and BR_LASTSC stay outside it. The session's initial assignments
move inside it: secured score 0, completed rounds 0 and session result 0.
The inner round setup still resets total, last roll, award, finished flag and
message at the start of each round.

When the round loop ends without Q, the footer offers A for a new challenge or
Q to quit. Its Repeat/Until accepts only those letters. A goes around the outer
application loop; Q leaves it. Between-round Q also leaves the application, and
active-play Q still ends immediately. The complete source shows the placement
of all three loops; do not add another score update at this new boundary.

Keep BR_LASTSC across replay. If A is held, BR_READ_FRESH must still wait for
its release before accepting the new round's key. Resetting every variable
indiscriminately would discard that information. The score and round values
reset; the input handover retains the previous key's scan code on purpose.
The random generator also continues its sequence; replay does not promise the
same random rolls. A constant supplied roll is a separate repeatable test.

Run both a success and an early failure. Hold A for 90 frames at the ready
ending prompt. Expect exactly one fresh challenge: secured 0, completed 0,
total 0, last roll 0 and an empty die. Release, then roll once: expect one roll,
not a carried-over action. Quit from active play, a between-round result and
both endings. Native checks qualify those named windows, not every possible
arrival time before a prompt becomes ready.

## Save and independently reopen this source

Use the [opening Save As route](../opening/README.md#keep-that-edit), now saving
`session.amos`. Allow pending guest disk writes to finish, export to a new image
and verify its filesystem before closing the edited session. A fresh AMOS boot
must Load that saved program, run, roll, bank, continue and quit. Loading the
ASCII source or a running snapshot does not test the native saved program.
The session audit retains an early export with unfinished disk bookkeeping as
well as the verified export; it does not treat the closed requester as proof.

## Connect presentation without hiding a new loop

The existing [board and sound checkpoints](../README.md) can now refer to values
and events whose jobs have been explained. Their maintained endpoint uses a
one-based `For BR_TURNNO=1 To BR_MAXTURN` loop; these session steps use an explicit
completed-round counter. They are different representations, not interchangeable
variable names. During active play the current round is BR_DONE+1; after its
award, the just-completed round is BR_DONE. Do not globally rename BR_DONE to
BR_TURNNO and expect the display and remaining-round calculation to agree.

The [presentation guide](../presentation/README.md) adapts the board to this
explicit counter. It extracts the shared display, groups the values, adds each
sound cue and introduces a ready screen in separate complete sources. It keeps
the session loops and fresh-key routine. Use that route to continue; the older
For-based endpoint is an alternative implementation.

These sources reach the accepted 10/5/30 challenge with a die and replay; they
do not add new game mechanics or replace public lessons. Human understanding
still needs a learner trial, and native sound preference still needs human
listening review.
