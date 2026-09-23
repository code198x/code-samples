# Dash: one countdown, two update rates

C09a is a listening and trace model of the maintained unit 17 `dash.asm` title sequencer. It is not a ROM capture or a regional emulator comparison. `results.json` pins the inspected source SHA-256; the model refuses to proceed if that source changes. The ordinary game instructions/data and ROM are preserved. A two-line source/snippet comment now describes writes at note/rest/stop loading accurately; the previous “twice per note” claim did not match the routine. The code before and after stripping comments compares identically.

From this directory:

```sh
python3 compare.py --output /tmp/dash-tempo
```

Python's standard library is sufficient. The output contains two WAVs, two CSV traces and a JSON record. Website copies of the WAVs live under `public/audio/nintendo-entertainment-system/assembly/dash/unit-17/tempo/`.

## What is modelled

The script reads all 27 data rows of `camptown_phrase` directly from the game. It models `start_phrase`'s timer=1 and the decrement/test/reload in `tune_tick`. First service is time zero in this comparison. The real game starts a phrase on its next serviced main-loop update, so this alignment is not a claim about startup latency.

Each CSV records every requested update, ideal service time, timer before/after, and note/rest event. Requested and serviced times are equal **by construction**, not measurement. `$FF` marks the excerpt's end: the actual routine loads row zero again during that same call. The model does not implement the unused `$FE` branch, gameplay, interrupt execution, overdue requests or missed notifications. A cumulative-duration oracle checks event indices independently of the countdown implementation.

Each audio file renders an ideal 50% pulse at a fixed gain. Both use the same nominal 1,789,773 Hz reference and the same period bytes in `f = clock / (16 × (period + 1))`. Phase starts afresh for each note. Rests render zero. The model does not reproduce NES analogue filtering, mixer behaviour, sweep, envelope, register-write latency or detailed waveform phase. Its purpose is to hear timing while keeping tuning fixed. Quarter-second silence precedes and follows each excerpt; the phrase's own rests remain inside it. Files are not normalised independently.

## Checked result

- Identical 27 pitch/rest events at identical update indices for both rates.
- 286 updates per title loop: 5.72 s at 50 updates/s, 4.766667 s at 60.
- Row 10 (zero-based) is a six-update rest starting at update 96. The next note begins at update 102: 120 ms at 50 or 100 ms at 60.
- The 60-update version runs 20% faster; its duration is one sixth shorter.
- WAV sample lengths match the schedule plus padding; signal is non-zero and does not clip. These checks do not establish subjective listening quality.

This is host-generated explanatory evidence. It neither validates Dash's actual deadline handling nor measures host-emulator performance. No original-hardware result, scheduler repair, PAL conversion or new music engine is claimed.

## Trace the real caller

In the maintained source, NMI saves registers, performs its display work, sets `nmi_flag`, restores registers and returns. Main tests and clears that flag, reads the controller, calls `tune_tick`, then dispatches game state. It is one CPU executing those contexts at different times. A flag is not a backlog counter; inspecting missed notification and shared-state hazards belongs to C09c/d. Moving all music work into NMI would not automatically solve scheduling or transfer-budget problems.

## Sources and next step

The source establishes the countdown and phrase data. NESdev's original community hardware research documents the [pulse timer frequency](https://www.nesdev.org/wiki/APU_Pulse). Direct retrieval returned 403; the indexed source excerpt confirmed the frequency formula and nominal regional clocks. Exact regional clock, PPU and service timing are deliberately outside this model.

C09b can compare a bounded musical-phase accumulator against this baseline. It must expose event-spacing jitter and a deliberate backlog policy, then obtain separately labelled native evidence. This pass stops at the diagnosis.
