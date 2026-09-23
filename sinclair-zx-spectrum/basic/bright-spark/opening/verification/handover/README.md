# C01c: Bright Spark handover

Target: Spectrum 48K PAL. Baselines and recovery copies are
`../../unit-04/steps/step-02.bas` and `../../unit-07/steps/step-02.bas`.
The working game is not edited by this delivery. Unit 04's temporary line 920
change is restored before switching to the complete final source.

From the code-samples repository, with Python 3 and Emu198x Spectrum's required
48K ROM already configured:

```sh
python3 sinclair-zx-spectrum/basic/bright-spark/opening/verification/handover.py \
  --emulator /path/to/emu198x-spectrum \
  --output /tmp/bright-spark-handover
```

The harness uses the existing `completion.py` ROM-entry and observation helpers.
It first compares q held at the first active asterisk with note lengths 0.15,
0.45 and restored 0.15 seconds. This is a repeatable guest observation point,
not native input latency or a measurement from the beginning of BEEP. A longer
note should delay exit; restoration should return to the baseline observation.
The cue must finish at rest and quit before another cue begins.

The final game checks use its unchanged 16-round cap. They observe the generated
sequence to supply responses, test success, repeated replay and failure counts,
then SAVE the final program through the ROM. A new emulator process LOADs the
TAP and tests play, failure, replay and quit. Source, binary and TAP hashes and
per-case observations belong in `results.json`. The local release manifest
binds the package to this evidence.

Screen-memory marker transitions are not completed-raster timestamps. Automated
MCP keys are not native host-keyboard evidence. Subjective listening, an
independent learner trial and original-hardware testing are not implied.

## Observed on 22 September 2026

Emu198x Spectrum 0.24.0 on macOS Apple silicon passed the automated route.
Held q at the first active marker reached STOP after 26, 41 and 26 guest frames
for requested notes of 0.15, 0.45 and restored 0.15 seconds. These observations
are not universal latency bounds. The complete 16-round game ended with count
16; subsequent attempts failed at counts 0 and 3 as expected. A fresh process
loaded the exported TAP and passed play, failure, replay and quit checks.

A fresh native UI launch loaded that same TAP and displayed `Program: spark16`
and `0 OK, 0:1`. A temporary macOS app wrapper was used so the UI tool could
locate the existing executable; it is not part of the release. Native launch
required access outside the sandbox for CoreAudio. No emulator code changed.

Native acceptance remains incomplete: automated UI keystrokes did not reliably
enter a clean RUN command, including after selecting Original keyboard mode.
This does not establish a fault in the game or the emulator's human keyboard
handling. The native loaded-program screen is evidence of loading only.

**Remaining manual pass:** from a clean load, run the game, start, watch and
repeat a round, fail, replay twice and quit; repeat with sound muted. Check
labels, active asterisks and result text without relying on hue. Record the
keyboard mode and any missed press. Automated screen-memory checks establish
the marker order but do not substitute for this perceptual check. Native
success through all 16 rounds is not claimed; that path has automated evidence.

Unit 07's handover section was rendered and visually reviewed in Chrome. Its
local tape endpoint returns HTTP 200 and byte-for-byte matches the packaged
TAP. MDX compilation, curriculum-route and template-whitespace checks pass.

## Owner play feedback

On 22 September 2026 the owner reported that the game was challenging and
“Works well”, accepting the handover. This is a reported successful play check;
it does not specify keyboard mode, completion of all 16 rounds, each replay
path or testing with sound muted. Those details are not inferred. The narrow
muted/readability check remains in the release queue; approval permits moving
on to the next implementation chunk.
