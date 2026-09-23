# Triangle cue: counter experiment

C02c, 22 September 2026. This is an author verification fixture, not a new engine
or a replacement Dash checkpoint. The lesson adds an optional prediction and
comparison using the existing three register writes.

## Baseline and scope

The maintained unit-11 source starts the four-step APU sequence with `$4017=$40`,
enables pulse 1 and triangle with `$4015=$05`, and requests the collection cue
with `$4008=$18`, `$400A=$29`, `$400B=$00`. Only explanatory comments changed in
the maintained source and its snippet. Asm198x 0.0.58 rebuilt the revised source
to a temporary ROM that compares byte-for-byte with the existing `dash.nes`.
The baseline hashes are in `results/identity.json`; the source hash there is the
pre-comment-edit baseline. No change to game behaviour or existing audio media.

The isolated fixture uses Emu198x's published APU crate, version 0.6.0, from
workspace revision `1b999de47dea60e424efbdc68f1cd483cb0191a6`. It runs one APU tick
per modelled CPU cycle. NTSC and PAL use nominal CPU clocks of 1,789,773 and
1,662,607 Hz for conversion into milliseconds. Rust 1.98.0 built the fixture.
The crate source hash is preserved with the results.

This is **APU counter execution**, not a ROM running through a CPU/PPU, subjective
listening, exact analogue onset/decay measurement, or original-hardware evidence.
Writes in the fixture have no intervening instruction cycles; phases explicitly
vary the time of the trigger. No emulator-core code changed.

## Reproduce

From code-samples, with Rust and the APU crate's dependencies already cached:

```sh
python3 nintendo-entertainment-system/assembly/dash/unit-11/verification/check.py \
  --emulator-repo /path/to/emu198x \
  --output /tmp/dash-triangle-results
```

The runner creates and removes a temporary Cargo project. It does not overwrite
Dash or its ROM. `triangle.rs` is the entire inspectable experiment.

For each region and four sequencer phases, compare linear reloads 24 and 96 with
length indices 0 and 1 (`$400B=$00` and `$08`). Assertions check the first gate to
close, unchanged stop times when only the linear reload changes behind the short
length gate, and a substantially longer interval once the length gate permits it.
Additional checks cover deferred linear reload, accepted timer writes while
disabled, enabling without a length reload, bit 7 halting both duration mechanisms,
and clearing length through `$4015`.

`onset_ms` is when both counters first become non-zero; `stop_ms` is when either
first reaches zero, both measured from the register writes. Neither is a measured
sound pressure onset or an audio-file tail.

| NTSC cases | Observed stop time from trigger | First gate to close |
|---|---|---|
| reload 24, length index 0 | 78.866–83.336 ms | length |
| reload 96, length index 0 | identical for each phase | length |
| reload 24, length index 1 | 103.004–104.170 ms | linear |
| reload 96, length index 1 | 403.009–404.174 ms | linear |

The phase samples are not exhaustive bounds. PAL results differ and are retained
in the CSV; the lesson's round-number duration examples explicitly name NTSC.

## Sources and remaining limitation

NESdev's original hardware research: [triangle](https://www.nesdev.org/wiki/APU_Triangle),
[length counter](https://www.nesdev.org/wiki/APU_Length_Counter),
[frame sequencer](https://www.nesdev.org/wiki/APU_Frame_Counter),
[mixer](https://www.nesdev.org/wiki/APU_Mixer). The maintained source extracts were
checked as well as available search excerpts; direct page retrieval returned 403.
The emulator is corroboration, not the authority for the hardware explanation.

Source inspection found a separate fidelity issue: the APU crate's
`Triangle::output()` returns zero when a gate closes. Hardware holds the current
waveform output instead. Its `clock_timer()` already gates sequence advancement.
Do not use current emulator output to demonstrate held DAC level, phase-related
clicks, or exact analogue silence. A future emulator fix needs a focused held-level
regression and audio/mixer review; it is outside this lesson correction. The
counter fixture deliberately does not test or endorse that output behaviour.

The learner comparison and subjective listening remain to be tried. The default
cue, difficulty and parked NES browser trial remain unchanged.
