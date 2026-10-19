# Draw a die, then match its face

Begin with the [message-to-one-round route](opening/README.md) if you are new to
AMOS. These are two small AMOS programs from the bank-or-risk opening. The first draws
one fixed pip. The second draws a supplied number from 1 to 6. Neither rolls a
random die or plays a game. The [prototype](../prototype/README.md) connects the
picture to the stored roll without adding rules.

## Run the fixed picture

Put `fixed-die.amos` on your work disk as `fixed.asc`. It is ASCII source: use
AMOS **Merge ASCII** (Amiga+Shift+M), select that file, then F2 to check syntax
and F1 to run. Start with a blank editor project; merging into another program
adds the source to it. The [native record](https://github.com/code198x/docs/tree/amiga-course-and-tooling-briefs/audit/2026-10-amos-bank-or-risk-die)
records the checked AMOS configuration. A key finishes; Return completes the
return to the editor in that configuration. Allow the screen transition to end.

Expect the words DRAW A DIE, an outlined die on the right and one central square
pip. The source uses a black background and white text and drawing. `Palette`
sets colour entries; `Paper 0` and `Pen 1` select entries for text, while `Ink 1`
selects entry 1 for drawing. `$000` is black and `$FFF` is white. Each hex digit
sets the strength of red, green or blue from 0 to F (decimal 15).

`Box 240,48 To 288,96` draws an outline from the top-left pixel to the bottom-right
pixel. Moving right increases x; moving down increases y. These are pixel
positions, separate from the text columns and rows used by `Locate`.
`Bar 262,70 To 266,74` fills a small rectangle: the central pip. Instructions run
in order, so the outline is drawn before the pip. `Wait Key` leaves the picture
visible until a key is pressed. `Hide`/`Show` hide and restore the mouse pointer;
`Curs Off` hides the text cursor; `End` finishes the program.

**Predict, then try:** change only the pip's x coordinates from 262 and 266 to
248 and 252. Which way will it move? It moves left by 14 pixels; the die outline
stays where it was. Restore those two numbers before continuing.

## Select a supplied face

Open a blank project and merge `match-die.amos` as `match.asc`. Check and run it.
The printed supplied face and pip count should both be 1. Change just
`BR_FACE=1` to `BR_FACE=2`, run again, then try 3, 4, 5 and 6. These are supplied
test values, not random results. Leave the value within 1–6 for this exercise.

Each `If BR_FACE=...` block asks whether the stored value equals that number.
Only its matching block draws pips. `End If` ends that decision. The `BR_` prefix
keeps the name distinct from AMOS command words. Each pip uses the same small
filled rectangle; the coordinates choose its position. No array or hidden
renderer supplies the picture.

| Supplied face | Pip positions |
| --- | --- |
| 1 | Centre |
| 2 | Top left, bottom right |
| 3 | Top left, centre, bottom right |
| 4 | All four corners |
| 5 | All four corners and centre |
| 6 | Left and right columns, three pips each |

Before drawing, `Ink 0` and `Bar 240,48 To 288,96` clear just the die rectangle
with black. `Ink 1` restores white for the new outline and pips. In this one-shot
program the area is already black. The same clearing block is useful when the
game draws another face: old pips must disappear without clearing nearby labels.

**Repair:** change the centre pip in the face-5 block to the same coordinates as
its top-left pip. The number remains 5 but only four distinct pips appear.
Restore `Bar 262,70 To 266,74` in that block. Checking the printed number alone
would miss the drawing fault.

## Connect the picture after decisions

The full prototype calls `BR_DRAW_DIE` after printing `BR_LASTROLL`. A `Gosub`
visits the labelled drawing routine; `Return` resumes after the call. Repeated
redrawing gives the routine a purpose. It reads the last roll and draws the
picture; it does not choose a roll, change scores or read a key. The six decisions
are the same as the supplied-face example, using `BR_LASTROLL` instead of
`BR_FACE`. The numeric roll remains visible beside the picture.

Zero means no roll yet. No pip block matches it, leaving an empty outline. A new
round and a replay reset the stored roll to zero; a bank or bust keeps the last
face visible while its result is read. Do not display the previous round's face
as a new roll.

The original AMOS Professional Manual's [Graphics chapter](https://amospromanual.dev/06-04-graphics.html)
defines the coordinate system, `Ink`, `Box`, `Bar` and palette notation. Its
[Keyboard chapter](https://amospromanual.dev/10-01-using-the-keyboard.html)
defines `Wait Key`. These checked fragments are authoring material. The
[opening checkpoints](opening/README.md) supply the earlier message/save and
input route through one round.

The [session checkpoints](session/README.md) develop secured points, completed
rounds, success, impossibility and replay after the one-round opening. They
separate routine extraction and next-round continuation from scoring. The
[presentation bridge](presentation/README.md) continues that route through a
shared display, grouped board, separate event cues and ready screen. It keeps
the completed-round counter. Its endpoint is `presentation/ready-screen.amos`;
the older top-level cue sources below retain their For-based implementation.

## Give this round its own space

`round-board.amos` is a supplied display, not another game. Merge it into a
blank project as `rboard.asc`, check with F2 and run with F1. It shows a total of
4, limit 10 and last roll 4. The words ONE ROUND and the supplied-value message
make its scope visible. It has no session score, target or round count yet.

The box from `0,64` to `223,111` groups this round's values. Its text starts at
column 1 on rows 9, 11 and 12. The existing die stays on the right. A label names
the value next to it: a roll is not the running total. Keep the text inside the
box when you vary a label. `Ink 1` explicitly selects white for its outline;
`Box` draws the border without filling over its contents.

Change only `BR_TOTAL=4` to `BR_TOTAL=7`. The total becomes 7 and the die still
shows 4: changing a total is not a new roll. Restore 4. To show a finished bank
instead, change `BR_HANDFIN=0` to `BR_HANDFIN=-1` and `BR_AWARD=0` to
`BR_AWARD=4`. The round now says it secures 4. In AMOS, -1 is true and 0 is false;
the decision displays either the award or the at-risk explanation. These edits
supply a test state; they do not implement banking input or score updates.

The die routine is the previously explained face selection. The `Gosub` visits
it and `Return` resumes after the call. It reads `BR_LASTROLL`, changes only the
die area and leaves the numbers alone. No new face is chosen while displaying.

## Add the challenge after its values are understood

`challenge-board.amos`, merged as `cboard.asc` in a blank project, supplies the
bust after banking 4 in round 1, then rolling 6 and 5 in round 2. Expect this:

- Secured 4 and target 30 in the upper box; round 2 of 5.
- Current round total 11, limit 10, this round secured 0 in the lower box.
- Last roll 5 beside five pips; three rounds after this one.
- A bust explanation and a supplied-result prompt. Any key finishes this snapshot.

The supplied assignments describe one moment. They do not play those rounds.
Read them before the call to `BR_DRAW_STATE`, which clears and redraws the whole
board from the stored values. Its `Return` comes back to the supplied-result
prompt. The boxes separate values by their jobs; they do not perform scoring.
The full prototype uses the same display routine with live values.

`BR_MAXTURN-BR_TURNNO` subtracts the current round number from the maximum. In
round 2 of 5 that is 3 later rounds. Counting later rounds keeps the current
round separate. The renderer calculates it from those two values every time;
it does not depend on a remaining-round value last updated after scoring.
At an ending the label changes to **Unused rounds**, because the challenge has
finished even if its maximum allowed more rounds. Success and failure remain
explained by the result text. The display decision does not end the game.

For a supplied perfect result in round 3, change `BR_BANKED=4` to 30,
`BR_TURNNO=2` to 3, `BR_TOTAL=11` to 10, `BR_LASTROLL=5` to 6, `BR_AWARD=0`
to 10, `BR_SESSIONFIN=0` to 1 and the message to `Target reached. You made it!`.
Keep `BR_HANDFIN=-1`. Predict secured 30, round total 10, last roll 6, this round
secured 10 and two unused rounds, then run and compare. Those different numbers
have different jobs; copying one score into every field would hide a fault.

The message box uses pixels `0,128` to `319,151`, with text on row 17. The control
box uses `0,160` to `319,183`, with text on row 21. The supplied snapshot replaces
the live controls with its own finish prompt. In the full game, active play,
between-round results and final results show their appropriate controls.
Keep each line within the 40 text columns; a line that wraps can overwrite the
next part of the board. A later text change needs another native display check.

## Hear one short tone

`short-tone.amos`, merged into a blank project as `short-tone.asc`, is the sound
checkpoint. F2 checks syntax; F1 runs it. Expect one fading tone, then silence
while the text and finish prompt remain. A key finishes the program. This is a
sound experiment for the game, not another scoring rule.

`Play Off` first stops any earlier note. `Wave 1 To 15` selects AMOS's built-in
sine wave for all four sound channels. A channel is one independently controlled
sound output. Their selection values are 1, 2, 4 and 8; adding them gives 15,
which selects all four, including outputs on both sides of the stereo pair.
No sample file or instrument bank is needed. The original manual calls this
selection a bit mask; binary notation is optional here.

Pitch is how high or low a tone sounds; its frequency counts waveform repeats
per second. A Play pitch is a numbered note, not that repetition count.

`Volume 24` sets the overall level, on a scale from 0 (silent) to 63. Start at a
comfortable listening level. `Play 49,0` starts pitch 49 with **zero instruction
delay**: execution continues immediately. The second argument is not the tone's
length. The next Print statements run while the tone is playing.

The seven `Set Envel` lines define how the sine wave's level changes over time.
They describe one sound, not seven notes. Each line names wave 1, a phase from
0 to 6, that phase's duration, and its ending level. Duration units are fiftieths
of a second in the manual; the checked configuration is PAL.

- Phase 0 rises to envelope level 63 over one unit.
- Phase 1 fades to zero over nine units.
- Phases 2–6 each stay at zero for one unit. Setting all of them avoids inheriting
  an old envelope definition.

The envelope's peak is scaled by the overall Volume setting. The first two
phases define about a fifth of a second of sound; the remaining phases are
silent. `Wait Key` keeps the program open after starting the tone; it does
not keep the tone sounding. The final `Play Off` also stops playback if a key
ends the experiment before the fade finishes.

Change one thing at a time, predict, then run:

- Change only `Play 49,0` to `Play 37,0`. The frequency halves (an octave lower); the
  fade is unchanged. Restore 49.
- Change only `Volume 24` to `Volume 12`. It is quieter, with the same pitch and
  fade. Restore 24.
- Change only `Set Envel 1,1 To 9,0` to `Set Envel 1,1 To 18,0`. The downward
  fade lasts longer. Restore 9.
- Change Volume to 0. The program still reaches its text and finish prompt, but
  the tone is silent. Restore 24 before comparing game cues.

These variations have separate native captures in the
[sound record](https://github.com/code198x/docs/tree/amiga-course-and-tooling-briefs/audit/2026-10-amos-bank-or-risk-sound).
Pitch and amplitude measurements establish those changes; they do not judge
which sound a learner will prefer. The original [Music chapter](https://amospromanual.dev/08-01-music.html)
defines Wave, Volume, Play, Play Off and Set Envel.

## Attach banking, then busting, to an event

These later checkpoints assume the once-only round award and session values
are understood. Each file is a complete game with the board and controls already
explained. They add sound in separate edits, rather than supplying a hidden
sound engine. Merge each ASCII file into a blank project as `bank-cue.asc`,
`bust-cue.asc` or `success-cue.asc`; check with F2 and run with F1.

`bank-cue.amos` adds the same setup after `Pen 1`, a call to `BR_SOUND_RESULT`
after the round award and session decision, and the labelled routine at the end:

```text
BR_SOUND_RESULT:
If BR_AWARD>0 Then Play 49,0
Return
```

It also stops sound when a new challenge begins and before returning to the
editor. Run the game, roll once and bank with B. Expect one tone and an unchanged
result while waiting. Holding B, pressing an unrelated key or redrawing must not
award more points or repeat the cue. Exact 10 also banks and uses the same tone.
At this stage, winning still uses the ordinary bank cue.

`bust-cue.amos` changes only that sound routine:

```text
BR_SOUND_RESULT:
If BR_AWARD=0
   Play 25,0
Else
   Play 49,0
End If
Return
```

A bust now uses a lower pitch; a bank keeps pitch 49. The call happens only after
a completed round, so zero here means a bust. B before rolling does not complete
a round and never reaches this call. Do not move it into the redraw routine or
key-reading loop: those can run without a new result. No Wait is added to the
game. The envelope ends the cue while the game can accept the next choice.

## Give success its own cue

`success-cue.amos` is identical to the maintained prototype at this checkpoint.
It adds an outer decision around the bank/bust choices: if `BR_SESSIONFIN=1`,
play pitch 61; otherwise choose the existing bank or bust cue. Success therefore
**replaces** the final bank cue. It does not queue a second tone after it.
The session decision must be computed before this routine is called.

Three perfect rounds should produce two bank tones and one higher success tone.
Three opening busts produce three low bust tones; the final text explains why
the target is out of reach. There is no additional failure cue in this version.
The picture, numbers and wording carry every result with Volume set to 0.

The call is beside the once-only award, not beside a Print statement. Waiting
and invalid keys cause no new sound. A new Play uses the same channels rather
than layering another set of voices. Replay and quit use Play Off to stop any
remaining tail. Those operations never wait for the sound to finish. Native
checks cover the named held-key and immediate-transition windows; they do not
establish every keyboard configuration or subjective sound quality.

## Extend the replay goal

The [replay-value stages](replay-value/README.md) continue after the presentation
bridge: finish all five rounds, retain an in-program personal best, record five
awards, offer one rescue and add a short reveal/target acknowledgement. Their
`feedback.amos` is the extended endpoint. Earlier sources retain the explained
early-ending rules as a working stage; the extension changes those deliberately.
