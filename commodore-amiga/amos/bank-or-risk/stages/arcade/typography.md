# Give words and scores different roles

Start from [stable-display.amos](stable-display.amos). The complete intermediate
`rom-text.amos` moves ordinary text to the Amiga's ROM font. `styled-board.amos`
then adds a small bitmap alphabet for the title and larger scores. The bright
palette and game rules stay the same. Both stages use the complete-frame display
routine, so the player sees the lettering only when the picture is ready.

Instructions and explanations use the ROM face at its normal size. The title
uses distinctive lettering, twice as large on the ready screen. Secured points
and the current total have larger digits. Best, limit, progress and the five
awards remain supporting information. Changing a typeface is not enough if the
player still cannot tell which number matters.

## Select and measure the ROM face

After the buffer setup, add:

```text
Get Rom Fonts
Set Font 1
BR_BASE=Text Base
```

Get Rom Fonts builds the font list from the computer's ROM. In the checked
Kickstart 3.1 setup, Font$(1) reports topaz.font, height 8, Rom. The native probe
also reports baseline 6 and a width of 96 pixels for Bank or Risk. This verifies
index 1 for that configuration; do not assume an arbitrary font-list index has
the same meaning on an unchecked setup. No font file is loaded from a disk.

Set Font selects the face for graphical **Text**, not for Print. Replacing only
the Set Font line would leave the existing Print fields using their old text
font. The [original font chapter](https://amospromanual.dev/11-01-fonts.html)
explains Font$, Set Font, Text Base and Text Length.

## Move from cells to graphical text

A Locate column or row counts text cells. Text takes a pixel position measured
at the font's baseline. This bridge retains the current eight-pixel grid:

```text
BR_TX=(column)*8
BR_TY=(row)*8+BR_BASE
```

The source replaces each Locate with those two assignments, using the original
column and row expressions. Its following Print becomes a string assignment
and a call to BR_LABEL. For example, the completed-count field constructs:

```text
BR_TEXT$="Completed: "+Str$(BR_DONE)+"/"+Str$(BR_MAXTURN)
Gosub BR_LABEL
```

Text requires a string. Str$ converts the stored numbers into printable strings;
+ joins those strings. The game still stores and compares numbers. Do not turn
BR_DONE into a string just to display it.

The complete source retains Pen/Paper and records each selection in BR_PEN and
BR_PAPER. The graphical routine uses those recorded colours:

```text
BR_LABEL:
Ink BR_PEN,BR_PAPER
Text BR_TX,BR_TY,BR_TEXT$
Return
```

Ink chooses the graphical foreground and background. Using the panel's
background for its labels avoids stamping dark canvas rectangles onto it.
The renderer restores its usual Pen/Paper contract before returning. These
helpers affect presentation, not awards or input decisions.

**Predict:** Change the selected ROM font in an isolated copy. Text Length and
Text Base may change. Check a long instruction, both controls and the two-digit
values before assuming the old coordinates still fit. A proportional font cannot
be laid out safely just by counting its characters.

## Draw a small alphabet

The styled source needs only digits and the letters in BANK OR RISK. It stores
18 glyphs in BR_GLYPH$(), and their order in BR_LETTERS$. Each glyph is a string
of 35 zero/one characters: five columns across, seven rows down. For example,
read the zero as seven rows:

```text
01110
10001
10011
10101
11001
10001
01110
```

A 1 draws ink; a 0 leaves the existing background. The diagonal helps distinguish
zero from the letter O. The complete source joins the rows into one string per
glyph. The assignments sit before the ready screen, after Dim BR_GLYPH$(18),
so they exist before the first lettering call. This is authored source data;
there is no external font, image bank or hidden download.

BR_WORD$ is the text to draw. BR_GX/BR_GY set its top-left origin, BR_SCALE its
pixel scale and BR_GINK its colour. BR_LETTERING visits each character in turn.
Instr finds it in BR_LETTERS$; Mid$ reads the corresponding glyph's cells.
A space or unknown character has index zero and advances without drawing.
This deliberately small alphabet is not a general text replacement.

For row BR_GROW and column BR_GCOL, the string position is:

```text
BR_GROW*5+BR_GCOL+1
```

Rows and columns start at zero; string positions start at one. The pixel position
is the word origin plus its character advance and the selected cell:

```text
BR_PX=BR_GX+((BR_CHAR-1)*6+BR_GCOL)*BR_SCALE
BR_PY=BR_GY+BR_GROW*BR_SCALE
```

Five drawn columns and one empty column give each character its six-pixel
advance. At scale 2 every cell occupies a two-by-two block. At scale 1 the
source uses Plot: AMOS rejects a Bar whose two corners describe that one point.
Larger cells use Bar with their last pixel at origin+scale-1. The rejected
single-pixel Bar attempt is retained in the native record.

**Repair:** A letter's crossbar has a gap. Work out which row and column own the
missing cell, predict its string index, then change that bit. Run the title at
both scales. Do not move every later character to hide a wrong glyph.

## Apply it where it helps

The ready title uses origin 8,16 and scale 2. The board header uses origin 8,8
and scale 1. The secured score uses origin 80,29 and scale 2; the current total
uses 168,73 and scale 2. Their ordinary labels stay in the ROM face. All three
score states—zero, a useful total and a two-digit bust—must fit their regions.
The drawing routine never changes the number it has been asked to display.

The [native record](https://github.com/code198x/docs/tree/amiga-course-and-tooling-briefs/audit/2026-10-amos-bank-or-risk-complete-frames)
retains title, active, result, rescue, record and replay pictures, along with
continuous transition checks. Source contracts compare the game decisions and
sound routine with the accepted endpoint. These checks do not establish that a
new learner understands the font representation or every edited variation.

## Keep the larger program

Save this version to a separate, empty Amiga data disk. The checked AMOS system
disk reports full when asked to save this larger program alongside its runtime
files. Waiting longer does not create free space. Give the data disk a clear
label, save the native .amos program, and verify that disk before the independent
reopen. Boot the original AMOS runtime separately, insert the data disk, then
Load the program. A snapshot restore is not a native Load test.

Native saving of this larger endpoint remains unqualified: the data-disk
trial produced an invalid exported filesystem after the media change.
[Emu198x #1877](https://github.com/emu198x/emu198x/issues/1877) tracks that
reproduction. The independent reopen described above remains a required check;
the earlier endpoint’s storage success does not qualify this one.
