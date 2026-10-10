# NES square wave

The maintained source for the Square Wave pattern. Target: NTSC NES, NROM
(mapper 0), rendering off. `make` builds `demo.nes`. Load it in any NES
emulator: it holds A-4 (timer 253, 440.4 Hz on NTSC) on pulse 1 until reset.
The screen stays black. After setup the CPU only copies `$4015` into
`status` (zero page `$00`); the tone needs no CPU time.

The contract is in `square-wave.inc`. `pulse1_tone` takes the timer's low
byte in A and its top three bits in X; the 11-bit timer must be 8–`$7FF`.
It writes duty 50%, length-counter halt and constant volume 15 to `$4000`,
`$08` to `$4001`, then the timer to `$4002`/`$4003`. The caller owns `$4015`
and sets bit 0 first, because a `$4003` write loads the length counter only
while the channel is enabled. Writing `$4015` also sets every other channel's
enable, so a game shares one copy of that byte between its sound routines.

`$08` in `$4001` disables the sweep with negate set. The sweep unit computes
its target period even when disabled; with negate clear and shift 0 the target
is twice the current period, so any timer of `$400` or more is muted.

Run the executable check with:

```sh
python3 verification/verify.py --emulator /path/to/emu198x-nes --output /tmp/square-wave
```

It builds `demo.asm` and six variants that replace only the setup between
the reset code and the hold loop, runs each for 120 frames in
`emu198x-nes --mcp`, and checks the machine's own `$4015` read and the
captured PCM:

| Case | Expected |
|---|---|
| held-a4 (the demo) | 440.4 Hz, level unchanged to the end, length counter non-zero |
| octave (timer 126) | 880.8 Hz, exactly twice held-a4 |
| low-negate-sweep (timer `$400`, `$4001=$08`) | 109.1 Hz |
| low-sweep-00-mutes (timer `$400`, `$4001=$00`) | silent, length counter still non-zero |
| timer-below-8-mutes (timer 7) | silent, length counter still non-zero |
| load-before-enable (`$4003` before `$4015`) | silent, length counter zero |
| length-expires (halt cleared, index 0 = 10) | tone stops after 75–84 ms at full level, no fade |

Pitch and duration are checked twice: against emulated time (120 NTSC
frames with rendering off) and against the WAV header, as an audio player
would play them. The current capture advertises 48,000 Hz and contains
95,845 samples over about 1.99677 seconds. A-4 measures 440.4 Hz at playback;
the length-limited tone stops after about 81.8 ms. Each capture must agree
with emulated duration within 2 ms and each tone with its timer frequency
within 0.5%. A copy with a deliberately wrong sample-rate header must fail
both checks.

The retained [results](verification/evidence/results.json) identify source,
ROM, capture and emulator hashes; [baseline](verification/evidence/baseline.json)
identifies the original page and what was wrong with it. Regenerate results
when the routine or capture path changes. The [run record](verification/evidence/run.md)
names the emulator revision and the separately executed APU regressions.

Hardware sources: NESdev Wiki, [APU Pulse](https://www.nesdev.org/wiki/APU_Pulse),
[APU Sweep](https://www.nesdev.org/wiki/APU_Sweep) ("Muting"),
[APU Length Counter](https://www.nesdev.org/wiki/APU_Length_Counter),
[APU Frame Counter](https://www.nesdev.org/wiki/APU_Frame_Counter) and
[APU DMC](https://www.nesdev.org/wiki/APU_DMC), as extracted to the 198x
reference library on 2026-04-22. These are community hardware research. The
results are emulator observations, not original-hardware tests or listening.
