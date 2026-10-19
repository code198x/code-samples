# Give the challenge its board and sounds

The result is the same five-round challenge, with labelled spaces for secured
points and the current round, a die showing the last roll, and a short sound
for each result. `ready-screen.amos` is the complete version reached here.
It still uses the session guide's completed-round counter and fresh-key routine.

Start from [replay.amos](../session/replay.amos). The
[session guide](../session/README.md) explains its score, rounds, endings and
replay. For each checkpoint below, keep a working copy before editing, check
with F2 and run with F1. Each `.amos` file is also a complete ASCII source:
merge its `.asc` copy into a blank project using the
[opening guide's route](../opening/README.md).
The file extension does not turn ASCII into a native saved AMOS program.

These are authoring checkpoints, with the answers included. Their native checks
are recorded in the [presentation audit](https://github.com/code198x/docs/tree/amiga-course-and-tooling-briefs/audit/2026-10-amos-bank-or-risk-presentation).
They do not establish how an uncoached beginner will learn from the eventual
lessons.

## Draw the stored state in one place

`shared-display.amos` extracts the two display blocks from `replay.amos`.
Previously, active play and the result each cleared the screen, printed the
values and drew the die. Moving those instructions gives us one place to change
the layout without moving the rules or input.

Replace the active display, from its `Cls 0` through `Print BR_MSG$`, with
`Gosub BR_DRAW_STATE`. Keep its `Locate 0,17` and controls after the call.
Replace the result display, from its `Cls 0` through `Print BR_MSG$`, with the
same call. Keep the result's `Locate 0,17` and following decisions in place.

Add `BR_DRAW_STATE:` before `BR_READ_FRESH:`. Its `If BR_HANDFIN` selects the
old result block; its Else selects the old active block. Each branch contains
those original display instructions, followed by `End If` and `Return`.
The complete source shows both blocks in their new home. `Gosub` visits the
label; `Return` resumes at the caller's next instruction. Execution normally
ends above the labels, so it does not fall into a routine by accident.

The routine reads the total, award, secured score, completed count, settings,
last roll, round/session flags and message. It clears and draws the screen;
it calls the existing die routine. It does not change a score, choose a face,
read a key or decide when the round ends. The caller still prints the controls
and decides which choices to accept.

**Predict:** After banking 4, will waiting at the result add another 4?
No. The award assignment remains before this call, outside the drawing routine.
Run with a supplied roll of 4, bank, wait and try X. Secured remains 4. Space
starts with total 0, secured 4 and an empty die. The extraction should produce
the same pictures as the earlier source for the same choices.

## Group the values by their jobs

Before `grouped-board.amos`, run the explained
[round and challenge board snapshots](../README.md#give-this-round-its-own-space).
They supply values so we can investigate layout without playing those rounds.
Keep their pixel coordinates and text positions distinct: `Box` uses pixels;
`Locate` uses text columns and rows.

Replace only `BR_DRAW_STATE` with the grouped version. Change the three control
positions in the main program from `Locate 0,17` to `Locate 1,21`. The new display
uses row 17 for the explanation and row 21 for controls. Moving just the boxes
would leave controls printed through the explanation. Scoring, input and the
die routine are unchanged.

The upper box shows secured score, target and **completed** rounds. The lower
box shows the current total, limit and either its award or the at-risk message.
The last-roll number stays beside the die. A bust can therefore show total 12,
award 0 and secured 4 without confusing those three values.

This adapts the older supplied board's counter. There, `BR_TURNNO` names the
current round, starting at 1. Here, `BR_DONE` counts finished rounds, starting at
0. They differ during play and agree just after a round finishes:

| Moment | Completed (`BR_DONE`) | Current round in the older board | Opportunities after this round |
| --- | --- | --- | --- |
| Before the first roll | 0 | 1 | 4 |
| Playing the second round | 1 | 2 | 3 |
| Reading the second result | 2 | 2 | 3 |
| Success after the third result | 3 | 3 | 2 unused |

During active play, `BR_MAXTURN-BR_DONE-1` excludes the unfinished current round.
At a result, `BR_MAXTURN-BR_DONE` counts the opportunities still available.
The renderer chooses between them with `BR_HANDFIN`. At an ending it says
**Unused rounds**. That label describes capacity left when play has stopped;
it does not invite another round. The completion increment and impossibility
test remain where the session guide put them.

**Repair:** The first active screen says five rounds after this one. What is
wrong? It used the result calculation before the current round had finished.
Subtract one more in the active display branch. Do not change `BR_DONE` to 1:
that would spend an opportunity before playing it. Check the initial screen,
second active round, second result and a third-round ending.

Each `Box` follows the supplied snapshot coordinates. Text occupies at most 40
columns. The renderer clears the whole board, draws the values, then returns to
the caller for the phase's controls. Changing its wording needs another native
layout check; wrapping text can write into the next region.

## Sound a result once

First run and vary the explained [short tone](../README.md#hear-one-short-tone).
Its sine wave, overall level, pitch and envelope are the sound we reuse here.
`Play` with a zero second argument starts playback and lets instructions
continue; the envelope fades the sound without a blocking pause.

`bank-cue.amos` adds that exact setup after `Pen 1`. Copy from `Play Off` through
the seven `Set Envel` instructions. Add `Play Off` just inside the outer replay
loop, before the active-Q `Show`, and before the final `Show`. A new challenge
or exit stops any remaining sound.

Add `Gosub BR_SOUND_RESULT` immediately before the result's
`Gosub BR_DRAW_STATE`, after the award, completed count and session decision.
Append this routine after the die routine:

```text
BR_SOUND_RESULT:
If BR_AWARD>0 Then Play 49,0
Return
```

A chosen bank or automatic perfect bank now produces one tone. Waiting,
pressing X or holding B does not call this routine again. B before any roll
still completes no round and produces no cue. A bust is silent at this step;
success uses the ordinary bank tone.

`bust-cue.amos` changes only that routine:

```text
BR_SOUND_RESULT:
If BR_AWARD=0
   Play 25,0
Else
   Play 49,0
End If
Return
```

This call follows a completed round, where a zero award means a bust. It is not
a general rule that every zero value should sound. The lower pitch identifies
this event; the visible message and zero award explain it with sound off.

`success-cue.amos` changes only the same routine again:

```text
BR_SOUND_RESULT:
If BR_SESSIONFIN=1
   Play 61,0
Else
   If BR_AWARD=0
      Play 25,0
   Else
      Play 49,0
   End If
End If
Return
```

Success replaces the final bank cue. Three supplied perfect rounds give two
bank tones and one higher success tone. Three opening busts give three low
tones and an out-of-reach message; there is no extra failure cue. The session
decision must run before sound selection so the last bank can be recognised as
success.

**Repair:** A tone repeats while the result stays on screen. Inspect the call's
location. Keep it beside the once-only award transition, outside the renderer
and input loop. Drawing and asking again are allowed to repeat without a new
result. Test held B, waiting, X and a next-round choice, not just one bank.

With `Volume 0`, the same numbers, pips, messages and controls must explain the
whole game. Restore 24 afterwards. These sources reuse the established sound
settings; listening preference still needs human feedback.

## Explain the challenge before starting

`ready-screen.amos` adds a ready screen immediately before `Randomize Timer`.
Copy its block from `Cls 0` through the matching `End If`: title, 30-point/five-round
goal, die range, bust and exact-limit rules, then Space/Q controls.

Its small Repeat calls the existing fresh-key routine until Space or Q. Q stops
sound, restores the pointer and ends the program. Space continues to the seed
and session initialisation. The game loops and score updates below do not
change. The previous scan code stays intact, so holding Space cannot also
advance through the first round. A or R at the ready screen does not start it.

Replay with A returns directly to the empty challenge, ready to roll. It does
not revisit the instructions or reseed the generator. Q works at the ready
screen, during a round, between rounds and at either ending.

## Check and keep the integrated program

For a repeatable investigation, change only `BR_FACE=Rnd(5)+1` to
`BR_FACE=5`. Each R supplies 5; two fresh R presses make a perfect 10.
Three such rounds reach 30 at completed 3, with two unused rounds. Restore the
random supplier afterwards. With supplied 6, two rolls bust at 12. Two opening
busts still leave a possible 30; three leave at most 20 and end the challenge.
These are test versions, not evidence about random outcomes.

Check active/result labels, held and unrelated controls, replay and fresh input
again after joining the presentation. Save the native program using the
[opening persistence route](../opening/README.md). Let disk writes finish,
export to a new file and validate the filesystem before closing the edited
session. Cold-boot that disk, Load the saved program, and run it. An emulator
snapshot is useful during testing but does not prove native saving and loading.

This route keeps the session's `BR_DONE` model throughout. The older
[prototype](../../prototype/bank-or-risk.amos) and top-level cue samples use a
For loop and `BR_TURNNO`; their earlier audits still identify those sources.
They are alternative implementations, not the next file a learner must copy.
Use this folder's `ready-screen.amos` as the endpoint for the continuous
opening → session → presentation teaching route.


The [replay-value extension](../replay-value/README.md) then changes the game to
finish all five rounds, keep a personal best, show its five awards and offer one
rescue. It introduces each change separately and retains this version as the
working earlier stage.
