# Spectrum beeper feedback

The maintained source for the Sound Beep pattern. Target: stock 48K PAL,
code at $8000, stack at $FF00, no peripherals. `make` builds `demo.tap`;
load it with `LOAD ""` and start tape playback. It plays one fixed tone,
an eight-note rising sweep, the reversed sweep and a short click, then waits.

The tone contract is in `sound-beep.inc`. H controls each half-period's
DJNZ count; L controls complete cycles. Both must be 1–255. Zero wraps to
256 iterations, so it is not a silent or zero-length request. The caller
disables maskable interrupts and owns restoring them. The demo enables the
ROM interrupt only between sounds and after the sequence. This is blocking
feedback, not a background audio engine.

`ula_output` owns bits 0–3: border and MIC. The routine masks other bits,
toggles bit 4, and returns with bit 4 clear. All ULA writers in an integrated
game must share this state; it cannot read back the output latch. Preserving
MIC's chosen digital bit does not disconnect the analogue cassette output.

Without contention or interrupts, the interval between rising writes is
`26*H+51` T-states. At a nominal 3.5 MHz, H=255 gives 523.9 Hz and H=127
gives 1043.8 Hz. Doubling L at H=127 approximately preserves the length of
H=255; it does not change pitch. Each sweep keeps sixteen cycles per note,
so its higher notes are shorter. This is a rising/falling effect, not a
musical scale. Port contention adds small timing differences on the 48K.

Run the executable check with:

```sh
python3 verification/verify.py --emulator /path/to/emu198x-spectrum --output /tmp/sound-beep
```

Add `--pasmo /path/to/pasmo` for an alternate-assembler byte comparison.
The check builds complete standalone callers, observes every port write,
measures PCM crossings, verifies pitch/length independence and sweep order,
checks preserved registers and return state, and reloads the demonstration
through the ROM's tape path. Output goes to the supplied directory; samples
and firmware are not rewritten. The emulator needs a configured 48K ROM.

The retained [results](verification/evidence/results.json) identify source and
emulator hashes and measured cases; [baseline](verification/evidence/baseline.json)
identifies the original page. Regenerate results when the routine changes.

Baseline: the website pattern's fenced source at website revision
`823e571fbfb67cd4db408adf3f695d46019bb391` is identified by its exact hash in the verification record rather
than treated as executed evidence. HL was a repetition count while the
delay stayed fixed, and its second routine's `.delay` call depended on
ambiguous local-label scope. The replacement uses distinct global labels.

Hardware sources: Sinclair's *ZX Spectrum BASIC Programming*, chapter 23
(output port 254), and Zilog's *Z80 CPU User Manual*, UM008011-0816,
DJNZ and OUT instruction tables. Timing above is a derivation from this
routine; PCM and bus results are emulator observations, not hardware tests.
