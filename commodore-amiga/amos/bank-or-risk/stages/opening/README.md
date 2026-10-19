# From a message to one round

Bank-or-risk asks you to secure points or risk another roll. A total over 10
loses that round; exactly 10 banks automatically. The finished challenge gives
you five rounds to reach 30. These checkpoints build the smaller pieces through
one playable round. The round has no target or session score yet, so it does not
have the full challenge's pressure to keep taking risks.

These are complete ASCII programs and authoring notes for the agreed teaching
map, not published replacement lessons. The
[first lesson pair](https://github.com/code198x/docs/tree/amiga-course-and-tooling-briefs/platforms/commodore-amiga/games/bank-or-risk/lesson-drafts)
is a separate beginner-facing review draft: type and change the message, then
save it on a data disk and reopen it from a fresh AMOS session. It does not
replace the checked authoring route below or establish a learner-trial result.

Start each file in a blank AMOS Professional editor project. Use **Merge ASCII** (Amiga+Shift+M), select the
file's `.asc` copy on your work disk, F2 to check syntax, and F1 to run. Merging
into an existing listing adds to it. Replace the whole listing when moving to
a separately named checkpoint unless an edit below says otherwise.

An on-screen End prompt is not the editor. Allow it to appear, then press
Return. Ctrl+C interrupts a running experiment; Return at its prompt takes you
back to editing. Keep a writable work disk available. Original installation
media and an emulator snapshot are not substitutes for saving your program.
The [native audit](https://github.com/code198x/docs/tree/amiga-course-and-tooling-briefs/audit/2026-10-amos-bank-or-risk-opening)
records the exact tested environment and each observed result.

## Put the challenge on screen

Run [message.amos](message.amos). Expect BANK OR RISK followed by a sentence
about banking or risking another roll. `Cls 0` clears the screen using colour
entry 0. `Print` displays the text between double quotes, then moves to the next
line. Instructions execute from top to bottom. `Wait Key` leaves the words
visible until a key is pressed; `End` finishes the program. The initial
text uses AMOS’s existing display colours. The later drawing step defines an
explicit palette; there is no unexplained colour setup to enter here.

Replace only the second Print line with:

```text
Print "Can you secure 30 points?"
```

Run again. The title stays the same and the second line changes. The complete
changed program is [edited-message.amos](edited-message.amos).

For the repair exercise, replace the title's `Print` with `Prit`, then check
with F2. Expect an error at that line. Restore `Print` and check again before
running. The native audit retains the failing and repaired checks.

A missing final quote is different: the checked Merge ASCII route supplies it
automatically and reports No errors. Inspect the imported listing. Do not
promise a missing-quote error that this editor repairs before the syntax check.

## Keep that edit

With the changed listing in the editor, use **Save As** (Amiga+Shift+S) and
choose a new filename, `welcome.amos`, on the writable work disk. This produces
a native tokenised AMOS program. The `.asc` file you merged is readable text;
saving does not turn that original file into the native program.

Export the modified work disk to a new disk-image file if using the checked
Emu198x route. Guest writes stay in emulator memory until exported. The audit
uses its `save_disk` tool and records the sidecar output name. Let guest disk
activity finish before exporting. In that tool route, validate the exported
filesystem before closing the edited session: the check confirms that file
contents and the disk's bookkeeping agree. A closed Save As requester alone
does not establish this. If validation fails, preserve the edited session,
allow pending writes to finish and export again to a new path. Keep the verified
export.
Then end the session, start AMOS from the exported work disk and use **Load**
(Amiga+L) to open `welcome.amos`. F2 and F1 should show the changed question.
Loading the old ASCII source or restoring the edited session would not check
whether your saved edit survived. If the disk is write-protected, use a verified
writable work disk; preserve your listing while correcting the storage setup.

**Predict:** Which sentence should the reopened program show? The changed
question. If the original sentence appears, inspect the saved filename and the
file you loaded before changing the program again.

## Change a drawing colour

First follow [the fixed die instructions](../README.md#run-the-fixed-picture).
That program introduces hiding the pointer, text-cursor control, the palette,
text colours, drawing colours and pixel coordinates before this variation uses
them. Run the fixed picture before editing it.

In `fixed-die.amos`, replace `Palette $000,$FFF` with
`Palette $000,$FFF,$F80`. Add `Ink 2` immediately before the central pip's
`Bar 262,70 To 266,74`. The complete result is
[die-colours.amos](die-colours.amos). Expect white text and outline with an
orange pip on black. The new entry is number 2 because entries start at 0.
The three hex digits specify red, green and blue strength: F, 8 and 0.

`Palette` defines the entries; `Ink` chooses which entry drawing uses. The pip's
position is unchanged. Change only `Ink 2` back to `Ink 1`: the pip becomes white
without moving. Restore 2, then change `$F80` to `$0FF`: the pip becomes cyan,
while the outline and text keep entry 1. Restore `$F80` after comparing.
Colour is an optional presentation difference here; the square's shape still
identifies the pip.

## Choose one roll

Run [one-roll.amos](one-roll.amos). Press a key at its prompt; expect one number
from 1 through 6. Another key finishes. The familiar display setup keeps the
screen black with white text. `BR_FACE` names the stored roll. The `BR_` prefix
keeps our identifiers distinct from AMOS command words. It does not create a
special kind of variable.

`BR_FACE=Rnd(5)+1` first obtains a whole number in 0–5, then adds one. The endpoint
calculation maps 0 to 1 and 5 to 6. `Randomize Timer` selects the generator's
starting state using the clock after your first key press. That varies ordinary
play; it is not evidence of fairness or a promise of different results on every
run. `Clear Key` before the final Wait Key discards buffered characters from the
first choice so the result can be read.

For a supplied-value version, replace the whole roll assignment with
`BR_FACE=4`. Expect 4 each time. Then try 1 and 6. Restore the random assignment
for ordinary play. Neither supplied endpoint proves what Rnd itself generates.
The [original Maths chapter](https://amospromanual.dev/05-03-maths.html#rnd)
defines the inclusive bound; the audit distinguishes source authority from its
finite observations. No DATA table or test harness is required by this exercise.

## Use the old total to make a new one

Run [running-total.amos](running-total.amos). It deliberately supplies an old
total of 4 and a roll of 3. Expect three labelled values: old total 4, roll 3,
new total 7. This is a trace of addition, not a random round.

In `BR_TOTAL=BR_TOTAL+BR_FACE`, AMOS evaluates the right side using the old stored
values, then assigns that result to the name on the left. The equals sign here
means assignment, not a claim that a number equals itself plus three forever.
The semicolon after a Print label puts the following value on that same line.

Change only `BR_FACE=3` to `BR_FACE=6`. Predict 10, then run and compare.
Restore 3. Do not replace the update with `BR_TOTAL=BR_FACE`: that would discard
the earlier four points. Check the old total and the roll separately when
explaining why the answer changed.

## Decide what the total means

Run [total-meaning.amos](total-meaning.amos). The supplied total is 9 and the
limit is 10: expect Still at risk. Replace only `BR_TOTAL=9` with
`BR_TOTAL=10`, then 11 in separate runs. Expect Perfect at 10 and Bust at 11.
Restore 9 before moving on.

`If condition Then instruction` runs its instruction only when that comparison
is true. `<` means below, `=` compares equality in this condition, and `>` means
above. These three tests divide the supplied totals into distinct cases.
Assignment and comparison both use `=`, but their positions give them different
jobs. The number is still shown even when the round would award zero.

**Repair:** if 10 is called a bust, inspect whether the bust test says `>=`
instead of `>`. Checking only 11 cannot reveal that mistake. Recheck 9, 10 and
11 after the repair. This program classifies a supplied total; it does not yet
read choices or update a score.

Now follow [the supplied-face program](../README.md#select-a-supplied-face).
Its six decisions connect a stored number to pips. Explain each case and the
clearing rectangle before the later round reuses that drawing.

## Read one choice before repeating it

Run [one-choice.amos](one-choice.amos) and press R, B or Q. Expect the key and
its requested action. Try X in a separate run: no action message appears and no
score changes. A further key finishes the program. Q is only reported in this
experiment; it is not yet connected to leaving a game.

`Input$(1)` waits for one character without requiring Return.
`BR_K$` stores text; the trailing `$` distinguishes it from numeric values.
`Upper$` normalises letters so lower-case r and upper-case R select the same
branch. Each If compares that stored text with a quoted letter. `Clear Key`
removes earlier buffered characters at entry and before the finish prompt.
The [Keyboard chapter](https://amospromanual.dev/10-01-using-the-keyboard.html)
defines the blocking input and buffer commands.

Replace the listing with [ask-again.amos](ask-again.amos). `Repeat` begins a
block and `Until BR_K$="Q"` tests its exit at the bottom. At least one input is
therefore read. The experiment prints every received character; Q exits and
other keys ask again. Waiting does not change any score: there is no scoring
assignment. Hold R long enough to expose repeated buffered key events. A loop
that reads characters has not yet defined one action per fresh physical press.

## Give a held key one action

[fresh-choice.amos](fresh-choice.amos) replaces the blocking character read with
an explicit input contract. R increases a visible count of accepted presses;
Q leaves. This count measures the experiment's input, not a game score.

`BR_LASTSC=-1` initially says there is no earlier key to release. On later
iterations, `Key State(BR_LASTSC)=0` waits until the previously accepted physical
key is up. `Clear Key` then discards buffered repeats. `Inkey$` returns text
already waiting, or an empty string when nothing has arrived. The inner
Repeat/Until keeps checking until it receives text. `Wait Vbl` yields until the
next display frame, rather than spinning continuously while waiting.
`Scancode` records which physical key produced the accepted character.

The outer loop still leaves on Q. `BR_COUNT=BR_COUNT+1` changes the count only
for an accepted R. `Locate 0,3` returns text output to column 0, row 3 so the
current count replaces the old display. Text positions are different from the
pixel positions used by the die.

Hold R: expect one accepted action in the checked window. Release, then press R
again: expect two. Press X: the count stays two. Release X before Q. The native
record states its tested hold/release windows; input arriving before a prompt
is ready can be discarded by Clear Key. This is a turn-based fresh-choice
policy, not continuous movement input. Do not remove just the release wait and
claim the same contract still holds.

## Connect one round

Run [one-round.amos](one-round.amos). It combines the already introduced total,
comparisons, fresh input and die selection. It adds a round award and a finished
flag. The complete five-round challenge is still a later step.

Read the initial assignments before the loop: cap 10, total 0, last roll 0,
award 0 and finished flag 0. A flag records whether something has happened;
AMOS uses 0 for false and -1 for true here. The message is a text value.
Randomize Timer prepares ordinary rolls. No session score is declared.

The loop clears the pixels with Cls and resets text output to column 0, row 0
with `Locate 0,0` before printing. Clearing alone does not put the next Print
back at the top: without Locate, repeated prompts drift down. The result
display also resets its text position. It then reads one fresh choice.
Q restores the pointer with Show and ends. R chooses a roll, stores it for the
picture and adds it to the total. A total above 10 finishes with award 0;
exactly 10 finishes with award equal to the total. B finishes with that total
only after at least one roll. At zero, B leaves the opening instruction visible.
Unrelated keys do not enter either action block.

The multiline `If` blocks end with `End If`; indentation shows which work each
decision controls. `Until BR_HANDFIN` leaves the round loop once its finished
flag is true. A bust preserves the total and last face while awarding zero.
The result display performs no further scoring and waits for a fresh key.
Thus a held final roll cannot immediately dismiss its own result.

The die is drawn in both active and result displays. That repetition now gives
a routine a purpose: `Gosub BR_DRAW_DIE` visits its labelled block, and Return
comes back to the instruction after the call. Its input is BR_LASTROLL; it
changes only the die rectangle, not the total, award or key. The pip branches
are the supplied-face drawing already explained. Zero draws an empty outline.
End before the label prevents ordinary execution falling into the routine.

Try B before rolling, then X: total and award stay zero. Roll once and bank:
the award matches that roll. For repeatable boundary checks, replace only
`BR_FACE=Rnd(5)+1` with `BR_FACE=5`: two fresh R presses reach exactly 10 and
finish automatically. With `BR_FACE=6`, two presses show total 12, last roll 6
and award 0. Restore the random assignment afterwards. These deliberate
suppliers are not hidden random results and do not require DATA or a generator.

This round is a useful checkpoint, not the finished game's challenge. Continue
with the [session checkpoints](../session/README.md) for keeping secured points,
awarding once, counting completed rounds, testing the target and impossibility,
and replaying. Those complete sources separate next-round continuation from
scoring. The presentation join still needs its own teaching step and native
checks. Human beginner understanding still needs a trial.
