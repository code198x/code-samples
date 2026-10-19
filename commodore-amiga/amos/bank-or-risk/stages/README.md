# Draw a die, then match its face

These are two small AMOS programs from the bank-or-risk opening. The first draws
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
defines `Wait Key`. These checked fragments are authoring material; the full
beginner route still needs the earlier message/save steps and later game steps.
