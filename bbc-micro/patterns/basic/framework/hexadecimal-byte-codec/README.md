# Read and Write Hexadecimal Bytes in BBC Micro BASIC

A byte is easier to recognise as A5 than as an unexplained decimal 165 when you are looking at bit patterns. A small two-way component makes that representation useful for diagnostics, seeds or compact input, while checking what comes back in.

## Include and initialise

Reserve public V/H/L/C/M/O, private A/B and lines **3000–3410**. There are no arrays. Combine routines.bas with the caller through build.py and keep END, STOP or a jump before the helper. C64/BBC use GOSUB; Spectrum uses GO SUB.

Call **3000** at an intended reset boundary. It clears every public field. M selects the operation: zero formats a byte; one parses two ASCII codes. The same H/L fields are output in the first direction and input in the second, so set the mode and relevant inputs deliberately.

## Format or parse

For M=0, supply integral byte V and case flag C. C=0 selects A–F; any nonzero byte selects a–f. Call **3100**. H/L become two ASCII codes, high digit first, and O=1. V/C/M survive. No terminator or display write is emitted. An invalid format input clears H/L/O and preserves V/C/M.

For M=1, supply H/L as exactly two ASCII digits from 0–9, A–F or a–f. Call 3100. A valid pair returns V and O=1; an invalid pair returns V=0,O=0. H/L/C/M survive, and C is unused by parsing. An unknown mode clears O and preserves the other fields.

See `routines.bas`.

| Fields | Use |
|---|---|
| V | Byte to format / parsed byte |
| H / L | High/low ASCII character codes |
| C / M | Format case flag / operation |
| O | Valid operation flag |

Zero is a valid parsed byte, so test O. A parser receives character codes, not numeric nibbles. There is no trimming, prefix handling or single-digit shorthand: 0x, a trailing space or a missing digit needs another input policy before this component.

## Check a roundtrip

The normal caller formats 165 as A5, then parses it back to 165. The custom caller selects lowercase a5 and recovers the same byte. Both also reject G0 and format the upper boundary 255. Saved first-character and roundtrip checks retain the earlier results.

See the retained-state section in `demo.bas`; the file also contains its boundary table and observation writer.

Line 2000, AA/BB/NN/JJ and the mailbox are diagnostics. A game supplies a logical ASCII editor or translates its device input. It also maps returned character codes to its presentation system. ASCII codes, keyboard codes and screen/font indices are not assumed interchangeable on every machine.

## Choose the useful boundary

Formatting and parsing are kept together here because the two-digit roundtrip is one small byte representation. Wider values need a declared byte/digit order and more output capacity. This component does not parse an arbitrary expression, address syntax or signed hexadecimal number.

Some BASIC dialects provide hexadecimal formatting. Their padding, case, sign and input rules may differ; compare those semantics before substituting a built-in. A two-character BASIC string can be more convenient for local display, while explicit codes suit a shared byte interface. Neither choice justifies skipping validation on input.

## Mistake and repair

The wrong caller swaps H/L after formatting. A5 becomes 5A, which is valid hexadecimal but represents 90. Both saved checks fail: the parser correctly reads the altered input. Keep the high digit first throughout the boundary. Repaired source and loaded program match normal exactly.

See `verification/wrong.png`.

## Cost and Maths for Games

Formatting splits one byte into two nibbles and maps each to a character. Parsing validates two character intervals before combining them. There is no search, allocation or device access. Keeping both directions together makes it easy to test that a formatted byte parses back to the original.

[Maths for Games](/craft/maths-for-games/) connects base sixteen, place value and reversible representations. [The Craft](/craft/) connects useful diagnostics and checked input to understanding a game's state.

## Global names and line numbers

BASIC numeric names, arrays and numbered lines are global. To combine helpers, rename public and private fields and renumber the helper together with every GO SUB/GO TO reference. Keep each state block under one owner. The maintained build.py rejects duplicate line numbers; it does not automatically namespace or renumber routines.

## Machine and measured size

BBC BASIC arrays include element zero; this one-based array interface leaves it unused. Its diagnostic uses MODE 7 and HIMEM=&6000 to separate program storage, mailbox and screen. The helper itself changes neither mode nor HIMEM.

The numbered helper occupies **671 tokenised program bytes** on this interpreter, including line headers. This excludes the caller, test tables, numeric scalar/array storage, interpreter stacks and ROM. Tokenised size is not machine-code size or a hardware-cycle count. No real-time or whole-game performance budget is inferred from the diagnostic. The caller’s AA/BB, JJ/KK and RAM mailbox are observation machinery, not required game state.

## Execution evidence

Working, custom, deliberately wrong and exact repaired callers executed through BBC Micro's stock BASIC interpreter under Emu198x 0.44.2. Build198x 0.2.9 tokenises C64 PRG and Spectrum TAP programs. C64 enters stock RUN, Spectrum uses ROM tape loading, and BBC enters every numbered source line through MOS/BASIC. Actual loaded program bytes, complete state packets, positive completion/count/guards and visible result pixels are checked. After the positive completion marker, the observer advances two complete display frames before capturing, so a partially scanned final character cannot masquerade as a finished picture. Firmware is not distributed.

An independent mathematical/order model checks the trace and rejects altered source, configuration, loaded program, state, completion and image evidence. Host exhaustive checks complement the native boundary/sequential examples; those host ranges are not claimed as natively exhaustive. The supplied diagnostic callers deliberately end with STOP; the interpreter report is expected. The wrong caller prints 0,0 and the normal/custom/repaired callers print 1,1.

Public CI checks retained evidence; it does not execute restricted firmware. Refresh with `python3 scripts/verify-basic-decisions.py hexadecimal-byte-codec bbc-micro --tools /path/to/extracted/releases` and inspect with `python3 scripts/check-basic-decisions.py hexadecimal-byte-codec`.
