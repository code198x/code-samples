# C01b: find the wrong note

Implemented locally for review on 22 September 2026. The optional companion at
`/experiments/bright-spark/wrong-note/` is linked from unit 02. It supplies an
isolated broken program, prediction prompts, two folded hints, a temporary
value display and a folded repair. No mandatory lesson or game checkpoint was
changed. C01c's packaged handover remains separate.

## Reproduce

Use Python 3, Emu198x Spectrum and a lawfully supplied, configured 48K ROM.
From the code-samples repository:

```sh
python3 sinclair-zx-spectrum/basic/bright-spark/opening/verification/wrong-note.py \
  --emulator /path/to/emu198x-spectrum \
  --output /tmp/bright-spark-wrong-note
```

The baseline and recovery copy is `../../unit-02/steps/step-03.bas`, also used
by the approved C01a comparison. The broken copy is
`../../experiments/wrong-note/broken.bas`. Its only difference is the missing
line 610. `observe.bas` adds line 915; `repair.bas` restores line 610. The harness
asserts these relationships before execution. Source and executable SHA-256
hashes are recorded in `results.json`.

The learner must enter the broken listing in empty BASIC memory. Overlaying it
on the working program would leave line 610 present. The harness instead types
the baseline through the ROM editor and explicitly deletes line 610, then
performs the diagnostic, repair and removal edits. It allows ROM listing redraw
to settle after edits. This host typing delay is not part of the game.

## Evidence

Verified in Emu198x Spectrum 0.24.0, default Spectrum 48K PAL configuration,
on macOS Apple silicon. Six runs pass:

| Run | Expected pitch values | Observation |
|---|---|---|
| Baseline | 0, 4, 7, 12 | Four original tones |
| Broken | 0, 4, 0, 12 | Third tone falls back to middle C |
| Broken with observation | 0, 4, 0, 12 | Row 21 displays these values before BEEP |
| Repaired with observation | 0, 4, 7, 12 | Row 21 displays the corrected values |
| Repaired without observation | 0, 4, 7, 12 | Exact baseline source restored |
| Repeated clean run | 0, 4, 7, 12 | Same pitches and visual order |

Each run checks four tones of approximately 0.15 seconds, asterisks in panel
order 1–4, labels at completion, no remaining asterisk and the intentional STOP
report. Audio uses C01a's 10 ms RMS windows and centre-crossing frequency estimate
with 25 Hz pitch and 30 ms duration tolerances. These are coarse signal checks,
not precision tuning measurements. The diagnostic adds printing time; no timing
comparison uses its execution as the unchanged baseline.

The result is explained by line 540 assigning zero on every renderer call.
The missing conditional assignment affects panel 3 only. The third value does
not inherit panel 2's value. Repair and regression checks retain panels 1, 2 and
4, rather than accepting only the previously faulty panel.

The website's `public/audio/bright-spark/wrong-note.wav` is the untrimmed broken
run from this verification, including setup and trailing silence. It derives
from our own four-note demonstration; no firmware is included. The harness
also writes source snapshots, WAVs and final-screen captures to its output.

## Limits and learner review

This is ROM-entry emulator evidence, not native keyboard acceptance or original
hardware testing. Subjective listening and a structured learner trial are not
claimed. Ask whether the learner can identify the first wrong value, explain
the default assignment, make the local repair and check unaffected panels.
Record which hints were needed before treating this as learner evidence.

The rendered companion was reviewed in Chrome, including expansion of both
hints and the repair. The recording enters playback in the corrected local
preview. Unit 02 MDX compilation, curriculum-route checks and the 135-template
whitespace check pass. The original working source remains untouched.
