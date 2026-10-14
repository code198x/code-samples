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

## Track and directory-extent diagnostic

`large.asm` builds 20 KiB of CODE at `$8000` using the same loader:

```sh
asm198x --dialect pasmo --cpu z80 large.asm -o large.bin
build198x plus3 --basic loader.bas --code large.bin --load-address 32768 -o large.dsk --format json
```

The program checks every byte from `$8040` to `$CFBF` against the high byte
of its address, giving each page a distinct value. It
then jumps to `$CFC0` to draw the same striped screen and compute `5A 5B` at
`$7000`. It loops at `$CFE9`. A filler mismatch stops in a red-border loop
without writing completion. The fixture is MIT licensed.

Including its 128-byte +3DOS header, DIAG.BIN occupies 161 records of 128 bytes:
128 in extent zero and 33 in extent one. The standard writer allocates 21
1 KiB blocks across tracks 1–6. Both the checked data and the executed tail
cross the first extent boundary, which lies at CODE address `$BF80`.
The umbrella runner independently compares all 20,480 loaded bytes, so neither
padding a small program nor process success alone proves the larger transfer.

This remains a contiguous two-extent file on one standard disk geometry.
Fragmented allocation, reordered directories, more extents and writes are
separate work. Use an Asm198x release containing the Pasmo `DEFS count, fill`
repair (asm198x/asm198x#628); release 0.0.63 rejects that syntax.
