# Install pictures once; select them many times

These four components separate pattern storage, screen names and colour state.
They implement init, install, replace and select; they are not text layout engines.
The pictures and reset callers are original MIT-licensed Code198x assets.

| Target | Allocations | Component/context | Replacement / selection / init writes |
| --- | --- | --- | --- |
| C64 hi-res text | $2000–$27FF font, $0400–$07E7 names | 238 / 24 bytes | 8 / 1 / 3,048 |
| NES NROM-256 CHR-RAM | PPU $0000–$0FFF font, $2000–$23BF names | 258 / 24 bytes | 16 / 1 / 5,056 |
| Master System Mode 4 | VRAM $0000–$37FF patterns, $3800–$3DFF names | 239 / 32 bytes | 32 / 2 / 15,872 |
| Game Gear Mode 4 | Same VRAM allocation, 160×144 viewport | 239 / 32 bytes | 32 / 2 / 15,872 |

Counts are destination data bytes, not control-port writes, elapsed cycles or frame budgets.
Every accepted Sega operation also sends address bytes to the control port. The
conservative port spacing is qualified on the named release, not measured hardware.

## C64 and NES: the 24-byte G context

Reserve G in private zero page. Words are little endian. Inputs survive.

| Offset | Field |
| --- | --- |
| 0 | CPU source address, word |
| 2 | First slot, byte |
| 3 | Count, byte, 1–255 |
| 4 | Selected character code, byte |
| 5 | Linear screen cell, word |
| 7 | Output: 1 accepted, 0 rejected |
| 8 | Output: destination bytes written, word |
| 10–23 | Private scratch |

`glyph_init` clears owned font and names. `glyph_install` validates then uploads
first/count; an exclusive end of 256 is legal. `glyph_replace` uploads one slot,
ignoring count. `glyph_select` writes one name. All byte codes are valid. Zero
counts, overflowing ranges and cells outside 0–999 (C64) or 0–959 (NES) reject
without destination writes. Full 256-slot replacement needs multiple calls because
count is a byte. Reserve six stack bytes including the direct call; registers and
flags are clobbered. Clear decimal mode. No interrupt or bank state is changed.

C64 rows are eight one-bit bytes, bit 7 leftmost. Set VIC bank 0, $D018=$18,
$D011=$1B and $D016=$08; the caller uses CPU mapping $37. Colour RAM belongs to
the caller; the component preserves it and the 24 bytes of screen padding. This
caller starts with blank RAM and original pictures. It does not copy a manufacturer
ROM font, retain BASIC/KERNAL services, or establish coexistence with interrupts.
A ROM-font-copy wrapper remains separate work under #128.

NES rows are eight low-plane bytes followed by eight high-plane bytes. The explicit
iNES header declares two PRG banks and **zero CHR-ROM banks**. The cartridge must
provide CHR-RAM; a CHR-ROM cartridge cannot use this upload implementation. Rendering
must be off; own $2005/$2006 latch and increment-one access, NMI and mapper state for
the entire call. $2001 is write-only, so the routine cannot validate that policy.
Restore address/scroll/control before resuming display. Attribute bytes, palettes,
the other CHR bank and other nametable allocation remain untouched. These are bulk
blanked transfers, not a VBlank queue. A different mapper needs its own bank contract.

The pinned assembler's default ca65 NES linker emits an extra empty 8 KiB CHARS
segment. `master_nes` checks the header, accepts only the declared extent or this
known zero padding, rejects nonempty undeclared data and writes exactly 32,784 bytes.
It does not turn CHR-ROM into RAM by deleting data. Tests reject contradictory headers
and discarded assets.

## Sega: the 32-byte P context

Define P in private RAM, then include the machine's `glyphs.inc`. Both wrappers
include `mode4.inc` unchanged. All words are little endian.

| Offset | Field |
| --- | --- |
| 0 | CPU source address, word |
| 2 | First pattern, word |
| 4 | Count, word |
| 6 | Selected pattern, word |
| 8 | Linear cell, word |
| 10 | Attribute byte |
| 11 | Output: accepted status |
| 12 | Output: destination data bytes written, word |
| 14,15 | Data/control ports ($BE/$BF) |
| 16–31 | Private scratch |

`pattern_init/install/replace/select` have the same roles, but deliberately use
word indices and counts. Inputs 0–10 and ports survive; AF/BC/DE/HL and flags are
clobbered. Reserve eight stack bytes including the direct call. No DI/EI is hidden
inside the component. Own the latch, stable source bank, interrupt/NMI policy and
VRAM allocation for the entire call. Source addresses are trusted, readable,
non-wrapping and disjoint from context/destination; validation is not a memory sandbox.

The hardware has 512 pattern slots. This allocation owns **448**, because its name
and sprite tables occupy the upper region. Valid indices are 0–447, counts 1–448
when first+count<=448, cells 0–767. Invalid requests return status/count zero without
writes. Each pattern has 32 bytes: four bitplanes per row, eight rows. A cell is
low index byte followed by index bit 8 plus attributes. Supply only bits 1–4:
H flip=$02, V flip=$04, palette 1=$08, priority=$10. The ninth index bit comes from
the selected word, not the attribute input. Other bits reject.

The caller owns both palettes, mode registers and sprite table. SMS palette entries
are one byte; Game Gear entries are two bytes. Game Gear displays a centred 160×144
window of the 256×192 background. Its top-left displayed point corresponds to logical
(48,24). Changing display mode or allocation needs a separately checked variant.
Priority bits are checked as name data; this no-sprite fixture does not verify sprite
priority interactions. Flips and both palettes have independent native pixel checks.

## Use the routines

Each machine directory contains the reusable include, a complete reset caller and
Makefile. Its `example_install` section demonstrates include/init/install/select;
point the source at a new sketch and call replace to change all instances of a slot.
Change one cell's code instead when only that instance should change. The command
mailbox and memory-copy diagnostic are optional verification transport, not a game API.

For cell (x,y), use `y*columns+x`. Slot n, row r starts at base+n*bytes_per_pattern:
C64 adds r; NES adds r and r+8; Sega adds 4*r+plane. These are practical uses of
row-major indexing, powers of two and bit masks, linked from Maths for Games unit 13.
A name costs 1 or 2 writes; a shared pattern costs 8, 16 or 32 irrespective of how
many cells use it. Choose based on how many instances should change, not a universal
claim that either operation is faster.

## Verification and limits

Asm198x 0.0.71 and independent Emu198x 0.39.0 processes execute 20 calls on C64/NES
and 40 on each Sega target, per build. Three builds per target include completed
wrong-slot and wrong-name controls: **360 calls and eight faulty builds**. Complete
font/name/guard allocations and selected whole native RGBA frames are compared with
an independent logical compositor; tests cover slot/cell ends, 255/256, counts,
rejects, shared replacement, reset, flips and palettes. Inputs, source data and actual
data-write counts are checked. Retained checks rederive the expected memory/pixels;
rehashing corrupt evidence cannot make it pass.

C64 colour RAM is read by executing CPU loads into a private diagnostic buffer,
because debugger memory reads intentionally inspect underlying RAM. NES observes
16 KiB logical PPU memory; page $3E00 is read through its physical $2E00 mirror to
avoid the buffered-read/palette boundary at $3F00. Palette reads are masked to six
bits. Sega reads all 16 KiB VRAM. Native frames use the pinned release's palettes;
they do not claim universal analogue RGB values.

Run `scripts/verify-native-glyphs.py --native <locked-tools> --assembler <locked-asm>`
to regenerate, review and copy build/verification to verification. Run
`scripts/check-native-glyphs.py` and `python3 -m unittest discover -s scripts -p test_native_glyphs.py -v`
to replay retained evidence and corruption controls. Toolchain hashes are in toolchain.json.
No manufacturer firmware, physical-machine timing, stock-OS loading, interrupt
coexistence, tear-free live updates or sustained throughput is established here.

## Hardware references

- Commodore, *Commodore 64 Programmer's Reference Guide* (1983), Programming Graphics,
  character memory, VIC-II memory pointer $D018 and CIA2 VIC-bank selection.
- Ricoh, RP2C02 development specification KA-A002-B (1982-10-12, revised 1982-12-03),
  register table p21: CTLR1 write-only, VRAM address/data and increment selection.
  NESdev [pattern tables](https://www.nesdev.org/wiki/PPU_pattern_tables) and
  [PPU registers](https://www.nesdev.org/wiki/PPU_registers) document reverse-engineered
  encoding, latch and buffered-read behaviour; distinguish that provenance from Ricoh.
- Sega, *Software Reference Manual for the Sega Mark III* (1986), video display,
  character pattern and name-table format; the Game Gear variant uses 12-bit CRAM
  and its native viewport. The independently qualified caller preserves that difference.
