# Volley prototype

A one-paddle rally game for stock 48K Sinclair BASIC. These eight maintained programs investigate the proposed bridge between Bright Spark and Touchdown; they are not published lessons.

## Play

Load `volley.tap` in a 48K Spectrum, enter `LOAD "volley"`, start the tape, then `RUN`. Press and release S to serve. Hold A to move up or Z to move down. Return the ball with the left paddle; each return adds one. After a miss, press and release R to return to the serve screen, or Q to quit. Q also quits during play. An empty-input hand-off prevents a held serve/retry key from advancing twice.

The source is `steps/step-08.bas`. The prototype is silent. PAPER-coloured spaces form a blue court, cyan walls and a yellow paddle; the white ball uses an existing character. It does not require an assembler, custom graphics or machine-code helpers. The tape is produced by the Spectrum ROM's SAVE command, not an injected program image.

## Checkpoints

| Source | Result | New idea |
|---|---|---|
| `steps/step-01.bas` | Horizontal movement stops at the edge | Position changes; erase the previous image |
| `steps/step-02.bas` | Horizontal movement returns from boundaries | Signed direction |
| `steps/step-03.bas` | Diagonal movement in a closed court | Two coordinates and independent reflections |
| `steps/step-04.bas` | Control a bounded paddle beside the moving ball | Input within updates; paddle length and limits |
| `steps/step-05.bas` | Paddle contact returns the ball; a miss stops | Candidate position, interval overlap and collision order |
| `steps/step-06.bas` | Serve, score, retry and quit | Integrate familiar counters and reset behaviour |
| `steps/step-07.bas` | Colour the court, paddle and score strip | PAPER spaces and restoring the background |
| `steps/step-08.bas` | Keep the ball visible during calculation | Consecutive erase/draw; update paddle endpoints only |

Steps 2–3 run until Spectrum BREAK (CAPS SHIFT + SPACE). Step 4 retains an automatic left-boundary return while demonstrating paddle controls; it is not yet a rally game. Step 5 deliberately stops on a miss; step 6 supplies the complete play cycle. Each file is a complete program, and the verifier applies its differences through ROM editing.

The paddle occupies column 2 and three rows starting at `p`. The ball moves in rows 3–19 and columns 3–29. Contact is resolved on the candidate next position: vertical wall reflection first, then right wall or paddle. A successful return moves the ball back into the court; the paddle is never overwritten. This discrete rule is a model to teach, not a simulation of round surfaces.

## Verification

Run from this repository with Python 3 and a released Emu198x Spectrum executable configured with a lawfully supplied 48K ROM:

```sh
python3 sinclair-zx-spectrum/basic/volley/prototype/verification/verify.py \
  --emulator /path/to/emu198x-spectrum --output /tmp/volley-baseline
python3 sinclair-zx-spectrum/basic/volley/prototype/verification/drawing.py \
  --emulator /path/to/emu198x-spectrum \
  --baseline-tape /tmp/volley-baseline/volley.tap --output /tmp/volley-colour
python3 sinclair-zx-spectrum/basic/volley/prototype/verification/rally.py \
  --emulator /path/to/emu198x-spectrum --paper-paddle \
  --tape /tmp/volley-colour/volley.tap --output /tmp/volley-rally
```

The first command verifies checkpoints 1–6; the second applies and verifies 7–8 and exports the coloured tape. The harness reuses the maintained ROM-key-entry helper from Bright Spark. All source changes and boundary experiments go through the ROM editor. Test-only starting positions and STOP instrumentation are removed before SAVE; the tape is then loaded in a new emulator process for play, retry and quit.

`PAUSE 2` is a provisional pacing choice, not a guaranteed frame rate: key activity may alter the wait. Responsiveness under held input needs observation. Automated movement and collision checks do not establish human enjoyment, native host-keyboard behaviour or original-hardware performance. See the docs repository's Volley prototype record for findings and teaching review.

## Compare the drawing

Step 7 keeps the original erase-first loop so the effect of the next change can be inspected. Step 8 keeps the old ball visible during calculations, then clears its cell and draws the new position consecutively at line 248. It returns to input rather than redrawing again at the top. A moving paddle clears one trailing cell and adds one leading cell; its overlapping cells remain untouched.

The blue playfield is the permanent PAPER setting. Walls, paddle and score use temporary PRINT colours; clearing a moving object therefore restores blue. This is rendering order and selective drawing, not double buffering or pixel scrolling. Fewer operations can also change the cadence.

`verification/drawing.py` loads the maintained monochrome tape, applies the actual ROM edits for stages 7–8, samples ball presence, checks colour restoration and contact boundaries, and exports the final tape for a fresh-process play/retry/quit check. Its optional diagnostic capture uses a declared temporary PAUSE 0; that edit is removed before export. Run `verification/rally.py --paper-paddle` for the coloured version's automated rally. These checks distinguish screen-memory sampling from human flicker perception.

## Token spacing

Listings retain readable spacing, such as `PRINT AT y,x;"o"`. Sinclair BASIC tokens supply that spacing when displayed; it is not an instruction to press Space after a keyword. The entry helper strips redundant post-keyword spaces only when converting a listing into ROM keystrokes. Quoted spaces remain meaningful, and `GO TO` / `GO SUB` remain compound token names.

`verification/spacing.py` checks the stored tape program, while `spacing-source-map.json` maps readable source hashes to the verified normalised entry hashes. Restoring readable sources does not change the keystrokes or the corrected tape.

## Lesson drafts

The website's `src/drafts/volley/` contains the overview and eight lesson drafts. Its roster declares the exact add/replace/delete sets; `verification/lessons.py --roster /path/to/website/src/drafts/volley/roster.json` checks them against the full sources and five focused snippets. Short opening lessons show their complete listings instead of duplicating change snippets.
