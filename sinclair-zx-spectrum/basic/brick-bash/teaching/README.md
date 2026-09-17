# Brick Bash teaching checkpoints

Nine standalone Sinclair BASIC programs support the agreed ten-lesson progression. Lesson ten saves and reloads the final program from lesson nine. The final source is byte-identical to the prototype that worked in native play and was described as surprisingly tough. Difficulty and artwork are unchanged. The approved overview and ten website lessons accompany these checkpoints.

| Lesson | Maintained source | Result |
|---|---|---|
| 1 | [Draw below the character grid](unit-01/brick-bash.bas) | Court and four-pixel ball; stopped drawing experiment |
| 2 | [Send the ball bouncing](unit-02/brick-bash.bas) | Continuous reflection; stops safely at the bottom |
| 3 | [Put the paddle under your control](unit-03/brick-bash.bas) | Held O/P movement, attached ball and SPACE serve |
| 4 | [Catch the falling ball](unit-04/brick-bash.bas) | Keep-up game; catches preserve horizontal direction |
| 5 | [Break one brick](unit-05/brick-bash.bas) | Single stored brick with axis-by-axis collision |
| 6 | [Give the wall an address](unit-06/brick-bash.bas) | Coordinate inspector with eighteen live/removed bricks |
| 7 | [Break the whole wall](unit-07/brick-bash.bas) | Full clearance using the brick array |
| 8 | [Aim with the paddle](unit-08/brick-bash.bas) | Left, vertical and right returns |
| 9–10 | [Finish and keep the game](unit-09/brick-bash.bas) | Complete title, play, result, retry and saved-tape cycle |

The first listing is a new program. Each directory also contains `edits.json` with exact added, replaced and deleted BASIC line numbers and `changes.bas` with only the lines to enter. These are authoring aids; essential explanation and editing instructions still belong in the lessons. Lesson six temporarily replaces the movement driver with numeric INPUT prompts. It retains the graphics and wall routines; lesson seven explicitly restores movement, paddle drawing and the result routines. Enter -1 at its X prompt to quit. A successful probe removes the brick, so probing it again reports no hit.

Other moving stages use R to restart and Q to quit; stages three onwards use O/P and SPACE. Stage nine adds the S-start title. The early stages intentionally do less work and can move faster than the final game. Stage one stops in the ROM editor; entering `GO SUB 3000` toggles the ball off, and repeating it restores the ball. This is a direct BASIC command, not an extra numbered program line.

## Reproduce the evidence

Use Python 3 with Pillow installed and an Emu198x Spectrum executable with its stock 48K ROM configured. Pillow only inspects saved PNGs; it does not create or edit game captures. From this directory:

```sh
python3 verification/derive.py
python3 verification/build.py --emulator /path/to/emu198x-spectrum --output /tmp/brick-bash-teaching --jobs 3
python3 verification/check.py --emulator /path/to/emu198x-spectrum --output /tmp/brick-bash-teaching --jobs 3
python3 verification/final.py --emulator /path/to/emu198x-spectrum --output /tmp/brick-bash-teaching
python3 verification/audit.py --evidence /tmp/brick-bash-teaching
```

Derivation is an authoring tool: the learner programs have no host-Python dependency. Build enters each complete listing through the ROM keyboard in a fresh session and records a self-starting tape. Check loads each tape in a separate session, drives ordinary keyboard input and reads state and bitmap memory. The coordinate inspector receives its test positions through its INPUT prompts. No game-state fixtures are injected. Final runs the prototype's full clearance and control checks against the newly built final tape.

[The evidence summary](verification/evidence/summary.json) identifies nine checkpoints and 55 passed execution groups, including the fourteen final checks. Exact source transitions, literal branch targets, source/tape hashes and both tape-block checksums are audited. A separate exhaustive host calculation compares the wall lookup with rectangle scanning at all 45,056 integer positions in the BASIC drawing area; this is not a claim of that many emulator probes.

Evidence directories retain tapes, stored ROM program lines, execution traces and inspected captures. Load any `bricks.tap` with `LOAD ""`; it starts at line 10. Capture verification checks result labels against the ROM font glyphs and the top 176 display rows against the current RAM bitmap, then retains the original PNG. `captures.json` records how many frames were needed. Result captures also wait for the full prompt. Bitmap checks cover the complete court, surviving bricks, paddle and ball, with the inspector's report below the court.

Human feedback applies to the unchanged prototype endpoint. Scripted checkpoint execution does not establish novice learning outcomes or original-hardware performance. The module overview and ten authored lessons now explain these stages; their local review and publication state belong in the documentation repository.
