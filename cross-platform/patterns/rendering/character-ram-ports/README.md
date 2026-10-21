# Character RAM on Ace, Oric TEXT and Atari XL

A picture can be shared by many cells. These components initialise their owned
ranges, install pictures, replace one shared picture and select a code in one cell.
They supply the same small jobs with different machine contracts. They do not
supply proportional text, arbitrary pixel placement or an upload scheduler.

| Target | Font allocation | Names and codes | Init writes |
| --- | --- | --- | --- |
| Jupiter Ace | TV-priority $2C00–$2FFF, 128×8 bytes | $2400–$26FF, 32×24; bit 7 inverts a 7-bit code | 1,792 |
| Oric Atmos TEXT | Standard set's drawable ASCII 32–127 at $B500–$B7FF | 37×28 logical cells within the 40×28 screen at $BB80; three control columns per row | 1,804 |
| Atari 800XL ANTIC 2 | $4000–$43FF, 128×8 bytes, 1 KiB aligned | $5000–$53BF, 40×24; bit 7 inverts a screen code | 1,984 |

The assembled components are 161 code bytes on Ace, 331 on Oric and 249 on Atari,
plus 24 context bytes and eight source bytes per picture. Reset/video/diagnostic
code is separate.

These are destination data-write counts, not measured cycles or live frame budgets.
A replacement writes eight bytes; selecting one cell writes one. Init destroys the
previous font/name contents. Colours, display lists and memory maps are caller-owned.

## Include and call

Keep the sample tree together and include the machine's `glyphs.inc`. Define G at
24 private bytes: ordinary RAM on Ace, zero page on Oric/Atari. The original reset
caller provides video setup and a complete `example_install` section. Call
`glyph_init` once, point at readable original pictures, install a range, then select
one code in multiple cells. To animate all instances, replace their shared slot.
To change only one instance, select another code in that cell.

| Offset | Field |
| --- | --- |
| 0–1 | CPU source pointer, little-endian |
| 2 | First stored glyph code |
| 3 | Nonzero upload count |
| 4 | Screen code to select |
| 5–6 | Logical cell index, little-endian |
| 7 | Output: 1 accepted, 0 rejected |
| 8–9 | Output: destination data bytes written |
| 10–23 | Private scratch |

`glyph_install` uploads count pictures from first. `glyph_replace` uploads one and
ignores count. `glyph_select` changes one name. `glyph_init` blanks the owned names
and pictures. All public inputs 0–6 survive; status and cost reset even on rejection.
The source pointer is trusted: keep the required bytes readable, non-wrapping,
stable and separate from context/destination. Do not point it at write-only RAM.
The component cannot validate arbitrary CPU mappings or source lengths.

Ace/Atari store 128 shapes (0–127), counts 1–128 with first+count<=128. All screen
codes 0–255 select a shape plus inverse bit; code 128 does not name a 129th shape.
Oric stores only 96 drawable standard shapes, codes 32–127, counts 1–96 with a
legal range inside that interval. Its selectable normal/inverse codes are 32–127
and 160–255. Codes 0–31 and 128–159 are controls and are rejected by this picture
API. It deliberately does not expose arbitrary attribute writes as glyph selection.

Cells run 0–767 (Ace), 0–1035 (Oric), 0–959 (Atari). Empty/overflowing uploads,
invalid slots/cells and Oric control codes reject before any destination write.

## Jupiter Ace

The caller uses the unexpanded base RAM: G=$3C40, mailbox $3C80, writable source
$3D00 and stack $3FF0. It does not load or coexist with the manufacturer's Forth.
Forth normally owns this working RAM, display, shapes and frame interrupts.

Use the TV-priority aliases for character/name writes. The CPU-priority mirrors
$2800/$2000 compete differently with display fetches; changing the address is not
an arbitrary optimisation. Character RAM is hardware write-only. Keep the original
font elsewhere if the game needs to edit or restore it; never read-modify-write
that memory. Debugger inspection used by verification is not a CPU font-read API.

The routine clobbers AF/BC/DE/HL/flags, needs eight stack bytes including the direct
call and is non-re-entrant. It does not change interrupt state. The reset caller
uses DI; a Forth-callable wrapper needs its own stack/IRQ/allocation policy.

Each row is eight bits, bit 7 leftmost. Normal set bits are white on black, and
code+128 inverts them. The released 0.41.0 renderer reversed that polarity. Ace
qualification therefore uses the locked source build at Emu198x PR #1912, commit
7806827f35d4f49417f3cbfd537470f1a91f06b4, with its executable and Cargo.lock hashes
in toolchain.json. The source-independent regression fails on the old core; the
corrected normal/inverse/blank-neighbour/border checks pass. Do not describe this
as execution on an unchanged released emulator. The bus/readback and physical
contention limitations are separate from that palette correction.

## Oric Atmos

TEXT has 40×28 physical cells, each six dots wide and eight high. This component
reserves the first three cells of every row for caller-owned paper=16, ink=7 and
50 Hz TEXT mode=26. It draws in the remaining **37×28** rectangle. That leaves mode
and colour state visible and makes even the final picture cell safe to select.
The complete caller owns VIA/IRQ policy. It does not use the BASIC ROM.

Logical cell (x,y) becomes screen address `$BB80+y*40+3+x`. Do not multiply a row by
37 when calculating the physical screen stride. Init/selection skip the control
columns, preserving their bytes. Standard font row r in character n is at
`$B400+n*8+r`; only the low six bits are pixels, bit 5 leftmost. Unused standard
control-code definitions, the alternate-font neighbour and screen guards are checked.

The same standard shape can be normal or inverse. Bit 7 in the screen code inverts
it; the serial style attribute chooses standard/alternate sets separately. A table
calling codes 160–255 simply an alternate character set hides that distinction.
The qualified variant owns only the standard set and normal height, without flash.
Another style/HIRES/font allocation needs another contract, not a changed constant.

A/X/Y/flags are clobbered; decimal mode must be clear. Reserve six stack bytes
including the direct call. The context is non-re-entrant; no IRQ or mode switch is
hidden in the component. The repeated-subtraction row lookup trades extra arithmetic
for a small fixed-stride routine. A row-address table is a useful faster variant,
with its own table storage and boundary checks.

## Atari 800XL

The original 16 KiB OS-socket fixture executes at $E000; it is not Atari OS firmware.
ANTIC mode 2 uses a 40×24 screen at $5000 and a 1 KiB aligned font at $4000, selected
with CHBASE=$40. The caller supplies three blank lines, an LMS character instruction,
23 further character lines and a jump/wait-for-vertical-blank in its display list at
$3000. It owns DMACTL, CHACTL=$02, GTIA colours/priority, NMI and CPU mapping.

Screen codes are not ATASCII. The low seven bits select one of 128 eight-row shapes;
CHACTL's selected inverse policy makes bit 7 invert it. Other ANTIC character modes
can change glyph size, colour interpretation and alignment. OS shadow CHBAS is not
a substitute for updating hardware CHBASE when the OS is absent, and an OS VBlank
routine could restore its own values if mixed with this takeover caller.

A/X/Y/flags are clobbered; clear decimal mode, reserve six stack bytes including the
direct call, and give the non-re-entrant context exclusive ownership. The component
does not disable/re-enable display DMA, change colours or install a display list.
Framebuffers use the pinned emulator's default video/palette configuration; no
universal analogue-RGB or non-square-pixel presentation claim is made.

## Verification

Each original caller is executed independently: 21 Ace calls, 28 Oric calls and
21 Atari calls per build. Three builds per target yield **210 calls**, including
six completed wrong-slot/wrong-name builds caught by both full memory and native
picture checks. All owned font/name allocations, reserved attributes, padding,
guards, Atari display list, public inputs, source assets and actual write counts
are checked. Boundaries include full legal uploads, first/last slots, inverse
codes, invalid zero/overflow ranges/cells, Oric control codes and its row transition.

An independent compositor derives whole native frames from logical shapes and
screen codes, not screenshots treated as expected answers. The retained checker
replays every call and checks exact source/tool identities. Corruption controls
reject incomplete or rehashed-wrong observations. Ace uses the corrected source
build above; Oric and Atari use independent released Emu198x 0.41.0 binaries, and
all use Asm198x 0.0.71. Original assets and callers are MIT licensed.

Run `scripts/verify-character-ram-ports.py --native <qualified-tools> --assembler <qualified-asm>`
then review build/verification before retaining it as verification. CI replays with
`scripts/check-character-ram-ports.py` and its corruption tests. The diagnostic mailbox
is optional transport, not part of the callable library. These runs do not establish
stock Forth/BASIC/OS loading, IRQ coexistence, physical timing or tear-free updates.

## References

- Jupiter Cantab, *Jupiter Ace User's Manual* (1982), chapter 12: normal/inverse
  characters, eight-row redefinition and write-only character RAM; chapters 14/24:
  CPU-priority and TV-priority aliases and working RAM ownership.
- Bob Maunder, *The Oric-1 Companion* (Linsac) (1983), character generation and serial
  attributes; Peter Lupton and Frazer Robinson, *The Oric Atmos Handbook* (1984), pp103–107 for six-bit
  character sketches and standard character RAM. Mike Brown's ULA reconstruction
  distinguishes inverse code bits from standard/alternate style selection.
- Atari, *De Re Atari* (1982), section 2 display-list mode 2/LMS and section 3-4
  character indirection, 128 shapes, inverse forms and 1 KiB alignment. Hardware
  CHBASE is $D409 (54281); the OCR text can misread its D as a zero. CHBAS is the
  OS shadow at $02F4; consult the hardware register description when taking over.
- MAME, cantab/jupace.cpp, screen_update and monochrome palette: reference
  implementation cross-check for Ace normal/inverse polarity, not evidence that
  its readable font-memory simplification matches the manual's CPU read bus.
