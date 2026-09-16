# Sonar prototype

Six checkpoints of the proposed replacement Sonar course. Target: stock 48K ZX Spectrum, PAL, Sinclair BASIC. The investigation is retained alongside the approved replacement teaching sequence in `../teaching/`.

| Source | What runs |
|---|---|
| `steps/step-01.bas` | A labelled 8×8 PAPER board. `X` shows the fixed target at row 3, column 6. `>14` in the bottom-right cell is a layout diagnostic, not a calculated clue. |
| `steps/step-02.bas` | Row/column input against the visible fixed target. `>-` marks a miss; `>*` marks a hit. |
| `steps/step-03.bas` | The target is hidden. Each probe reports exact orthogonal distance: the row difference plus the column difference, without direction. |
| `steps/step-04.bas` | A two-dimensional array remembers clues. Repeated probes preserve the count, and a full redraw reproduces stored knowledge. The target is still fixed. |
| `steps/step-05.bas` | Instructions, discovery, retry and exit complete a fixed-site round. |
| `steps/step-06.bas` | Each round selects a random target; the clue rule and controls stay the same. |

## Try it

Load a generated `sonar1.tap` through `sonar6.tap` in a 48K Spectrum emulator. These tapes start at line 10 after loading. Stage 6 is the random-round play version. With Emu198x:

```sh
emu198x-spectrum --machine spectrum_48k --tape /path/to/sonar6.tap --autoload-tape --scale 3
```

Enter one digit from 1 to 8 and press Enter for the row, then do the same for the column. Enter Q at either prompt to return to BASIC. `RUN` starts the checkpoint again. These are ROM keyword-editor commands: use the emulator's documented Host keyboard mode, or R for the RUN keyword in Original keyboard mode.

The `>` marker identifies the latest probe without depending on colour. Unknown cells show a dot; a hit shows `*`. Only the latest probe remains on the board in stages 2–3. Stage 4 remembers all clues and counts distinct valid probes, including the winning probe. Revisiting a cell moves the latest marker but does not increase the count. Stages 5–6 begin with instructions: press Enter to search. After discovery, enter R and press Enter for another round, or Q to quit. Stage 5 repeats the fixed site; stage 6 selects a random target. A separate round may legitimately select the same target again. There is no probe limit, rating or sound.

## Accepted banded game

`experiments/distance-bands.bas` changes one rule from stage 6: a probe reveals `N` for 1–2 steps, `M` for 3–4, or `F` for 5 or more. A direct hit still shows `*`. Steps mean row difference plus column difference. The legend remains above the board; old clues, distinct-probe counting, random rounds and controls are unchanged. The array stores the revealed band (1, 2 or 3), rather than the exact distance. This is the accepted game endpoint after human play. Its source path remains stable for the verification records; the derived and executed teaching checkpoints live in `../teaching/`.

Load `sonar-bands.tap` with the same emulator command as above. The agreed default remains 8×8; a larger board is an optional extension. More probes alone are not evidence of a better game.

Reproduce the comparison from the verified stage-six tape:

```sh
python3 verification/bands.py --emulator /path/to/emu198x-spectrum --baseline /path/to/sonar6.tap --output /tmp/sonar-bands
```

The runner checks the baseline hash, enters changed lines through the ROM editor, checks distance boundaries with a declared fixed-target edit, restores random placement, solves eight rounds using only revealed clues, and saves and fresh-loads the comparison tape. `verification/bands-results.json` records execution evidence. Scripted play does not establish human enjoyment.

## Representation and input

`tr` and `tc` hold the hidden target. `pr` and `pc` hold a completed coordinate entry; `lr` and `lc` identify the latest marker. Stages 1–3 have no array. From stage 4, `g(row,column)=-1` means unprobed; otherwise the cell stores its revealed distance, with zero for a hit. The array records the player's knowledge and never contains an unrevealed target marker. A new probe stores a clue and increments `n`; a repeat reads its existing clue.

Ordinary probes redraw only the old and new marker cells. Both incremental drawing and full-board reconstruction call the same cell renderer. Drawing reads the array and does not decide distances, change the target or count probes. Each new round recreates and initialises the array, clears the counter and latest marker, and resets coordinate input. Stage 6 calls `RANDOMIZE` once after the instructions, then uses `INT (RND * 8) + 1` for each target coordinate on each round. Retries continue the random sequence rather than reseeding it.

Each logical cell occupies three character columns by two character rows. A cell at `(r,c)` starts at screen row `4+2*(r-1)`, column `5+3*(c-1)`. Labels and a frame surround the board. Status uses screen row 21; the ROM owns the input area below it. Alternating blue/cyan PAPER distinguishes adjacent cells; the printed symbols carry the meaning.

`INPUT LINE` reads text without editable surrounding quotes. Input must be exactly one character between `"1"` and `"8"` before `VAL` runs. Empty strings, fractions, expressions and other text are rejected at the same coordinate prompt. Q is checked before coordinate validation. Sinclair BASIC string names are single letters followed by `$`: `p$` is the prompt, `a$` is the answer and `b$` is the displayed clue.

The ROM may enlarge its input area and scroll the board while a long answer is being typed. After an answer longer than sixteen characters is submitted, the program redraws the board and stored clues before reporting the invalid input. In stages 2–3 it restores the visible diagnostic target where applicable and latest marker instead. The selected row survives an invalid column. Status prints end with a semicolon so they do not advance beyond the last output row. This is ROM input behaviour to explain, not an extra game mechanic.

## The deduction to investigate

For the ordinary fixed target, probing row 1, column 2 gives `2+4=6`. A probe at row 3, column 6 gives zero and displays a hit.

Exact clues at the two ends of the top row determine a single target. Let their distances be `d1` and `d2`. Then:

```text
target row    = (d1 + d2 - 5) / 2
target column = (d1 - d2 + 9) / 2
```

The fixed target produces 7 and 4, so the next probe can be `(3,6)`. This is a deduction exercise, not evidence of sustained replay value. The six checkpoints retain this exact-distance rule. The separately verified banded variant is the accepted endpoint; these exact-distance stages remain available for teaching and comparison.

`python3 verification/deduction.py` independently enumerates all 64 target positions: each pair of exact top-corner clues identifies exactly one cell. `verification/deduction.json` retains that mathematical result separately from emulator execution.

## Reproduce execution checks

Use Python 3 and a released Emu198x Spectrum executable, with a lawfully supplied 48K ROM configured:

```sh
python3 verification/verify.py --emulator /path/to/emu198x-spectrum --output /tmp/sonar-review
python3 verification/rounds.py --emulator /path/to/emu198x-spectrum --output /tmp/sonar-rounds
```

The runners type source through the ROM editor, verify that numbered lines were accepted, check the board and probes, save tapes using ROM `SAVE`, and load each tape in a fresh emulator process. Stage 5 and 6 changes are entered over the preceding complete checkpoint. Read-only screen/memory inspection provides evidence; neither program bytes nor game state are injected. Corner-target checks in the opening runner use declared keyboard-entered line replacements, restored before saving. The saved and loaded program bytes must match the original ROM-entered checkpoint. The rounds runner also clears the display with direct ROM `CLS`, calls the renderer, and resumes the program to establish that the array supplies the whole board without changing the target or count.

Generated tapes are local build outputs. Source and binary hashes, ROM identity and execution results belong in `verification/results.json` (stages 1–3) and `verification/rounds-results.json` (stages 4–6); executed captures belong in `captures/`. Scripted MCP keyboard events are distinct from native host-keyboard acceptance, human play and original-hardware testing.

The retained run passes on released Emu198x Spectrum 0.25.0 with the configured 48K ROM. It covers all 64 cells against the ordinary fixed target, the worked distance-six example, same-cell hits, repeated probes, both maximum-distance corners using labelled target edits, invalid input at both prompts (including 40 and 80 characters), recovery of the board and latest marker, quitting at both prompts, and the two-clue shortcut. Each of the three tapes was saved through the ROM and automatically started in a fresh emulator process; the loaded program bytes match the original entered checkpoint. The captures were visually inspected. Human play and native host-keyboard acceptance remain open.

The stages 4–6 record covers all 64 retained clues, repeated misses and hits, the winning probe counted once, invalid-input preservation, reconstruction after `CLS`, fixed-site retries, all exit prompts, and twelve random rounds solved from revealed clues. All three later tapes also pass fresh-process loading and play; stages 5–6 additionally complete retry after loading. A follow-up shortened instruction line 5060 to fit the screen: stored program bytes were identical everywhere else, and title display, play, retry, exit, saving and fresh loading were checked again. The record retains both source revisions and links the follow-up evidence explicitly. This establishes functioning random rounds, not uniformity of the generator or human replay value.

## Sources

Steven Vickers, edited by Robin Bradbeer, *ZX Spectrum BASIC Programming*, second edition (Sinclair Research, 1983): chapter 4 (single-letter FOR variables and nested loops), chapter 7 (variable names), chapter 8 (`VAL`, `STR$`, `ABS` and `INT`), chapter 11 (`RND`, range conversion and `RANDOMIZE`), chapter 12 (`DIM`, initialisation and two-dimensional arrays), chapter 15 (`PRINT AT`, `INPUT LINE` and the lower input area), chapter 16 (PAPER and INK), and chapter 20 (named tapes and `SAVE … LINE`). The distance rule is this game's design, not a simulation of sonar propagation. Original source and character-based graphics use this repository's MIT licence.
