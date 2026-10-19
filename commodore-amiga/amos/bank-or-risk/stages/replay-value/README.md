# Make another attempt worth playing

The challenge now plays all five rounds. Aim for 30, then keep building a score
to beat next time. Five visible spaces record what each round secured. One
rescue lets you undo a bust; once spent, it is gone until the next challenge.
`feedback.amos` is the complete version reached here.

Start from [ready-screen.amos](../presentation/ready-screen.amos), explained by
the [presentation guide](../presentation/README.md). These five complete sources
keep the limit of 10 and the same fresh-key routine. They add the replay goals
in separate steps. Keep a working copy, check each edit with F2 and run with F1.
For a complete source, merge its ASCII copy into a blank project through the
[opening route](../opening/README.md); Save As creates a native AMOS program.

## Play all five rounds

`five-rounds.amos` changes the session decision after the once-only award and
completed-round increment. Only `BR_DONE=BR_MAXTURN` sets a terminal result.
Then secured points at or above 30 mean success; otherwise the result invites
another attempt. The round's outcome still contributes at most 10.

Before round 5, reaching 30 changes the message to **30 reached. Keep building!**
The upper-bound test still explains when 30 is out of reach, but it changes only
the message. It no longer ends play. Remove the session flag from both loop
conditions: the continuation checks `BR_DONE<BR_MAXTURN`; the round loop ends
on completed 5 or Q. Update the ready screen to explain the full session.

The complete source shows the new decision block between the completion
increment and sound call. It uses nested If/Else/End If blocks; a single-line
If/Then inside a structured test is not accepted by this AMOS dialect.

**Predict:** Three perfect rounds secure 30. What next? Read the result, then
Space begins round 4 with total 0 and secured 30. A bust cannot remove the 30.
After round 5, the final score might exceed 30. Three opening busts likewise
leave two rounds to improve the score, even though 30 is no longer possible.

The earlier early-ending version remains a useful working stage. This is a
deliberate game-design change, not a repair to its probability calculation.

## Keep a best across replays

`personal-best.amos` adds `BR_BEST=0` once, after the seed and before the outer
replay loop. Add `BR_NEWBEST=0` inside that loop. After a completed round, only
if completed equals the maximum, compare secured points with the best. A
strictly greater score replaces the best and sets `BR_NEWBEST=-1`.

The display prints Best alongside the title. At a new record it also prints
**New personal best!** on row 24. The semicolon after that Print matters: it
avoids advancing past the bottom text row and scrolling the board.

The full source places this comparison before the sound and result display.
The renderer reads the result; it never updates the best. A replay resets the
new-record flag and current score, while leaving Best alone.

**Predict:** Finish with 40, replay, then finish with 25. The best stays 40.
A later 40 is a tie, not a new record. A later 41 replaces it. Q during an
unfinished challenge does not enter its partial score as a completed record.

This best lasts while the program is running. Q returns to the editor; running
the program again starts at zero. Saving the program does not save a record
file. Disk records are outside this step.

## Record five different awards

`scorecard.amos` gives the repeated awards a table rather than five separately
named variables. After `BR_MAXTURN` is set, `Dim BR_MARK(BR_MAXTURN)` reserves
numbered entries. AMOS also provides entry 0; this program leaves it unused and
uses entries 1 through 5 to match the completed-round count.

Just inside the replay loop, a For/Next loop sets all five entries to zero:

```text
For BR_SLOT=1 To BR_MAXTURN
   BR_MARK(BR_SLOT)=0
Next BR_SLOT
```

For starts the slot at 1. Next adds one and repeats until it passes the maximum.
This is a counted visit to five storage locations, not a replacement for the
player's round loop. `BR_SLOT` is a working position, not a completed round.

Immediately after `BR_DONE=BR_DONE+1`, store `BR_AWARD` in `BR_MARK(BR_DONE)`.
That ordering makes the first completed award occupy entry 1. Store a bust's
zero too; do not skip its entry or use its displayed total.

The renderer visits the same five entries on row 23. A completed entry prints
its award, the active round prints **?**, and future entries print **-**.
Positions `9+(BR_SLOT-1)*6` place them six text columns apart. The subtraction
makes the first offset zero. Keep five slots within the 40-column screen.

Zero in storage does not mean unplayed. `BR_DONE` tells us which entries have
been completed. After banking 4 and busting, the result shows `4 0 - - -`.
Space then makes the third slot `?`. Their sum must equal the secured score;
the current at-risk total is excluded until banking or automatic completion.

**Repair:** The first award is stored in entry 0 and the display seems one
round behind. Move the store after the completion increment. Do not shift the
drawing loop to conceal the mistaken index. Compare the first bank, a zero
award, the fifth result and a replay with all previous awards cleared.

The original manual's [arrays section](https://amospromanual.dev/05-01-the-bare-bones.html)
defines Dim and zero-based element numbers. Here the deliberate unused zero
keeps the game's round numbers visible in its indices.

## Decide whether to spend the rescue

`rescue.amos` adds `BR_RESCUE=1` at challenge reset. It adds
`BR_RESCUEASK=0` at each round reset. Before choosing a roll, save `BR_TOTAL`
and `BR_LASTROLL` as `BR_BEFORE` and `BR_BEFOREFACE`.

The regular roll and bank block now sits inside the Else of a pending-rescue
decision. Q is still checked before either branch. The complete source shows
that indentation and every matching End If; moving just one If would leave
ordinary banking able to award a bust total.

On a bust with rescue available, set the pending flag and message. Do not yet
set the round-finished flag or change score/completed count. The display keeps
the bust total and roll visible. It explains the choice and prints
**U rescue   B accept bust   Q quit**. The usual bank action is not active here.

- U spends the rescue, clears pending, and restores the pre-roll total and face.
  The round is still active. Bank the restored total or risk another roll.
- B clears pending and finishes the round with award zero. It keeps the rescue
  for a later round.
- R, Space, X and another unrelated key do nothing to the pending state.
- Q abandons the unfinished challenge without awarding or recording this round.

If rescue has already been spent, a later bust finishes with zero immediately.
U has no ordinary-play action; holding it cannot restore another roll. The
fresh-key routine still requires release before accepting another choice.

The display shows Rescue 1 or 0. During a pending bust the current scorecard
slot remains `?`, because no award has been chosen yet. The renderer has a
separate pending explanation instead of claiming those bust points can be banked.

**Trace:** Supply 6 for each roll. Roll twice: total 12, completed 0, secured 0,
rescue 1. U restores total 6 and its previous face, with rescue 0. B then banks
6 once. In the next round, two more sixes bust and record zero immediately.
The secured 6 survives. Replay restores rescue 1 and clears the five awards.

**Repair:** Pressing B at the rescue question banks 12. It has fallen through
into the ordinary bank branch. Keep pending handling and ordinary play on
opposite sides of the If/Else. Only the pending B branch should run there;
it explicitly assigns award 0. Check both U and B, not just undo.

Rescue supplies forgiveness and can encourage a risk before it is spent. Do
not promise every rescue question is a difficult strategic choice. A best-score
goal and the target goal can favour different choices; the mathematical study
is optional, not an instruction to memorise an optimal policy.

## Give a roll and a result clearer feedback

`feedback.amos` adds `Gosub BR_ROLL_PICTURE` after choosing the actual face,
before applying it. The routine briefly draws faces 2, 4 and 6, waiting for two
vertical blanks at each. The caller then assigns the actual face and adds it
to the total once. The preview never calls Rnd or changes secured points.
These are reveal pictures, not three additional rolls.

The original manual's [screen chapter](https://amospromanual.dev/06-02-using-screens.html)
defines Wait Vbl. Six waits give a short reveal on the recorded PAL setup;
drawing and execution add time, so do not describe it as an exact wall-clock
stopwatch. Decisions remain untimed. The existing input handover accepts the
next fresh choice after the reveal; it does not queue choices tapped during it.

The round result now labels its contribution **Saved this round: +** and places
it in the five-round record while the secured total changes above. A bust shows
+0. Nothing is transferred again while drawing the same result.

A new `BR_REACHED` flag resets at each challenge. After an award, set a one-event
`BR_TARGETCUE` when the secured score first reaches 30. Sound selection uses it
for the higher success cue. That cue replaces the bank cue on this event; it
does not repeat on rounds 4 and 5 because the score is still above 30.
Reset the event flag at the next round. The result acknowledges reaching 30;
a final new-record message takes that text row when appropriate.

The usual bank and bust cues remain. Waiting, held keys and rejected input
produce no new result sound. With Volume 0, every score, choice and outcome
still has a visible explanation. No new sample bank or audio dependency is
needed.

## Check the completed challenge

For a repeatable run, replace only `BR_FACE=Rnd(5)+1` with `BR_FACE=5`.
Two fresh rolls make each perfect 10. Play all five: 30 at completed 3 is an
invitation to continue, and the final score is 50. Replay and bank each single
5 to finish at 25; Best remains 50. Repeat the perfect run: 50 is a tie.
Restore the random supplier afterwards.

Use supplied 6 separately to inspect both rescue choices and a later spent-token
bust. A replay restores the token and empty card but keeps Best. Waiting,
invalid keys and held controls must not change score, card, best or token.
Save and independently reopen the final source through the
[checked storage route](../opening/README.md#keep-that-edit). Verify the exported
filesystem before cold boot; a running snapshot is not proof of native saving.

The [execution record](https://github.com/code198x/docs/tree/amiga-course-and-tooling-briefs/audit/2026-10-amos-bank-or-risk-replay-value)
separates prescribed cases, random play, audio measurements and persistence.
These sources implement the agreed extension. Human play/listening feedback,
authored replacement lessons and beginner learning outcomes remain pending.
