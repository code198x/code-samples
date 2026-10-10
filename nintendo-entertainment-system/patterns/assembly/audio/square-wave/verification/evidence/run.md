# NES audio verification — 10 October 2026

All seven complete ROM cases pass in Emu198x at commit
`df2799e220a10de6a3bc0f14f04c6506363cb7d3`, built with
`cargo build --release --locked -p emu198x-nes --no-default-features`.
The sample sources are unchanged from samples commit
`be65631db11bac9127e85a76f448bef3806819a8`.

The run used Asm198x v0.0.58 and Python 3.14.3. `results.json` retains
assembler/emulator binary hashes, verifier/source hashes, cartridge and WAV
hashes, sample counts, both timebases, and individual observations.
`execution.log` is the verifier's output. Reproduction is in the sample README.

Each 120-frame capture contains 95,845 samples at a WAV rate of 48,000 Hz:
1.996771 seconds of playback. The held A-4 measures 440.4 Hz during playback.
The header-only negative control makes that same PCM play at about 448.8 Hz;
both the pitch and duration checks reject it. This closes the old observer's
blind spot: normalising pitch by the observed effective sample rate could
not detect wrongly labelled audio.

Separately, `cargo test --locked -p emu198x-ricoh-apu-2a03 --lib` passed all
77 tests, with none ignored. These include both triangle-hold regressions,
PAL/NTSC sample counts and the advertised-rate pulse pitch test. The relevant
fixes were already present as `c63d1bc3` and `a1f23188`; no emulator code
changed during this verification.

These are native emulator observations. They do not establish browser-player
acceptance, listening quality, analogue fidelity or original-hardware results.
