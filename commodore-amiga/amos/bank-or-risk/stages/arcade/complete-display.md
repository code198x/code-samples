# Show the finished picture

`stable-display.amos` continues from `rolling-die.amos`. It has the same board,
rolls and rules, but the player no longer watches the board being erased and
rebuilt. This is a separate step before changing the lettering.

The first animation stage draws directly on the displayed screen. The Amiga
can scan that memory while Cls, Bar and Text/Print operations are still changing
it. A frame can therefore contain a cleared panel or an unfinished board. A
correct picture after drawing finishes does not prove that the transition was
clean. The retained recording reproduces the problem as the die settles.

## Draw somewhere hidden

After Flash Off, add:

```text
Double Buffer
Autoback 0
Bob Update Off
```

Double Buffer gives the screen a second image. The **physical** image is the
one being displayed. The **logical** image is where we draw the next picture.
Autoback 0 makes drawing affect only that hidden logical image. Otherwise AMOS
can synchronise drawing to both images and expose the work we are trying to hide.
Bob Update Off stops automatic object updates from controlling swaps; this
stage takes responsibility for when its complete pictures become visible.

This costs another screen's bitmap memory. For a 16-colour 320×200 picture,
four bitplanes hold 32,000 bytes, before bookkeeping. The native check uses the
recorded A1200 configuration; this calculation is not a minimum-machine claim.
The original [screen chapter](https://amospromanual.dev/06-02-using-screens.html)
and [object updating chapter](https://amospromanual.dev/07-03-updating-objects.html)
explain the physical/logical images and manual Autoback mode.

## Present, then prepare the next hidden image

Add this routine after the existing ones:

```text
BR_PRESENT:
Screen Swap
Wait Vbl
Screen Copy Physic To Logic
Return
```

Screen Swap makes the finished hidden picture the displayed one. Wait Vbl lets
that display change take effect. The old displayed picture is now the hidden
one. Copying Physic to Logic makes both images agree again, without changing
what the player sees. That matters because the next preview edits only the die
and controls: its hidden starting picture must already contain the current board.

**Predict:** Omit that final copy and swap several times while changing only
the die. The two buffers can retain different boards or previous die positions.
A second bitmap does not automatically mean that every partial edit is correct.
Restore the copy before continuing.

## Include the controls in the finished picture

Add `Gosub BR_PRESENT` at the start of BR_READ_FRESH, before its existing
held-key check and Clear Key. The caller has already drawn the board and its
appropriate controls. Presenting here shows those together before waiting for
the next choice. The remaining fresh-key code stays unchanged.

Also add `Gosub BR_PRESENT` immediately after the call to BR_DRAW_DIE inside
the preview loop. Each face and the Rolling prompt are then finished before
they appear. Keep the subsequent slowing waits and Q polling. Do not swap after
each pip or line: that would expose another partly drawn image.

No extra random number is chosen. No score, rescue or best is changed by
presenting a picture. The extra copying and vertical-blank wait have a timing
cost, so the previous stage's exact reveal timing is not a promise for this one.
The decision after settling remains untimed.

## Check the transition

Supply five as the roll: begin with an empty die, roll to five, then roll to a
perfect ten. Check both the settled board and every frame between them. Bank,
continue, finish five rounds and replay. A static screenshot can miss a flash
lasting just one frame. Check Q during the preview as well as at input prompts.

The [native record](https://github.com/code198x/docs/tree/amiga-course-and-tooling-briefs/audit/2026-10-amos-bank-or-risk-complete-frames)
compares every recorded roll frame with complete before/after board states and
retains the earlier failed transition. Labels, values and pips still need direct
inspection. A clean recorded case does not establish all possible input timings.
