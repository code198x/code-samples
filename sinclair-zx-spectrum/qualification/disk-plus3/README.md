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
of its address, giving each page a distinct value. It then jumps to `$CFC0` to draw the same striped screen and compute `5A 5B` at
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

## Fragmented and reordered qualification fixtures

After building and independently validating `large.dsk`, generate a new fixture:

```sh
python3.13 rearrange.py fragmented large.dsk fragmented.dsk > fragmented.json
python3.13 rearrange.py reordered large.dsk reordered.dsk > reordered.json
python3.13 rearrange.py combined large.dsk combined.dsk > combined.json
```

The MIT script accepts only this diagnostic's original directory layout. It
leaves the input unchanged and refuses an existing output. JSON records the
input/output hashes and every block and directory-entry move. It uses no extra
dependencies. Run its checks with `python3.13 -m unittest test_rearrange.py -v`.

Fragmentation places CODE's 21 logical blocks at physical blocks
`3,43,5,41,7,39,9,37,11,35,13,33,15,31,17,29,19,27,21,25,23`.
Copies use the original bytes, including where old and new locations overlap.
Directory reordering places extent 1 in slot 0, `DISK` in slot 2 and extent 0
in slot 17, with deleted entries in the gaps. This makes the loader find the
first extent in the second directory sector. `combined` applies both changes.
The loader and program bytes are unchanged. The original data disk has no
executable boot sector; all runs still enter through the normal ROM Loader.

These are fixed qualification fixtures, not production Build198x layout
options or a general disk editor. The umbrella runner independently validates
both original and rearranged images before execution, records fixture preparation
separately from mastering, and compares every loaded CODE byte. Results apply
only to the exercised arrangements; other permutations remain untested.
Production mastering options are a later follow-up under
[Build #6](https://github.com/build198x/build198x/issues/6).

## Final allocation block and directory slot

`python3.13 rearrange.py boundary large.dsk boundary.dsk > boundary.json`
relocates the full file block originally at physical block 22 to block 174,
and puts CODE extent 1 in directory slot 63. The other blocks retain their
original placement; DISK and extent 0 remain in slots 0 and 1. The unused slots
are deleted entries. The input is still the original validated `large.dsk`.

Block 174 covers track 39 sectors 7 and 8. Both contain diagnostic bytes that
load at `$CB80–$CF7F` and are checked before completion. The trailing sector 9
is outside the type-0 allocation area and remains unchanged. This is the last
allocation block and last directory slot, not a full-disk or full-directory
test. No new production mastering option is implied.

## Full directory search

`python3.13 rearrange.py full-directory large.dsk full-directory.dsk > full-directory.json`
adds 61 unrelated one-byte CODE files, `FILL0000.BIN` through `FILL0060.BIN`,
in slots 0–60. Each owns a distinct block (24–84), a checksummed +3DOS header,
and two 128-byte records; its one-byte payload is its index, 0–60. The remaining
slots 61–63 hold the unchanged `DISK` and two `DIAG.BIN` extents. CODE keeps its
original contiguous blocks 3–23. All 64 directory entries are occupied.

The original files, boot sector and unused blocks are preserved. JSON records
all added files with their slots, blocks, lengths and hashes, as well as the
three directory moves. Occupied destination blocks and existing output files
are rejected. The umbrella independently validates all 63 files and the exact
64-entry directory before normal ROM loading and newly observed execution.

This tests finding the loader and CODE past valid unrelated files in a full
directory. It does not test opening the filler files, file creation or directory
exhaustion errors, full disk allocation, deletion or writes. It remains a fixed
qualification fixture; production mastering options belong to later Build #6 work.
