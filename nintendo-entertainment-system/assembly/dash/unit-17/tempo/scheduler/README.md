# Dash: bounded musical phase

C09b follows the [rate diagnosis](../README.md). It adds an isolated scheduler comparison, not a replacement game release. `scheduler.asm` is the complete small routine; `check.py` generates three instrumented copies of the existing game in an output directory. The original `dash.asm` and ROM stay unchanged. The runner requires the pinned source and a byte-identical rebuild of the maintained ROM.

## Contract

We target nominal 50 musical updates per second. One unit is 1/300 second; a musical update needs six units. A caller at exact 50 Hz supplies 6, while one at exact 60 Hz supplies 5. The phase byte carries unused units, always 0–5. An accepted elapsed value is 1–6, so the sum is at most 11: no byte overflow, and at most one player call is due. There is no catch-up loop. The first service after a phrase starts loads its first row immediately; subsequent calls account for intervals. Generated `start_phrase` resets phase, started and fault bytes for the next phrase.

A value outside 1–6 is explicitly rejected: set `tempo_fault`, clear the active phrase pointer, clear phase and silence pulse 1. The music remains stopped until another phrase is started. This is a diagnostic policy for optional music, not permission to discard collisions, score or simulation updates. The routine cannot detect elapsed time the caller failed to report. It does not repair the existing one-bit notification handshake.

The normal algorithm needs phase and initial-service state; the fault byte makes the policy observable. The fixture additionally counts main opportunities and records 28 events. Fixture bytes occupy $40–$47; event records occupy $0300–$036F, separate from this game's zero page, stack and OAM. The routine may alter A/X/Y through the player. Its state is main-owned; NMI is not changed to access it.

## Exact-rate model

```sh
python3 model.py --output /tmp/dash-scheduler
```

This reuses C09a's parsed phrase and ideal pulse renderer. The target phrase lasts 5.72 s. At exact 50 Hz it is serviced in 5.72 s; at exact 60 Hz its loop boundary is serviced in 5.733333 s. Maximum event lateness for this phrase is 13.333 ms, within one 60 Hz opportunity. Phase is retained instead of rounding every note separately, so lateness does not accumulate unboundedly. Individual intervals can be shorter or longer than requested as adjacent events have different lateness.

`events-50.csv` and `events-60.csv` separate requested and serviced times. `model-results.json` records checks and audio hashes. Requested event indices come from the baseline phrase; a rational-ceiling oracle checks the phase simulation independently. The 50 Hz rendered WAV is byte-identical to C09a's `tempo-50.wav`; the website adds only `scheduled-60.wav`. These are host listening models, not native recordings.

## Native experiment

```sh
python3 check.py --emulator /path/to/emu198x-nes --output /tmp/dash-scheduler
```

Configuration: native Emu198x NES, NTSC, same ROM assets and pitch registers in every copy. Binary hashes are retained in `native-results.json`. `fast` offers the scheduler one call per serviced main-loop opportunity with input 5. `slow` omits every sixth opportunity and supplies 6 at each remaining request. This is a deliberately uneven five-of-six cadence on the **same NTSC machine**, not a PAL run or an exact 50 Hz clock. Both use nominal supplied time; neither measures elapsed hardware time. The frame numbers in the log count serviced main-loop opportunities, not CPU cycles or raw interrupt arrivals.

The first row and the next loop's first row bound the comparison. All 28 `(opportunity, next table index, timer)` records match the independent expected schedule. Fast and slow contain the same notes/rests; corresponding events differ by zero or one opportunity. The loop restart occurs at opportunity 345 versus 344. This is native execution of the real `tune_tick` with instrumentation, not exact-rate model evidence.

The overload copy supplies 30 at opportunity 120. Eleven events precede the fault; the phrase pointer clears, the fault flag remains set, and the recorded audio is zero after four seconds. Every recording contains signal and stays below clipping. WAVs are reproducible outputs in the supplied directory, not separately maintained website assets. Subjective listening and original-hardware testing remain separate.

Fresh-process regressions apply identical Start/release, right/release and A/release schedules to the baseline and all three variants. Selected player, obstacle, score, lives, animation and level state agree; title music stops on entry to play. This is a short regression, not a full completion/restart test. A sampled playing NMI returns on scanline 247 with preserved A/X/Y and balanced interrupt stack use: 718 cycles including DMA for baseline, 719 for the three variants (DMA alignment differs). The measurement excludes interrupt entry and preceding latency. It checks one path, not worst-case headroom or the title/game-over transfer paths. Music work remains outside NMI.

## Boundaries and next work

Instrumentation consumes time and changes layout. The supplied nominal time values do not establish correct physical tempo on every region; exact clocks require a finer ratio and measurement. A stalled main loop may lose notifications before this routine sees them. C09c/d investigate those handoffs separately. Do not merge this fixture into the ordinary game as a finished cross-region scheduler or describe its overload branch as a general recovery mechanism.
