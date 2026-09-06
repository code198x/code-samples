# Bright Spark opening lesson drafts

Seven complete runnable checkpoints accompany the two replacement lesson drafts. Existing published sources remain in `unit-01/` through `unit-06/`; these new files are under `opening/` until release is agreed.

- Unit 1: one coloured row; a rectangle; a routine supplied with coordinates and colour; four labelled panels.
- Unit 2: one persistent active cue; a note followed by restoration; all four cues in order.

Target: stock 48K Spectrum, 50 Hz configuration, Sinclair BASIC. Sources are typed through the ROM editor. The verification runner checks transitions by deleting removed BASIC line numbers and entering changed lines, preserving the preceding checkpoint's program.

```sh
python3 verification/verify.py --emulator /path/to/emu198x-spectrum --output /tmp/bright-spark-opening
```

Requires the sibling prototype and Meet BASIC verification transports, Python 3 and a configured, lawfully supplied 48K ROM. Emu198x Spectrum v0.22.1 on Apple silicon passed all seven checkpoints and a return to the single-cue caller; see [results](verification/results.json), including source hashes. Labels, active/resting marker state and STOP reports were checked. Sources in `snippets/` are exact excerpts of the corresponding complete state, not additional programs.

The automation allows 60 extra frames after each edit for ROM listing/redrawing. Without that allowance, one run reached a missing-variable report after editing the first active-cue checkpoint. The same unchanged BASIC sources passed with the allowance; the failure has not been isolated as an emulator defect. This delay belongs to the typing harness, not the lesson program.

The board and active blue panel captures have been inspected in colour; the active panel was also inspected through a browser greyscale filter. All four labels and the asterisk remain identifiable. Subjective listening, native keyboard review and original hardware remain unverified. The drafts are not published lessons.

[Playback investigation](../prototype/README.md#playback-policy) records fixed sequences, repeated cues, key interference and release hand-off. The lesson cue retains the extra interruptible PAUSE, explicitly described as variable pacing rather than a precision timer.
