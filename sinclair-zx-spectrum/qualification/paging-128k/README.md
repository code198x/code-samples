# Spectrum 128K paging diagnostic

A successful run draws white stripes on black with a green border, writes
`5A 5B` to `$7000`, and leaves bank readbacks `A0` through `A7` at `$7010`.
A failed readback loops with a red border and never writes the completion
signature. Source and generated program bytes are MIT licensed.

The program writes one distinct byte at offset `$3B00` in **all eight banks
before reading any back**. This catches missing bank selection and aliased
banks; writing then immediately reading each bank would not. It accesses
`$FB00` via `$7FFD` bits 0–2, preserving ROM 1 and the primary display. Code
runs in fixed bank 2 at `$8000`, the stack is at `$BF00`, and observations are
in fixed bank 5. The bank 2/5 aliases at `$BB00`/`$7B00` do not overlap code,
stack, screen or observations. Interrupts stay disabled; reset to exit.

From the family workspace root:

```sh
Asm198x/asm198x/target/release/asm198x --dialect pasmo --cpu z80 --tapbas \
  Code198x/code-samples/sinclair-zx-spectrum/qualification/paging-128k/diagnostic.asm \
  -o diagnostic.tap
python3.13 ops/qualification/run.py --recipe 128k-paging \
  --rom "$HOME/.emu198x/roms/sinclair-zx-spectrum-128k/128-0.rom" \
  --rom1 "$HOME/.emu198x/roms/sinclair-zx-spectrum-128k/128-1.rom"
```

The runner verifies the BASIC+CODE tape, cold-boots the named UK 128K ROM pair,
selects the menu's Tape Loader with keyboard automation, and lets the ROM decode
tape pulses. BASIC clears below `$8000`, loads CODE there and calls it with
`RANDOMIZE USR 32768`. No injected program or restored snapshot is involved.

The raw program is 114 bytes; `complete` is `$806A`, `failed` is `$806C`.
The runner watches executed signature writes, reads the entire screen RAM and
checks the eight actual bank readbacks. SkoolKit independently loads through its
ROM pulse simulation from prepared BASIC state, then its output snapshot is
inspected for every physical bank marker. That snapshot is never an Emu input.

This tests one byte per bank on the explicitly named configuration. It does
not test full RAM integrity, contention timing, paging lock, alternate port
decoding, shadow screens, ROM selection, AY audio, other ROMs or other models.

References in the family workspace: `reference/by-system/sinclair-zx-spectrum/128k-memory-paging.md`
(Memory Map; Port 0x7FFD), checked against Fuse `machines/spec128.c`.
Broader coverage remains [198x #67](https://github.com/stevehill1981/198x/issues/67).
