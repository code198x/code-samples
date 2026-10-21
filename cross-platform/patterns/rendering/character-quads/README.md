# A bigger character is four ordinary characters

Give a title, score digit or sign more room without a bitmap renderer. Prepare a
16×16 picture as four 8×8 tiles, install them in four consecutive slots, and call
`quad_select` to place their codes in a 2×2 screen rectangle. The six original
Graphics I callers reuse the existing MSX upload component unchanged. The source
art, reset fixtures, converter and placement routine are MIT licensed.

## Prepare, include, initialise, call

`prepare.py` doubles each dot of an eight-byte 8×8 source into a 2×2 square.
It writes exactly 32 bytes, in **top-left, top-right, bottom-left, bottom-right**
tile order, eight row bytes per tile, bit 7 leftmost. It runs on the host:

```sh
python3 cross-platform/patterns/rendering/character-quads/prepare.py \
  cross-platform/patterns/rendering/character-quads/f.bin /tmp/large-f.bin
```

The checked-in `assets.inc` is that same result in assembler form, followed by
an independently prepared arrow. Each `demo.asm` includes its actual wired
caller. `customise.asm` selects the arrow with `ASSET_OFFSET=32`, slot 16 and a
first cell of 734: the last legal 2×2 origin, column 30 row 22. Its second copy
is at cell 330. The ordinary F starts at slot 8, at cells 330 and 334.

Reserve **24 writable bytes at G** for the existing upload component and
**eight separate writable bytes at Q**. Set G+10/G+11 to the target's data-write
and control ports. Establish Graphics I, colours and sprite policy exactly as
in the existing custom-glyph caller, then call `glyph_init` once. It erases the
owned font and names, not the colours or registers. Include both:

```asm
    include "msx/patterns/assembly/rendering/custom-glyphs/glyphs.inc"
    include "cross-platform/patterns/rendering/character-quads/z80.inc"
```

Paths above are relative to the repository root; the complete callers supply
folder-relative paths. Set G+0 to 32 readable prepared bytes, G+2 to the first
slot and G+3 to 4, then call `glyph_install`. `prepare.inc` shows those exact
statements followed by the two placement calls. A game needs neither the reset
fixture nor its mailbox/snapshot transport.

## Placement contract

| Q offset | Meaning |
| --- | --- |
| 0 | First of four consecutive slot codes, byte 0–252 |
| 1 | Little-endian cell-index word |
| 3 | Output: 1 accepted, 0 rejected |
| 4 | Output: 4 name data bytes written, or 0 |
| 5–7 | Private scratch |

Inputs 0–2 survive. All 24 G bytes survive placement, including its upload
results and wired ports. AF/BC/DE/HL/flags are clobbered; no alternate registers,
IX/IY, banks or interrupt enables are changed. Reserve twelve stack bytes
including the direct call, plus the caller/interrupt requirements. The routine
is non-re-entrant. Q and G must be private, writable and disjoint from each
other, code, stack and source assets.

The index is `row*32+column`. Accepted origins have **column 0–30 and row 0–22**.
The last is 734; its bottom-right cell is 767. An origin in column 31, row 23,
or outside the screen rejects before any VDP access. First slot 252 is legal:
its tiles use 252–255. First 253–255 rejects before writing. Both outputs reset
even after a previously accepted call. There is no clipping, wrapping or implied
font allocation: the caller must have installed all four codes and owns their
colours. Slot zero is valid, but replacing it also changes blank screen cells
which still select zero.

Placement changes four names only. It leaves the font, colours, sprites,
registers and all other names alone. Erase an old instance explicitly before
moving it. A repeated placement at the same origin is allowed. Replacing any
one shared tile changes every screen cell that selects that slot, including
other large characters that share it.

## Native interfaces stay visible

| Machine | Data write / control / read | G / Q | Reset image |
| --- | --- | --- | --- |
| ColecoVision | $BE / $BF / $BE | $6200 / $6220 | original 8 KiB bios |
| Sord M5 | $10 / $11 / $10 | $7200 / $7220 | original 8 KiB rom |
| Memotech MTX | $01 / $02 / $01 | $F200 / $F220 | original 24 KiB rom |
| Tatung Einstein | $08 / $09 / $08 | $8200 / $8220 | original 8 KiB mos |
| SVI-328 | $80 / $81 / $84 | $8200 / $8220 | original 32 KiB rom |
| SG-1000 | $BE / $BF / $BE | $C200 / $C220 | original 32 KiB cart |

These are original replacements for reset firmware, not manufacturer software,
OS loading or game-cartridge integration. ColecoVision and SG-1000 retain their
1 KiB CPU RAM limits and 256-byte diagnostic buffer. SVI reads through $84 but
uploads through $80. Each target executes separately; sharing Z80 code and a
VDP does not establish another port's behaviour.

Own the VDP address latch and every interrupt/NMI user for the **whole** call.
There is no hidden DI/EI. DI alone does not mask console NMI. The reset callers
disable VDP interrupts and own foreground video access. The retained conservative
NOP port spacing is qualified only on the pinned emulator's default clock/video
configuration. This is not a VBlank queue, physical bus-timing measurement,
frame-budget or tear-free animation claim.

## Make it your own

Choose the supplied arrow by changing `ASSET_OFFSET` from 0 to 32, choose first
slot 16, and move the first origin to 734. The customised caller is built and
executed independently: the arrow appears in the lower-right corner, with its
second instance in the middle. No extra scratch or placement code is needed;
each installed shape still takes 32 pattern bytes and each instance four names.

To draw a purpose-designed 16×16 letter rather than enlarge eight dots, replace
all 32 bytes in TL/TR/BL/BR order. Do not pass a single eight-byte sketch to an
upload declaring four tiles; it would read 24 bytes beyond the supplied asset.
The converter rejects source lengths other than eight, but the existing upload
API trusts its CPU source pointer. Keep all bytes readable, non-wrapping,
disjoint from contexts, and stable in the selected bank throughout upload.

Four consecutive tiles need not start at a multiple of four for the placement
routine, but Graphics I shares colours by **groups of eight slots**. Slots 8–11
share one colour byte; slots 5–8 cross two groups. Use a four-slot-aligned start
if one colour group is desired, and set that group's colour separately.
Changing another tile in that group can affect its colour too. The fixture uses
white-on-black throughout; it does not qualify a colour-animation policy.

## Common mistake: step one cell instead of one row

The deliberately broken fragment uses `ld de,1` for the bottom-row step.
It completes with status 1 and four data writes, but the lower tiles land beside
the upper tiles. One overwrites the top-right name. All writes are in VRAM; the
picture and name geometry are wrong. The maintained fixed fragment restores
`ld de,32`. Its independently executed binary is byte-identical to the normal
caller. Check four name positions and the visible F; successful completion
alone cannot prove correct placement. Broken code is kept only in `mistakes/`
and explicitly selected diagnostic builds.

## Maths and cost

For local output dot (x,y), the expanded source dot is `(x div 2,y div 2)`.
For tile (tx,ty), its number within the group is `ty*2+tx`; screen cell is
`origin + ty*32+tx`. This is integer division, row-major indexing and translation,
not a new hardware character size. The VDP still fetches ordinary 8×8 tiles.
The native frame uses the emulator's TV framing; 16 stored dots do not guarantee
a physically square image on every display.

One prepared glyph needs **32 asset bytes and four slots**, versus eight bytes
and one slot for its source. There is no runtime pixel resampling. Upload writes
32 pattern data bytes plus two address-control bytes. Each placement writes
**four name bytes plus four address-control bytes**, versus one plus two for a
single cell. Q+4 counts only name data, not total CPU accesses or elapsed cycles.
The shared placement code is **92 bytes**; unchanged upload code is **205 bytes**;
contexts total **32 RAM bytes**. Caller setup, stack, diagnostic buffer and reset
ROM padding are additional. The converter runs on the host and consumes no game
RAM or CPU time.

At most 64 disjoint four-tile glyphs fit in 256 slots before blank/UI/game tiles
are reserved. Reusing identical tiles can save slots but needs a non-consecutive
four-code map and a separately verified API. Runtime bitmap scaling allows
other sizes/positions at a different draw/storage cost; prebuilt banks trade ROM
and switching policy for less work while playing. This routine does not supply
strings, metrics, wrapping, arbitrary positions, larger grids or a bank cache.

## Verification

```sh
python3 scripts/verify-character-quads.py --native /path/to/locked-tools --assembler /path/to/locked-asm
python3 scripts/check-character-quads.py
python3 -m unittest discover -s scripts -p test_character_quads.py -v
```

`toolchain.json` retains the exact qualified Asm198x 0.0.71 and six Emu198x 0.39.0
release/archive/binary/source-lock identities. Each machine completes 893 native
observations: 868 normal calls, seven calls in each customised/faulty/repaired
build, and four startups. This covers every screen origin (including rejected
edges), slots 0/252 and invalid ends, colour-group boundaries and word indices
768/65535. Complete 768-byte name tables, public inputs, status, write count,
unchanged upload context and CPU guards are checked after every call. Selected
full 16 KiB VRAM snapshots and whole native frames check other resources and
visible output. The independent compositor uses logical screen coordinates;
the asset oracle selects source dots rather than repeating the converter's
nibble expansion.

Retained checks require exact observation/source/tool sets and recompute the
picture and geometry, rather than trusting stored pass flags or hashes. Tests
exercise every source pixel and all 256 row values in every source row, and
reject rehashed corrupt names/VRAM/pictures, changed guards, missing calls/builds
or source bindings, and an unknown machine. Native evidence is specific to
these six default/reset configurations, not original hardware or every mode.

Hardware/port claims reuse the primary references in
[the six TMS glyph contracts](../tms-glyphs/README.md#primary-references), including
the TI TMS9918A/TMS9928A/TMS9929A data manual's Graphics I tables and CPU interface.
No new port, register layout or timing capability is inferred here.
