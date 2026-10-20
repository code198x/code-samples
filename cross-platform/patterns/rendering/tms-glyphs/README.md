# Change the picture, or change one place

A door can appear twice without storing its eight rows twice. Put code 1 in two
screen cells and both use pattern 1. `glyph_replace` changes that shared picture;
`glyph_select` changes one cell's number. These six Graphics I ports reuse the
maintained MSX Z80 include unchanged. Each has its own original caller and native
execution, because wired ports, CPU RAM and video framing are machine contracts.

## Include, initialise and call

Reserve 24 private bytes at `G`, and set `G+10` to the **write data port** and
`G+11` to the control port. Include
`msx/patterns/assembly/rendering/custom-glyphs/glyphs.inc` from the code-samples
root, or use the relative include in the complete caller. It requires no other
code. It destroys AF/BC/DE/HL/flags, preserves public inputs 0–6 and ports 10–11,
returns through RET, and needs ten stack bytes including nested calls. Add your
own callers and interrupts. It is non-re-entrant and does not execute DI/EI.

Configure Graphics I: patterns $0000–$07FF, names $1800–$1AFF, 32×24 cells,
colour bytes at $2000–$201F, sprite attributes at $1B00 and sprite patterns at
$3800. The complete caller writes VDP registers `00 C0 06 80 00 36 07 F1`,
disables VDP interrupt generation and uses a sprite-list terminator. This fixture
owns the foreground CPU, VDP registers and all VRAM; a running game can reserve
only the component's font/name allocations but must coordinate its other users.

`glyph_init` blanks the 2,048 font bytes and 768 name bytes. It leaves colours,
sprites and registers to the caller. Call it once after video setup; calling it
again erases the whole owned font and screen. It does not copy a ROM font.

Supply these fields, then call the entry directly:

| Offset | Field |
| --- | --- |
| 0 | Little-endian word: readable CPU source pointer |
| 2, 3 | Byte: first slot, nonzero count |
| 4 | Byte: code for a selected screen cell |
| 5 | Little-endian word: cell index |
| 7 | Output: 1 accepted, 0 rejected |
| 8 | Output word: destination data bytes written |
| 10, 11 | Caller-supplied write data/control ports |
| 12–23 | Reserved private context bytes |

`glyph_install` copies count glyphs, `glyph_replace` copies one and ignores
count, and `glyph_select` changes one name entry. Valid slots/codes are 0–255;
counts are 1–255 and `first + count` must not exceed 256. To install all 256,
use two calls. Cells are 0–767. Zero counts, overflowing slot ranges and invalid
cells reject before any destination write; status and count still reset.
Source pointer and irrelevant input fields are ignored by init/select as
appropriate. A source is trusted: it must remain readable for all `count*8`
bytes, not wrap the CPU address space or overlap the context. The routine does
not validate bank mappings or ROM/RAM allocation. It does not copy from VRAM.

## Six wired interfaces

| Target | Data write / control / data read | Fixture CPU RAM and loader |
| --- | --- | --- |
| ColecoVision | $BE / $BF / $BE | buffer $6000–$60FF, G $6200, stack $63F0; original bios image, 8192 bytes |
| Sord M5 | $10 / $11 / $10 | buffer $7000–$70FF, G $7200, stack $7FF0; original rom image, 8192 bytes |
| Memotech MTX | $01 / $02 / $01 | buffer $F000–$F0FF, G $F200, stack $F7F0; original rom image, 24576 bytes |
| Tatung Einstein | $08 / $09 / $08 | buffer $8000–$80FF, G $8200, stack $FFF0; original mos image, 8192 bytes |
| SVI-328 | $80 / $81 / $84 | buffer $8000–$80FF, G $8200, stack $FFF0; original rom image, 32768 bytes |
| SG-1000 | $BE / $BF / $BE | buffer $C000–$C0FF, G $C200, stack $C3F0; original cart image, 32768 bytes |

SVI's read port is $84, while uploads use $80. Never derive one from the other.
These TMS devices are **port-accessed**, not CPU bitmap RAM. An interrupt or
another renderer changing the two-write VDP address latch can redirect the
transfer. Disable or coordinate every VDP user for the complete call; DI alone
does not mask a console NMI. The original callers disable VDP interrupts and do
not request pause/reset inputs. They replace the reset firmware, so the result
is not a stock BASIC/MOS/BIOS or cartridge-startup integration claim.

The shared OUT helper retains its conservative fixed NOP spacing. Native checks
cover only the locked emulator's selected default clock/video configuration.
They do not establish physical-device access timing, boosted CPU operation,
VBlank throughput or tear-free animation. A live upload queue and a measured
blanking budget remain separate components. Do not turn the display off and on
per glyph just because the original reset setup owns the whole machine.

## Count the change

Each glyph is eight rows; bit 7 is leftmost. Row `10000001` is 129. Row r of slot
n is at VRAM `n*8+r`. Slot 255 starts at $07F8 and ends at $07FF. Screen cell
(31,23) has index `23*32+31 = 767`, at $1AFF. The next byte is sprite state,
so rejecting cell 768 matters. A picture in slot 8 uses colour byte
`$2000 + (8 div 8) = $2001`: Graphics I shares one foreground/background byte
among eight slots. Glyph uploads never choose colours.

Local dot (3,5) in cell (2,2) appears at pixel (19,21), using `(8*cx+lx,
8*cy+ly)`. Character numbers, placement and colour are different resources;
this arithmetic does not supply proportional text or arbitrary pixel positions.

A replacement writes 8 font bytes plus 2 control-port bytes. A selection writes
1 name byte plus 2 control bytes. Init writes 2,816 data bytes plus 4 control
bytes for its two ranges. Installing 255 glyphs writes 2,040 data bytes plus 2
control bytes. The returned G+8 counter counts data writes only. Those counts
are checked against the native result, not inferred to be elapsed cycles.

The unchanged positive component assembles to 205 code bytes with the pinned
assembler; private context is 24 RAM bytes, font allocation 2 KiB and names
768 bytes. Glyph source assets need 8 bytes each, in readable ROM or RAM.
Caller setup, its 256-byte snapshot buffer and original ROM padding are excluded
from the component size. The buffer is diagnostic machinery, not a game API
requirement. ColecoVision/SG-1000 callers fit their selected 1 KiB RAM maps.

Replacing a shared wall pattern can be cheaper than editing every wall cell.
Opening one door often calls for selecting a different code in one place. A
banked font, pattern cache, Graphics II bitmap, four-plane Sega Mode 4 or
arbitrary-position bitmap text has a different contract and is not supplied by
these routines. Reuse the existing map-region component for many cell changes.

## Verification and retained evidence

Build with `make` in a machine's folder, or run:

```sh
python3 scripts/verify-tms-glyphs.py --native /path/to/tools --assembler /path/to/asm198x
python3 scripts/check-tms-glyphs.py
python3 -m unittest discover -s scripts -p test_tms_glyphs.py -v
```

`toolchain.json` pins released Asm198x 0.0.71 and six Emu198x 0.39.0 executables,
archive hashes and unsigned producer-source locks. Each original ROM/reset
fixture is MIT licensed, with original glyphs and no manufacturer firmware.

Every target runs 24 calls: shared replacement, single-cell selection, slots
0/255, range-end 256, zero/overflow counts, cells 0/767/768/65535, count-ignored
replacement, 255-glyph transfers at first slots 0 and 1, colour-group boundaries,
reset and reuse after reset. After **each** call, compare all 16 KiB VRAM,
public inputs/ports, accepted/rejected status, data-write count, CPU guards and
unchanged RAM/ROM sources. Six selected full native frames per build are
compared with an independent logical glyph compositor, including borders.

Each machine also executes two completed accepted faulty builds: one moves
uploaded patterns to the wrong slot, the other shifts name writes by one byte.
Both must fail memory and native-picture comparisons. A crash or timeout does
not count as this evidence. The retained checker rederives bytes and pixels,
checks complete source/tool/observation sets and rejects corrupt evidence even
when its hashes are recomputed. Unknown machine selections fail rather than
checking nothing. See each machine's `verification/results.json`.

The diagnostic reads 256 VRAM bytes at a time into private CPU RAM so a full
snapshot fits even the small-RAM consoles. Its separate **read** port is target
configuration, not an assumed copy of the write port. Execution qualifies this
code/model/reset configuration only, not a whole emulator, original hardware,
OS coexistence or another display mode.

## Primary references

Port and table choices reuse the named primary sources in the existing
[tile-region contract](../tile-region/README.md#sources), including the TI
*TMS9918A/TMS9928A/TMS9929A Video Display Processors Data Manual*, November 1982,
§§2.1.3–2.1.5, Graphics I tables, CPU interface, auto-increment and address latch;
Coleco's *Technical Manual* CPU/VDP interface; Sord *BASIC-G* Appendix H p.279;
Memotech *Operator's Manual* Appendix 10; SVI-318/328 *Service & Technical Manual*
I/O map; and Tatung *Einstein Hardware Manual* main-board interface/schematic
p.34. Sega's compatible Graphics I port is independently executed here; this is
not an inference that Mode 4 shares the same pattern encoding. Frame windows and
RGB values describe the pinned emulator, not a universal analogue crop/palette.
