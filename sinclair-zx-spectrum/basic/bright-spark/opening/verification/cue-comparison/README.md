# Unit 02: hear one change

C01a was approved by the project owner on 22 September 2026. The optional folded comparison stays beside the
four-cue checkpoint in unit 02 so that we can keep the baseline, edit and audio
in one place. It does not add a required lesson. Unit 04 retains the later
input-response comparison. C01b's fault and C01c's game handover remain separate.

## Baseline and reproduction

The recovery copy is `../../unit-02/steps/step-03.bas`; its SHA-256 is recorded
in `results.json`. The working checkpoint is unchanged. The three small files
in `../../unit-02/experiments/` contain the exact pitch, duration and restoration
edits used by the lesson. Apply each variation to the baseline independently.
The captured variant source hashes are also recorded.

From the code-samples repository, with Python 3 and a lawfully supplied 48K ROM
already configured in Emu198x:

```sh
python3 sinclair-zx-spectrum/basic/bright-spark/opening/verification/cue-comparison.py \
  --emulator /path/to/emu198x-spectrum \
  --output /tmp/bright-spark-cue-comparison
```

Verified on 22 September 2026 with Emu198x Spectrum 0.24.0, its default 48K PAL
machine, on macOS Apple silicon. The executable hash is in `results.json`.
The harness types the program through the ROM editor, allows each edit's
listing to settle, then runs baseline, pitch, duration and restored baseline.
No source injection, new audio engine or packaged full game is involved.

The output contains complete sources, WAV recordings, final-screen captures
and a result record. Lesson recordings in the website's
`public/audio/bright-spark/cue-{baseline,pitch,duration}.wav` are untrimmed copies
from this run. They include setup silence and trailing silence; elapsed clip
length is not a measurement of the cue sequence. No firmware is distributed.
These recordings derive from the project's own four-note demonstration.

## Observations

| Run | Approximate measured pitches (Hz) | Detected duration per note |
|---|---|---|
| Baseline | 267, 333, 392, 525 | 0.16 s |
| Pitch only | 258, 333, 442, 525 | 0.16 s |
| Duration only | 262, 331, 390, 521 | 0.46 s |
| Restored baseline | 258, 333, 392, 525 | 0.16 s |

These are coarse signal measurements: 10 ms RMS windows locate sounds and
positive mean crossings estimate frequency within their centres. Window
rounding explains why the detected duration exceeds the requested 0.15/0.45 s.
The pitch check allows 25 Hz; small differences in the other measured pitches
are not evidence that their pitch settings changed. Source comparison confirms
that exactly one numbered line differs in each variation.

Each run showed asterisks in panels 1, 2, 3 and 4 in order. All four labels
remained at the end, no asterisk remained, and BASIC reached `STOP`. The
recordings contain four sustained tones. The script checks each expected pitch
and duration and repeats the baseline after restoration.

## Review and limits

The local Astro rendering was inspected in Chrome: the optional disclosure,
three labelled audio controls, highlighted edits and folded explanation render.
All three audio controls enter playback. MDX compilation, curriculum routes
and template-whitespace checks pass. Lesson edit snippets were compared against
the exact captured variant sources.

Signal and screen assertions are emulator evidence. They do not establish
subjective sound quality, native emulator keyboard behaviour or original
hardware accuracy. No such testing is claimed. The owner approved the exercise;
a structured learner trial and a separately documented subjective listening
check have not been recorded. Ask the learner to predict each change and explain
why tripling note duration does not triple the whole cue; record any help
needed before expanding this exercise format.
