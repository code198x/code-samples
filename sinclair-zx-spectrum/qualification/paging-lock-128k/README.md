# Spectrum 128K RAM paging-lock diagnostic

A successful run draws white stripes on black with a green border and writes
`5A 5B` to `$7000`. Failure loops with a red border without that signature.
Source and generated program bytes are MIT licensed.

The program first writes distinct markers `A0`–`A7` to offset `$3B00` in all
eight RAM banks, then reads them back into `$7010`–`$7017`. It selects bank 3
and sets bit 5 of `$7FFD` with `$33`. Its initial read and eight further reads,
after attempted selections `$10`–`$17` (each with bit 5 clear), must all see
`A3`. These actual readbacks go to `$7020`–`$7028`. A final write through
`$FB00` stores `C3`; its readback goes to `$7029`. All observations are recorded
before checking the lock. Only success produces the screen and signature.

Code stays in fixed bank 2 at `$8000`, the stack below `$BF00`, and observations
in fixed bank 5. Marker aliases `$BB00`/`$7B00` avoid code, stack, screen and
observations. Interrupts stay disabled; reset to exit. The raw program is
169 bytes, `complete` is `$80A1` and `failed` is `$80A3`.

From the family workspace root, with Asm198x on PATH:

```sh
asm198x --dialect pasmo --cpu z80 --tapbas \
  Code198x/code-samples/sinclair-zx-spectrum/qualification/paging-lock-128k/diagnostic.asm \
  -o diagnostic.tap
python3.13 ops/qualification/run.py --recipe 128k-paging-lock \
  --rom "$HOME/.emu198x/roms/sinclair-zx-spectrum-128k/128-0.rom" \
  --rom1 "$HOME/.emu198x/roms/sinclair-zx-spectrum-128k/128-1.rom"
```

The runner checks BASIC+CODE TAP structure and metadata, cold-boots the named
UK 128K ROM pair, selects Tape Loader with keyboard automation and lets the ROM
decode tape pulses. BASIC loads at `$8000` and calls `RANDOMIZE USR 32768`.
No injection or snapshot restoration is involved. See the umbrella runner guide
for pinned release downloads and `--release-tools`.

Pasmo independently assembles the same tape. SkoolKit independently loads via
ROM pulses from prepared BASIC state and checks all physical bank markers:
`A0 A1 A2 C3 A4 A5 A6 A7`. Its output snapshot is inspected locally, never
restored into Emu or published. The `--omit-paging-lock` control changes only
`lock_value` from `$33` to `$13`, preserving all addresses and a valid tape;
both runtimes must fail execution.

The hardware basis is the bank-register table in section 1.3 of the
[Sinclair ZX Spectrum 128 Service Manual](https://spectrumforeveryone.com/wp-content/uploads/2017/11/ZX-Spectrum-128-Service-Manual.pdf),
printed page 6: bits 0–2 select RAM and bit 5 prevents further register access.
This fixture tests RAM selection lock on one named configuration. It does not
qualify reset clearing, ROM or shadow-screen lock effects, timing, full RAM
integrity, alternate port decoding, expansions, other ROMs or other models.
Broader coverage remains [198x #67](https://github.com/stevehill1981/198x/issues/67).
