# Give the game an arcade board and a visible roll

The new board uses bright colour to separate secured points, points at risk and
the rescue. The five awards have their own row above the controls. A larger die
shakes through changing faces, slows, then settles on its one chosen result.
`rolling-die.amos` is the complete version reached here.

Start from [feedback.amos](../replay-value/feedback.amos), explained by the
[score-chase guide](../replay-value/README.md). The user played that version and
found the game worked well, then requested colour, spacing and a clearer roll.
These three complete sources develop that presentation without changing the
five-round rules, personal best or rescue decisions. Check each with F2 and
run with F1; a complete ASCII copy can be merged through the
[opening route](../opening/README.md).

## Give each colour a job

`arcade-colours.amos` first changes the palette and drawing/text selections while
keeping the existing layout. Add `Flash Off` immediately before Palette, then
replace the original two palette values with:

```text
Palette $112,$FFE,$4FF,$F6B,$FE4,$224,$7F9,$BAD
```

AMOS presets entry 3 to flash, even when the cursor is hidden.
[Flash Off](https://amospromanual.dev/06-03-screen-effects.html#flash-off) stops
that colour animation before we set a stable palette. Otherwise pink text can
cycle through dark colours and become unreadable.

These are entries 0 through 7, in order. Each three-digit hexadecimal value
specifies red, green and blue intensity. The earlier
[palette exercise](../opening/README.md#change-a-drawing-colour) explains that
notation. Here the roles are:

| Entry | Role |
| --- | --- |
| 0 | Dark ink background and dark die pips |
| 1 | Warm white instructions and die face |
| 2 | Cyan secured points and completed awards |
| 3 | Pink title and rescue question |
| 4 | Yellow points at risk, current slot and roll feedback |
| 5 | Dark blue panel surface, used by the next layout stage |
| 6 | Mint rescue availability and a new record |
| 7 | Lavender supporting labels and future slots |

A palette entry defines a colour; Pen selects a text colour, Paper its cell
background, and Ink the colour used by shapes. The complete source places
Pen changes before the relevant text and selects yellow in the die routine.
It restores Pen 1 and Paper 0 before returning from the state renderer, so the
caller does not inherit the last field's colour for its controls.

**Predict:** Change only entry 4. The at-risk total and die outline/pips in
this stage change together; the secured score does not. Restore the palette.
Then change the total's Pen selection: that field can use a different entry
without redefining what the entry means everywhere else.

Every meaning still has a label, value or position. A bust says zero; a pending
rescue asks a question. A colour is never the only explanation. The
[native record](https://github.com/code198x/docs/tree/amiga-course-and-tooling-briefs/audit/2026-10-amos-bank-or-risk-arcade)
includes computed foreground/background contrast and a grayscale comparison.
Those checks do not establish how every display or person perceives the colours.

## Give related values room to breathe

`arcade-layout.amos` replaces the state renderer, ready screen and die routine.
Change the main program's three control positions from `Locate 1,21` to
`Locate 1,23`. The game decisions between those calls remain unchanged.

The board still fits 320×200 pixels and 40×25 text cells. Locate uses text
columns/rows; Bar and Box use pixel coordinates. Keep those two grids distinct.
The complete renderer gives the information this order:

| Region | Placement | Purpose |
| --- | --- | --- |
| Title / Best | Text row 1 | Identify the game and score to beat; NEW BEST names a completed improvement. |
| Secured / Goal | Row 4 | Compare safe points with the target. |
| Completed / Die label | Rows 6 / 5 | Separate progress from the pending roll picture. |
| Round panel | Pixels 8,64 to 215,112 | Total, limit and current award/status belong together. |
| Die | Pixels 248,56 to 304,112 | Leave a clear gap from the round panel. |
| Rescue / accepted last roll | Row 15 | Show resource state and the accepted roll beneath their regions. |
| Result or question | Row 17 | Keep the full explanation above the award slots. |
| Five award slots | Pixels 152–175 vertically | Each round has a labelled place, with a ? for current and - for future. |
| Controls | Row 23 | Keep the next accepted action separate from the scorecard. |

The former bottom-row celebration now appears as NEW BEST in the header.
The first crossing of 30 already has its result message and success cue. This
removes the crowded extra line without removing either explanation.

The five slots begin at pixel x=8 and are 64 pixels apart. Each surface is 48
pixels wide, leaving a 16-pixel gap. `BR_SX=8+(BR_SLOT-1)*64` computes each origin.
Their text columns advance by 8 because each text cell is 8 pixels wide.
The existing completed/current/future decisions still select the same values;
the new positions and colours do not decide what a round awarded.

The dark panel uses Ink 5 to fill its shape and Paper 5 for its text. Paper 0
returns to the canvas afterwards. Otherwise a text field would stamp a rectangle
of the wrong background over its panel, or later controls would inherit a blue
strip. Pen/Paper restore is part of the routine's return contract.

The larger die uses one origin, `BR_DX,BR_DY`. All its outline and pip positions
are offsets from that origin. For example, a central pip begins at
`BR_DX+25,BR_DY+25`; its opposite corner adds 6 to each coordinate. The six
explicit face branches are the familiar pip patterns with these larger offsets.
A ready die fills with panel colour and shows no pips; a rolled die is a warm
white square with dark pips. Last/No roll text preserves the distinction.

`BR_DRAW_DIE` first clears the fixed region from 244,52 to 308,116, then draws
at its current origin. That margin also covers the later two-pixel shake.
It must not clear the last-roll label on row 15 or the adjacent total panel.
`BR_DRAW_STATE` supplies the resting origin 248,56 before calling it.

**Repair:** The scorecard's fifth value writes beyond its surface. Inspect both
the slot's pixel origin and its text-column formula. Five 48-pixel surfaces
plus four 16-pixel gaps occupy 304 pixels, starting at 8 and ending before 312.
Do not reduce the game to four stored awards to hide a layout error. Check
values 0 and 10 as well as a question mark and dash.

## Show one roll settling

`rolling-die.amos` adds `BR_ANIMATE=1` near the input setup and replaces only
`BR_ROLL_PICTURE`. Its caller still chooses the actual face once, calls the
reveal, then assigns that face and adds it once. Preview pictures never call
Rnd, award points, advance completed rounds, touch Best or spend rescue.

The new For loop visits six preview faces, from 6 down to 1. Even visits put the
origin at 250,54; odd visits use 246,58. Both are two pixels from the resting
origin. Since every pip is relative to the same origin, the whole die moves
together. The fixed clear region removes the old outline and pips between frames.

A second counted loop waits for one vertical blank on the first preview, two on
the second, and so on through six. The 21 waits slow the sequence towards its
end. On the recorded PAL setup this is roughly half a second with drawing and
execution included; it is not a universal wall-clock promise. The original
[screen chapter](https://amospromanual.dev/06-02-using-screens.html) defines
Wait Vbl. Do not add a long Wait after the actual outcome: the player should
be able to read and decide as soon as it settles.

During the reveal the control line says **Rolling... Q quits**. Each waited
frame checks `Upper$(Inkey$)` for Q and exits without committing the unfinished
roll. Other keys during that busy interval are discarded; they cannot bank an
unseen result, accept a bust or spend rescue. The ordinary fresh-key reader
still handles the next decision after settling, including release of held R.
It is not a queue for taps made during the advertised rolling interval.

The routine restores origin 248,56, Paper 0 and Pen 1 before returning. The
caller then redraws the actual accepted face and total. A preview six can
therefore settle on an actual five; that is one roll with a reveal, not seven
rolls. Changing the preview order must not change the die supplier or score.

For the no-motion copy, change only `BR_ANIMATE=1` to `BR_ANIMATE=0`.
The same result appears directly. Fixed-roll runs with and without motion must
have identical settled pictures, awards, target crossing and replay state.
The configuration is a source setting rather than a new game rule.

## Recheck the meaning as well as the picture

Supply 5 in place of `Rnd(5)+1`: two fresh R presses make a perfect 10. Play
five rounds. Three reach 30 and continue; five reach 50 and set Best. The target
cue occurs once at the first crossing. Replay keeps Best and clears the card.
Repeat with Volume 0 and with motion disabled; every outcome stays readable.

Supply 6 separately. A pending bust keeps the current ? and completed count;
U restores the earlier total while spending rescue, or B accepts zero and
keeps it. With supplied 4,5,6, undo restores total 9 and face 5. That checks the
face restoration as well as the number. Test Q during rolling, active play,
the rescue question, a between-round result and the ending.

The [execution record](https://github.com/code198x/docs/tree/amiga-course-and-tooling-briefs/audit/2026-10-amos-bank-or-risk-arcade)
retains the native motion clip, captures and sound checks. Save and independently
reopen the native program through the [storage route](../opening/README.md#keep-that-edit),
requiring a valid exported filesystem before cold boot. No public lessons are
replaced. The user's earlier play feedback supports the game; acceptance of
this new presentation and an uncoached learner trial remain separate work.
