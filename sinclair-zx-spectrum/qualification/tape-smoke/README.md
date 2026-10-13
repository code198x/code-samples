# Spectrum ROM tape diagnostic

A successful run shows thin white vertical stripes on black with a green border.
The program fills all 6,144 bitmap bytes with `AA`, all 768 attribute bytes with
`47`, then computes and writes `5A 5B` at `7000`. It loops at `8034` afterwards.

The source is MIT licensed under this repository's licence. It contains no ROM
bytes or third-party assets. It requires at least 48 KiB RAM; it is **not** a
16K diagnostic. It makes no paging, sound, expansion or timing-accuracy claim.

Build with Asm198x (the filename is part of the tape header):

```sh
asm198x --dialect pasmo --cpu z80 --tapbas diagnostic.asm -o diagnostic.tap
```

Boot a Spectrum 48K with its normal ROM and type `LOAD ""`, then play the tape.
The BASIC loader sets BASIC's RAM limit to `7FFF`, loads CODE at `8000`, and
calls `RANDOMIZE USR 32768`. Do not import the code into RAM or restore a snapshot to
claim tape-loading evidence.

For the current Emu198x CLI:

```sh
emu198x-spectrum --machine spectrum_48k --rom "$SPECTRUM_ROM" \
  --tape diagnostic.tap --autoload-tape --frames 2000 \
  --screenshot screen.png
```

The screenshot command is a convenience, not a qualification assertion. The
cross-stack runner checks the ROM-loaded bytes at `8000`, observes zeroes at `7000` before
loading, watches the program's stores change them, checks the completion
loop, and compares every screen RAM byte after a bounded 2,000-frame run. Neither the
screen nor the completion word occupies the tape CODE payload.

Asm198x 0.0.61 and later preserve native tape output with JSON reporting;
[Asm198x #619](https://github.com/asm198x/asm198x/issues/619) records the fix.
The qualification runner retains separate invocations to support older source
baselines and independently compares the raw bytes and native payload.
