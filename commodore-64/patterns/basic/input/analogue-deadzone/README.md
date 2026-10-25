# Convert an Axis Sample to Intent in C64 BASIC

A slightly off-centre sample should not make a character creep. A dead zone ignores a small region around the centre, then starts movement gently with magnitude one just beyond the boundary.

## Include and initialise

Reserve public S/C/R/D/M/O, private T/A and lines **3000–3180**. There are no arrays. Combine routines.bas and a caller using build.py, with END, STOP or a jump before the helper. C64/BBC use GOSUB; Spectrum uses GO SUB.

Call **3000** at a reset boundary. It clears all public fields. Set sample S, calibrated centre C and radius R afterwards. S/C are integral bytes; R is an integral zero through 127. The sample and centre must use the same logical units and calibration.

## Query one numeric sample

Call **3100**. Distance at most R, including both boundaries, gives D=0,M=0. Outside the zone, D is one below centre or two above centre, and M is the distance **beyond** the radius. O=1 means valid input. Invalid input clears D/M/O and preserves S/C/R; valid calls also preserve all three inputs.

See `routines.bas`.

| Fields | Use |
|---|---|
| S / C / R | Sample / calibrated centre / quiet-zone radius |
| D / M / O | Direction / excess magnitude / valid-input flag |

Subtraction stays signed before taking the absolute distance. A sample left of centre must not wrap into a large positive byte. Removing the radius gives magnitude one at the first accepted sample, rather than a jump directly to the original distance.

## Compare two quiet zones

At S=110,C=100, normal radius eight returns direction two and magnitude two. The custom radius sixteen returns still. Later calls exercise the two boundaries and the first sample beyond each. The native table includes extreme centres, opposite endpoints and invalid radii.

See the retained-state section in `demo.bas`; the file also contains its boundary table and observation writer.

Line 2000, AA/BB/JJ (Z on Spectrum) and mailbox writes are diagnostics. These runs verify the numeric routine through each machine's interpreter. They do not verify a physical analogue device or an input adapter. The caller must obtain and calibrate a suitable sample. A digital joystick or keyboard reader does not acquire analogue precision by passing its values through this helper.

## Calibrate and scale deliberately

A centre near an endpoint leaves unequal travel on each side. The mathematical quiet interval may extend beyond the byte sample domain; only supplied byte samples are queried. Calibration and endpoint scaling need their own measurements and policy.

M is not rescaled to 255. If full available travel should always produce full speed, scale each side against its measured endpoint range. A larger radius suppresses more small movement but leaves less usable travel. Hysteresis can prevent chatter around a boundary, at the cost of retained state; this independent-sample query has none.

For two axes, separate axial dead zones create a square quiet region. A radial dead zone is a different geometry and needs a corresponding distance/scaling routine. Choose it for the intended control feel rather than substituting one label for the other.

## Mistake and repair

The wrong caller replaces the calibrated centre with zero. The same sample now appears far from centre, and both the magnitude and preserved-centre checks fail. Keep the actual calibration input and preserve signed subtraction. Repaired source and loaded program match normal exactly.

See `verification/wrong.png`.

## Cost and Maths for Games

Each query has fixed validation, signed subtraction, absolute distance and comparisons, with no input read, loop, allocation or clock. A simpler threshold can suit a purely digital decision; scaled analogue magnitude or hysteresis adds another policy and cost.

[Maths for Games](/craft/maths-for-games/) connects signed displacement, inclusive intervals and piecewise mappings. [The Craft](/craft/) connects calibration and dead-zone shape to responsive, intentional control.

## Global names and line numbers

BASIC numeric names, arrays and numbered lines are global. To combine helpers, rename public and private fields and renumber the helper together with every GO SUB/GO TO reference. Keep each state block under one owner. The maintained build.py rejects duplicate line numbers; it does not automatically namespace or renumber routines.

## Machine and measured size

C64 BASIC V2 recognises only the first two significant characters of numeric variable names. Short names make the ownership visible; check for collisions before including another component. This helper uses scalar numeric fields and allocates no arrays. The diagnostic uses a mailbox at $C000, outside the normal BASIC heap.

The numbered helper occupies **259 tokenised program bytes** on this interpreter, including line headers. This excludes the caller, test tables, numeric scalar/array storage, interpreter stacks and ROM. Tokenised size is not machine-code size or a hardware-cycle count. No real-time or whole-game performance budget is inferred from the diagnostic. The caller’s AA/BB, JJ and RAM mailbox are observation machinery, not required game state.

## Execution evidence

Working, custom, deliberately wrong and exact repaired callers executed through C64's stock BASIC interpreter under Emu198x 0.44.2. Build198x 0.2.9 tokenises C64 PRG and Spectrum TAP programs. C64 enters stock RUN, Spectrum uses ROM tape loading, and BBC enters every numbered source line through MOS/BASIC. Actual loaded program bytes, complete state packets, positive completion/count/guards and visible result pixels are checked. After the positive completion marker, the observer advances two complete display frames before capturing, so a partially scanned final character cannot masquerade as a finished picture. Firmware is not distributed.

An independent mathematical/order model checks the trace and rejects altered source, configuration, loaded program, state, completion and image evidence. Host exhaustive checks complement the native boundary/sequential examples; those host ranges are not claimed as natively exhaustive. The supplied diagnostic callers deliberately end with STOP; the interpreter report is expected. The wrong caller prints 0,0 and the normal/custom/repaired callers print 1,1.

Public CI checks retained evidence; it does not execute restricted firmware. Refresh with `python3 scripts/verify-basic-input-models.py analogue-deadzone commodore-64 --tools /path/to/extracted/releases` and inspect with `python3 scripts/check-basic-input-models.py analogue-deadzone`.
