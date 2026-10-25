# Wrap and Skip Menu Options in BBC Micro BASIC

Moving down from the last menu option should not select an imaginary option below the list. Wrapping and skipping disabled options belong in one small selection routine; drawing the menu and deciding when a held key repeats belong elsewhere.

## Include and initialise

Reserve public S/C/E/D/M/O, private I/K/T/J and lines **3000–3290**. There are no arrays. Private I must not be the caller's outer FOR variable. Combine routines.bas with your caller using build.py, with END, STOP or a jump before the helper. C64/BBC use GOSUB; Spectrum uses GO SUB.

Call **3000** at an intended reset boundary. It clears all public fields. Set option count C from one to eight, starting zero-based selection S below C, and enabled mask E afterwards. Bit zero enables option zero. Bits above the count are ignored.

## Offer a navigation request

Set D=1 forward, D=255 backward or D=0 for no movement, then call **3100**. These are encoded requests, not amounts to add to the index. The helper searches at most C candidates, wrapping inside the option count and choosing the first enabled option.

See `routines.bas`.

| Fields | Use |
|---|---|
| S / C | Retained selection / option count |
| E / D | Enabled mask / direction request |
| M / O | Selection changed / valid-input flag |

O=1 means the count, selection and inputs were valid. M=1 means S actually changed. With none enabled, S survives with M=0. With only the starting option enabled, a full search returns to it and M stays zero. D=0 does not repair a disabled selection. C/E/D survive every valid call.

Count/selection are integral and bounded, E is an integral byte and D is one of the three requests. Invalid input clears M/O and preserves S/C/E/D. A bad selection is reported rather than silently clamped into a different action.

## Exercise both ends

The normal caller starts at two in a three-option menu with only zero and two enabled, then moves forward to zero. The custom caller starts at zero with all three enabled and moves backward to two. Later calls test an empty enabled mask, a full-circle search and skipping a disabled option.

See the retained-state section in `demo.bas`; the file also contains its boundary table and observation writer.

Line 2000, AA/BB/JJ (Z on Spectrum) and the mailbox are observations. A game obtains one navigation request from a press/repeat policy, calls the helper and redraws when M reports change. Selection and activation are distinct: a held key that opened a menu should not accidentally activate its first option.

## Customise the menu

Use a different enabled mask as game state changes. A disabled starting selection can move to a valid enabled candidate; it does not have to be enabled already. More than eight options need another availability representation and wider or differently bounded indices. A two-dimensional layout needs an explicit neighbour policy.

For a BASIC-only interface, signed minus one can be a more natural backward request. This version retains the byte-facing 255 convention of the assembly component; change the validation and caller together if you adopt another interface. Separate menus need renamed fields/line references or a deliberate context wrapper.

## Mistake and repair

The wrong caller adds D directly to S, then asks the helper to do nothing. Normal forward movement produces index three; custom backward movement produces 255. Both are invalid for a three-option menu, and both saved checks fail. Pass the request to the bounded search instead of treating byte arithmetic as menu wrapping. Repaired source and loaded program match normal exactly.

See `verification/wrong.png`.

## Cost and Maths for Games

The search visits at most eight candidates and uses arithmetic to test an enabled bit. Empty masks cannot cause an unbounded loop. A plain wrap is cheaper when every option is always enabled; a neighbour table can suit an irregular layout. Neither input scanning, repeat timing nor rendering occurs here.

[Maths for Games](/craft/maths-for-games/) connects modular indices and bounded search. [The Craft](/craft/) connects predictable navigation, disabled actions and deliberate activation.

## Global names and line numbers

BASIC numeric names, arrays and numbered lines are global. To combine helpers, rename public and private fields and renumber the helper together with every GO SUB/GO TO reference. Keep each state block under one owner. The maintained build.py rejects duplicate line numbers; it does not automatically namespace or renumber routines.

## Machine and measured size

This helper uses scalar numeric fields and allocates no arrays. Its diagnostic uses MODE 7 and HIMEM=&6000 to separate program storage, mailbox and screen. The helper itself changes neither mode nor HIMEM.

The numbered helper occupies **414 tokenised program bytes** on this interpreter, including line headers. This excludes the caller, test tables, numeric scalar/array storage, interpreter stacks and ROM. Tokenised size is not machine-code size or a hardware-cycle count. No real-time or whole-game performance budget is inferred from the diagnostic. The caller’s AA/BB, JJ and RAM mailbox are observation machinery, not required game state.

## Execution evidence

Working, custom, deliberately wrong and exact repaired callers executed through BBC Micro's stock BASIC interpreter under Emu198x 0.44.2. Build198x 0.2.9 tokenises C64 PRG and Spectrum TAP programs. C64 enters stock RUN, Spectrum uses ROM tape loading, and BBC enters every numbered source line through MOS/BASIC. Actual loaded program bytes, complete state packets, positive completion/count/guards and visible result pixels are checked. After the positive completion marker, the observer advances two complete display frames before capturing, so a partially scanned final character cannot masquerade as a finished picture. Firmware is not distributed.

An independent mathematical/order model checks the trace and rejects altered source, configuration, loaded program, state, completion and image evidence. Host exhaustive checks complement the native boundary/sequential examples; those host ranges are not claimed as natively exhaustive. The supplied diagnostic callers deliberately end with STOP; the interpreter report is expected. The wrong caller prints 0,0 and the normal/custom/repaired callers print 1,1.

Public CI checks retained evidence; it does not execute restricted firmware. Refresh with `python3 scripts/verify-basic-interfaces.py menu-navigation bbc-micro --tools /path/to/extracted/releases` and inspect with `python3 scripts/check-basic-interfaces.py menu-navigation`.
