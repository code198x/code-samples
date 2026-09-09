# Bright Spark replacement lesson drafts

Eighteen complete runnable checkpoints accompany seven replacement lesson drafts. Existing published sources remain in `unit-01/` through `unit-06/`; these new files are under `opening/` until release is agreed.

- Unit 1: one coloured row; a rectangle; a routine supplied with coordinates and colour; four labelled panels.
- Unit 2: one persistent active cue; a note followed by restoration; all four cues in order.
- Unit 3: a stored order; length and first/last character diagnostics; append a literal choice while preserving the prefix.
- Unit 4: fixed playback; between-cue quit checks.
- Unit 5: one validated fresh choice; a complete fixed-order response.
- Unit 6: one random choice and score; prefix-preserving growth with a 16-round ending.
- Unit 7: instructions and readiness; replay, quit and a recoverable finished game.

Target: stock 48K Spectrum, 50 Hz configuration, Sinclair BASIC. Sources are typed through the ROM editor. The verification runner checks transitions by deleting removed BASIC line numbers and entering changed lines, preserving the preceding checkpoint's program.

```sh
python3 verification/verify.py --emulator /path/to/emu198x-spectrum --output /tmp/bright-spark-opening
```

Requires the sibling prototype and Meet BASIC verification transports, Python 3 and a configured, lawfully supplied 48K ROM. Emu198x Spectrum v0.22.1 on Apple silicon passed all seven checkpoints and a return to the single-cue caller; see [results](verification/results.json), including source hashes. Labels, active/resting marker state and STOP reports were checked. Sources in `snippets/` are exact excerpts of the corresponding complete state, not additional programs.

The automation allows 60 extra frames after each edit for ROM listing/redrawing. Without that allowance, one run reached a missing-variable report after editing the first active-cue checkpoint. The same unchanged BASIC sources passed with the allowance; the failure has not been isolated as an emulator defect. This delay belongs to the typing harness, not the lesson program.

The board and active blue panel captures have been inspected in colour; the active panel was also inspected through a browser greyscale filter. All four labels and the asterisk remain identifiable. Subjective listening, native keyboard review and original hardware remain unverified. The drafts are not published lessons.

[Playback investigation](../prototype/README.md#playback-policy) records fixed sequences, repeated cues, key interference and release hand-off. The lesson cue retains the extra interruptible PAUSE, explicitly described as variable pacing rather than a precision timer.

## Sequence representation

Run the third lesson checks from this directory:

```sh
python3 verification/sequence.py --emulator /path/to/emu198x-spectrum --output /tmp/bright-spark-sequence
```

Emu198x Spectrum v0.22.1 passed sequential ROM edits from the final unit 2 checkpoint through all three unit 3 states, rerun initialisation, appending a repeated choice, and restoration of the final source. See [source hashes and observed screen text](verification/sequence-results.json). The final captured display was inspected: all four labels remain visible above the panels and the four diagnostics occupy rows 18–21 without scrolling. This verifies representation and editing continuity, not sequence playback or player input. The new lesson remains a development-only draft for review.

## Complete game verification

```sh
python3 verification/completion.py --emulator /path/to/emu198x-spectrum --output /tmp/bright-spark-completion
python3 verification/finish-experiments.py --emulator /path/to/emu198x-spectrum --tape /tmp/bright-spark-completion/spark16.tap --output /tmp/bright-spark-experiments
```

The completion runner edits the final unit 3 source through all eight later checkpoints, through the ROM editor. It exercises fixed `314`, `22` and `1234`, repeated cues with held/tapping interference, correct and wrong first/middle/last choices, idle and irrelevant input, held response keys, release across phases, and ordinary quit routes. `RANDOMIZE 1234` makes the complete-game run reproducible; the driver observes playback to answer, checks each preserved prefix, completes all 16 rounds, and observes the ending without a seventeenth playback. It then replays, fails the first round for score 0, completes three and fails the fourth for score 3, quits, saves a tape and loads it in a fresh process for another play/replay/quit. No game variables are injected. See [completion results](verification/completion-results.json).

The final source is `unit-07/steps/step-02.bas`. Generated tape/audio files stay in the chosen output directory. The final tape name `spark16` distinguishes it from earlier `spark` checkpoints. The first full run used `spark`; the separate finishing run checks the exact `SAVE "spark16"` / `LOAD "spark16"` workflow used in lesson 7. The finishing runner also checks the temporary two-round cap, rejected keys on both sides of the accepted range, separate short repeated presses, held replay, playback quit, and the proposed pitch/duration experiment. See [finishing results](verification/finish-results.json). Its test-only line edits are declared in the script and do not affect the pristine final tape exported beforehand.

Execution is configuration-specific: released Emu198x Spectrum v0.22.1, Apple silicon, stock 48K ROM, 50 Hz. Each edit receives extra settling frames for the ROM listing, as in the earlier harness. An initial finishing-experiment run omitted that allowance and failed to enter RUN after editing; the unchanged BASIC sources were retried with the established allowance. A second harness check mistook the intentional partial screen clear during replay for lost labels; label assertions now apply during cues and at the ready board, not while CLS is clearing the old result. No emulator defect is inferred from either automation failure.

The final successful-round capture has been inspected and is used by lesson 7. The browser review checks all four new drafts at 390/1440 pixels in light/dark themes, including expanded full sources, answer panels and local links. Publication, independent learner review, native keyboard feel, subjective listening and original-hardware acceptance remain separate. The blocking input does not queue taps made during cues; the lesson tells players to wait for the current cue to finish.
