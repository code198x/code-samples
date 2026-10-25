# Test Opaque Pixels in Two Small Masks in C64 BASIC

Two sprite boxes overlap. Their visible shapes might still miss each other completely. This narrow-phase query checks the opaque bits, after a cheaper box test has decided the pair is worth examining.

## Include and initialise

DIM P(8) and Q(8). Reserve public F/R/X/Y/O and private I/J/T/K/A/B. Reserve numbered lines **3000–3250**, combine routines.bas with a caller using build.py and keep END, STOP or a jump before the helper. C64/BBC use GOSUB; Spectrum uses GO SUB. Private I/J must not be outer caller FOR variables.

Call **3000** at a reset boundary. It clears all fields and both masks. Supply the mask rows and relative offsets afterwards. Each row is a byte with its most significant bit on the left:128 is the leftmost pixel,1 the rightmost. A set bit is opaque; a clear bit is transparent.

## Align and query

Place Q at X pixels right and Y pixels down relative to P, then call **3100**. F=1 reports an opaque overlap, and R is the first overlapping zero-based P row. No overlap returns F=0,R=255. R+1 is the corresponding array index.

| Field | Use |
|---|---|
| P(1)..P(8) / Q(1)..Q(8) | Eight MSB-left rows per mask; preserved |
| X / Y | Nonnegative right/down displacement; preserved |
| F / R / O | Hit, first P row and valid-input flag |

Shifts and mask rows must be integral bytes. O=0 rejects invalid numeric input with F=0,R=255. Valid input sets O=1. A shift of eight or more on either axis is a valid empty overlap. Rows and offsets survive every call. This BASIC validity guard is additional to the assembly example's byte-only input representation.

## The reusable routine

See `routines.bas`.

The helper selects shared rows, shifts Q right by X, and tests aligned bit pairs. Bits shifted beyond the right edge are discarded. It exits at the first row containing a shared opaque bit. Arithmetic bit extraction keeps the listing usable across dialects without assuming identical bitwise syntax.

## Keep the relative offset

The normal caller gives both masks an opaque pixel in row four, but Q is shifted one pixel right. Their boxes overlap while their opaque pixels miss. The custom caller moves P's pixel into that shifted column and gets a genuine hit in row four. Later calls change horizontal/vertical alignment and test a shift of eight.

See the retained-state section in `demo.bas`; the file also contains its boundary table and observation writer.

Line 2000, AA/BB/JJ/KK (Z/Q on Spectrum) and mailbox writes are diagnostics. A game supplies masks matching the current animation/collision shape, converts world positions to the documented relative offset, calls 3100 and consumes F/R after checking O.

## Customise collision detail

The masks need not include every decorative pixel. A smaller collision shape can produce more forgiving play. Keep the shape and its origin consistent as animation frames change. This helper reads logical masks; it does not fetch sprite hardware data, upload graphics or prove what the display currently shows.

The contract handles right/down offsets only. Left/up or mixed-sign displacement needs a deliberate signed-offset adapter or a wider routine; turning a negative offset into 255 means empty overlap here, not wrapping. Larger sprites need larger row sets and a new horizontal representation.

Use a cheap box first where it can reject most pairs. Testing every pixel pair for every object can cost far more than the visual precision repays. A machine's hardware collision facilities may offer other choices; compare their actual guarantees with the shape this game needs.

## Mistake and repair

The wrong caller ignores X and aligns the masks at zero. It reports contact between opaque pixels that are actually apart, and both saved checks fail. Convert relative coordinates before the mask query. Repaired source and loaded program match the normal caller exactly.

See `verification/wrong.png`.

## Cost and Maths for Games

The helper validates sixteen row values and visits at most eight shared rows and eight bit positions per row. Empty rows and an early hit reduce work. BASIC division and powers make this a readable, relatively expensive narrow phase; no frame-time budget is inferred.

[Maths for Games](/craft/maths-for-games/) connects bit masks, translation and set intersection. [The Craft](/craft/) connects coarse-to-fine collision, forgiving shapes and where pixel precision improves play.

## Global names and line numbers

BASIC numeric names, arrays and numbered lines are global. To combine helpers, rename public and private fields and renumber the helper together with every GO SUB/GO TO reference. Keep each state block under one owner. The maintained build.py rejects duplicate line numbers; it does not automatically namespace or renumber routines.

## Machine and measured size

C64 BASIC V2 recognises only the first two significant characters of numeric variable names. Short names make the ownership visible; check for collisions before including another component. Array element zero exists but is unused here. The diagnostic uses a mailbox at $C000, outside the normal BASIC heap.

The numbered helper occupies **521 tokenised program bytes** on this interpreter, including line headers. This excludes the caller, test tables, numeric scalar/array storage, interpreter stacks and ROM. Tokenised size is not machine-code size or a hardware-cycle count. No real-time or whole-game performance budget is inferred from the diagnostic. The caller’s AA/BB, JJ/KK and RAM mailbox are observation machinery, not required game state.

## Execution evidence

Working, custom, deliberately wrong and exact repaired callers executed through C64's stock BASIC interpreter under Emu198x 0.44.2. Build198x 0.2.9 tokenises C64 PRG and Spectrum TAP programs. C64 enters stock RUN, Spectrum uses ROM tape loading, and BBC enters every numbered source line through MOS/BASIC. Actual loaded program bytes, complete state packets, positive completion/count/guards and visible result pixels are checked. After the positive completion marker, the observer advances two complete display frames before capturing, so a partially scanned final character cannot masquerade as a finished picture. Firmware is not distributed.

An independent mathematical/order model checks the trace and rejects altered source, configuration, loaded program, state, completion and image evidence. Host exhaustive checks complement the native boundary/sequential examples; those host ranges are not claimed as natively exhaustive. The supplied diagnostic callers deliberately end with STOP; the interpreter report is expected. The wrong caller prints 0,0 and the normal/custom/repaired callers print 1,1.

Public CI checks retained evidence; it does not execute restricted firmware. Refresh with `python3 scripts/verify-basic-motion.py pixel-mask-collision commodore-64 --tools /path/to/extracted/releases` and inspect with `python3 scripts/check-basic-motion.py pixel-mask-collision`.
