# Spectrum +3 ROM disk diagnostic

A successful run shows thin white stripes on black with a green border. This
reuses the MIT [tape diagnostic](../tape-smoke/diagnostic.asm): it computes
`5A 5B` at `$7000`, fills screen RAM and loops at `$8034`.

From this directory, with Asm198x and Build198x installed:

```sh
asm198x --dialect pasmo --cpu z80 ../tape-smoke/diagnostic.asm -o diagnostic.bin
build198x plus3 --basic loader.bas --code diagnostic.bin --load-address 32768 -o diagnostic.dsk --format json
```

Insert the DSK in drive A of a Spectrum +3, cold boot its normal ROM, and press
Enter on **Loader**. It loads the BASIC file `DISK`, whose first line sets
RAMTOP below the CODE, then loads `DIAG.BIN` and calls `$8000`.
The disk has no executable boot sector. The space before `CODE` is intentionally
absent in the listing: the Spectrum token supplies its display spacing.

The authored loader is MIT licensed under this repository's licence. No ROM
bytes, snapshots or third-party assets are included. This fixture covers one
standard single-sided 40-track +3DOS loading route. It does not test writeback,
other disk geometries, protection, banked programs or expansion hardware.

The umbrella qualification runner checks the DSK container, directory, +3DOS
headers and recovered payload, then observes new execution through the actual
ROM/FDC path in Emu198x and independently in MAME. A screenshot or successful
process exit alone is not qualification.
