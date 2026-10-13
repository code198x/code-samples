# Source-generated 48K snapshot diagnostic

Restoring this snapshot and running it produces alternating white/black screen
columns and computes `$5A,$5B` at `$7000`. Those completion bytes start at zero;
loading a file successfully is not completion. The source is MIT-licensed.

```sh
asm198x --dialect pasmo --sna diagnostic.asm -o diagnostic.sna
```

Asm198x 0.0.63 emits a 49,179-byte 48K SNA. PasmoNext 0.1.3 independently emits
identical bytes with `pasmo --sna diagnostic.asm diagnostic.sna`.
The four data bytes at `$8000` deliberately separate origin from entry `$8004`.
The SNA saves that entry on its stack at `$FFFC`; restoration pops it and leaves
SP at `$FFFE`. The diagnostic sets its own stack and disables interrupts before
using RAM. Completion loops at `$8038`.

There is no DEVICE directive, ROM call or booted system-variable assumption.
The no-DEVICE assembler contract supplies zero RAM, `$38` attributes and the
register defaults. This makes the generated snapshot redistributable without
embedding firmware-derived RAM. A legitimate local ROM is still required by
the runtime configuration; do not package it with this fixture.

Run the full native-format, restoration and fresh-execution checks from the
[umbrella qualification runner](https://github.com/stevehill1981/198x/tree/main/ops/qualification):

```sh
python3.13 ops/qualification/snapshot.py --rom "$SPECTRUM_ROM"
```

That command uses source builds; its documentation also names verified release
binaries. Emu198x uses `load_snapshot`, observes registers and all 48K RAM before
running, then watches four program-originating signature writes and checks RAM
and rendered pixels. The independent MAME route uses its native SNA reader.
This is portable restoration, not ROM tape loading or a curriculum load recipe.

The bounded claim covers this initial 48K snapshot only. Nonzero initial general
registers, captured save/diverge/restore states, 128K banks, other snapshot formats,
interrupt-boundary fidelity, peripherals and firmware calls need separate tests.
