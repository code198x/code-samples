# Turn a Score into Five Digits in Spectrum BASIC

Your score counter likes binary arithmetic. The player wants to read 65535. This formatter supplies five decimal character codes that a separate text routine can draw, translate to tiles or write into a record.

## Include and initialise

Reserve D(5), public L/H/O and private V/P/I/K. Reserve lines **3000–3150**, combine routines.bas and your caller with build.py, and keep END, STOP or a jump before the helper. C64/BBC use GOSUB; Spectrum uses GO SUB. Private I must not be an enclosing caller's FOR variable.

Call **3000** at a reset boundary. It clears L/H, validity O and every D element. Then supply unsigned low byte L and high byte H. Their combined value is L+256*H, from zero to 65,535.

## Format without drawing

Call **3100**. If L/H are integral bytes, O=1 and D(1)..D(5) receives exactly five ASCII codes with leading zeroes. L/H survive. Invalid input sets O=0 and preserves all D values and both inputs. This BASIC validity flag handles numeric values outside the assembly helper's byte-input representation.

| Field | Use |
|---|---|
| L / H | Low/high input bytes; retained |
| D(1)..D(5) | Five output ASCII codes, no terminator |
| O | Fresh valid flag |

Zero becomes 00000. The largest input becomes 65535. There is no sixth byte to scan for a zero terminator. A consumer must use the counted five-element output. ASCII is a logical result: a character display, bitmap font or tile map may need a machine-specific translation.

## The reusable routine

See `routines.bas`.

The helper combines the input in private V, then extracts digits at place values 10,000, 1,000, 100, 10 and 1. V is a BASIC number with enough range for the 16-bit input; it is not an eight-bit work byte. It finishes at zero after all digits, while P finishes at 0.1. Private scratch is overwritten on every valid call.

## Format changed values

The normal caller first formats 65,535, then zero, one,9,999 and 10,000. The custom caller begins with 4,096 and returns 04096. Every native trace checks all five character codes and preserved inputs after every call.

See the retained-state section in `demo.bas`; the file also contains its boundary table and observation writer.

The diagnostic's line 2000, AA/BB/JJ/KK (Z/Q on Spectrum) and mailbox are removable. A game copies both bytes, calls 3100, checks O and passes D to its own rendering routine. Convert when the displayed score changes if doing so saves useful work.

## Customise presentation

Hide leading zeroes after formatting if that suits the display, while keeping the final zero for a value of zero. Signs, separators, decimal points and larger counters require a wider output contract. They are not silently inferred from these two unsigned bytes.

BASIC's STR$ can be convenient for a complete number, but padding, leading spaces and substring operations differ across dialects. This routine offers fixed counted ASCII output without string allocation. Packed BCD moves work into score updates; native lookup tables trade space for conversion speed. Which is best depends on how often the score changes and where it is displayed.

## Mistake and repair

The wrong caller clears H before formatting.65,535 becomes 255 and the formatter correctly returns 00255. Both saved checks fail because the supplied high byte and resulting digits differ from the intended score. Copy both bytes before changing gameplay state. The repair's source and loaded program match the normal caller.

See `verification/wrong.png`.

## Cost and Maths for Games

Each valid call extracts five digits with division, subtraction and integer rounding. It writes five output cells and allocates no helper strings. The globals and array cells occupy BASIC numeric storage; they are not nine packed native bytes. No hardware-cycle claim is made.

[Maths for Games](/craft/maths-for-games/) connects binary storage, base-ten place values and remainders. [The Craft](/craft/) separates the stored score, its formatted digits and the player's visual feedback.

## Machine and measured size

Spectrum FOR variables must be single letters: this diagnostic uses Z/Q instead of the other callers’ JJ/KK. Numeric arrays start at one. AND/OR in these listings join comparisons; neither is being used as a bitwise operator. The diagnostic reserves its mailbox above CLEAR 59999.

The numbered helper occupies **291 tokenised program bytes** on this interpreter, including line headers. This excludes the caller, test tables, numeric scalar/array storage, interpreter stacks and ROM. Tokenised size is not machine-code size or a hardware-cycle count. No real-time or whole-game performance budget is inferred from the diagnostic. The caller’s AA/BB, Z/Q and RAM mailbox are observation machinery, not required game state.

## Execution evidence

Working, custom, deliberately wrong and exact repaired callers executed through Spectrum's stock BASIC interpreter under Emu198x 0.44.2. Build198x 0.2.9 tokenises C64 PRG and Spectrum TAP programs. C64 enters stock RUN, Spectrum uses ROM tape loading, and BBC enters every numbered source line through MOS/BASIC. Actual loaded program bytes, complete state packets, positive completion/count/guards and visible result pixels are checked. After the positive completion marker, the observer advances two complete display frames before capturing, so a partially scanned final character cannot masquerade as a finished picture. Firmware is not distributed.

An independent mathematical/order model checks the trace and rejects altered source, configuration, loaded program, state, completion and image evidence. Host exhaustive checks complement the native boundary/sequential examples; those host ranges are not claimed as natively exhaustive. The supplied diagnostic callers deliberately end with STOP; the interpreter report is expected. The wrong caller prints 0,0 and the normal/custom/repaired callers print 1,1.

Public CI checks retained evidence; it does not execute restricted firmware. Refresh with `python3 scripts/verify-basic-records.py decimal-format sinclair-zx-spectrum --tools /path/to/extracted/releases` and inspect with `python3 scripts/check-basic-records.py decimal-format`.
