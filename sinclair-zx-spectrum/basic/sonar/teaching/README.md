# Sonar teaching checkpoints

Eleven runnable states for the approved nine-lesson sequence. The game is one hidden target on an 8×8 grid, with near (1–2), medium (3–4) and far (5+) readings. Zero is a hit. This is Sinclair BASIC for a stock 48K ZX Spectrum, PAL.

| Lesson | Checkpoints |
|---|---|
| 1 | One row; labelled board with a visible fixed target |
| 2 | Validated row prompt; row and column hit/miss probes |
| 3 | Exact-distance clue at the latest probe |
| 4 | Banded clue at the latest probe |
| 5 | Separate array experiment; remembered clues in the game |
| 6 | Distinct-probe count, repeat handling and redraw |
| 7 | Instructions, fixed round, discovery/retry/exit |
| 8 | Random rounds; final accepted game |
| 9 | Uses lesson 8 unchanged, saved and fresh-loaded |

`roster.json` names each complete source, its starting source, added/replaced/deleted BASIC lines and maintained edit snippet. The lesson 5 array experiment is separate: save the lesson 4 game, use NEW for the experiment, then reload lesson 4 before applying the memory edits. It is not an unexplained replacement of the running game's code.

`verification/derive.py` derives these maintained files from the retained prototype sources. It also checks byte-for-byte final-source equality with `prototype/experiments/distance-bands.bas`. Do not edit a derived listing without reconciling the derivation and exact edit roster.

## Execution

With the configured 48K ROM and released Emu198x Spectrum 0.25.0:

```sh
python3 verification/derive.py
python3 verification/audit.py
python3 verification/verify.py --emulator /path/to/emu198x-spectrum --baseline /path/to/sonar-bands.tap --output /tmp/sonar-teaching
```

The runner enters source changes through ROM keyboard events, executes every state, observes screen and numeric state without injecting game data, and captures the results. It explicitly edits the fixed target for band boundary checks and restores it. A final tape is saved through the ROM, loaded in a fresh process, played, retried and exited. Its stored program bytes are compared with a fresh load of the accepted banded tape.

`verification/results.json` retains emulator/ROM identities, source hashes and the checks. These pass for all eleven states, including both input prompts, invalid/long input, band boundaries, all 64 remembered clues, repeated probes, display reconstruction, fixed and random retries, and final fresh loading. The inspected captures and their source mapping live in `captures/`. Source equivalence and scripted execution do not establish beginner comprehension or original-hardware compatibility.

The approved lessons live in the website repository under `src/content/curriculum/sinclair-zx-spectrum/basic/sonar/`. Publication checks and the review record remain with the website. See the documentation repository's `platforms/sinclair-zx-spectrum/games/sonar/lessons.md` for the authoring and review status.

The original program and character graphics use the samples repository's MIT licence. Hardware/language sources: Steven Vickers, edited by Robin Bradbeer, *ZX Spectrum BASIC Programming*, second edition (Sinclair Research, 1983), chapters 4–5, 7–9, 11–12, 15–16 and 20. The band rule is a game design, not a physical sonar simulation.
