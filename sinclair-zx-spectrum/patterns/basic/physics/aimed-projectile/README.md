# Aim a Projectile at a Target in Spectrum BASIC

An enemy can fire towards the player's current position without an angle table. Subtract the two positions, scale both components by the same dominant distance, and give the resulting velocity to a projectile. The speed rule matters as much as the arithmetic.

## Include and initialise

Reserve public U/V/O/X/Y/A/B/S, private D/E/F and lines **3000–3220**. There are no arrays. Combine routines.bas with a caller through build.py, keeping END, STOP or a jump before the helper. C64/BBC use GOSUB; Spectrum uses GO SUB. Call **3000** to clear public fields, then supply the intended shot.

X/Y are the origin and A/B the target, all integral byte coordinates in the same nonwrapping space. S is an integral speed from zero through fifteen. Call **3100** to calculate a velocity. O=1 means valid inputs; invalid input returns U/V/O=0 and preserves the inputs.

## Scale both axes together

The helper computes signed differences before taking their magnitudes. Their largest magnitude is the scale. Each output magnitude is the integer part of absolute-difference*S/scale, then its original sign is restored. Coincident points produce a valid zero vector without division.

See `routines.bas`.

U/V are signed velocities encoded as bytes. Decode a value of 128 or more by subtracting 256 before ordinary BASIC position arithmetic. Four pixels left is encoded as 252. Zero is always encoded as zero, including a negative component rounded down to zero.

For a noncoincident target, the dominant component has magnitude exactly S. This is a **dominant-axis speed rule**, not constant Euclidean speed. A diagonal shot can travel farther per update than an axis-aligned shot. That may suit the game's movement model; otherwise choose a different normalisation deliberately.

## Launch once, retain the velocity

The normal caller aims from 100,100 at 110,105 with speed four. It returns U=4,V=2. The custom caller aims at 90,95 and returns 252,254, meaning minus four and minus two. Saved horizontal and vertical checks verify both components.

See the retained-state section in `demo.bas`; the file also contains its boundary table and observation writer.

Later calls cover coincident points, extreme opposite corners and an invalid speed. AA/BB/JJ, line 2000 and the mailbox are diagnostics. The helper calculates a shot; it does not allocate an object, advance a position, choose a target or draw anything.

A game normally stores the decoded velocity with a spawned projectile. Recomputing it towards the player's new position every update instead creates homing behaviour. Either can be useful, but they are different rules. The same distinction applies to where the origin and target were sampled within the update.

## Choose the speed and precision

At a small S, a shallow component can round to zero. [Fractional-position integration](/patterns/commodore-64/basic/physics/fractional-position/) can retain subpixel progress and improve shallow trajectories, using wider state and integration. A Euclidean normaliser needs an appropriate length calculation or approximation and a corresponding cost/rounding policy. A small angle/velocity table trades runtime work for data and discrete directions.

Byte coordinates deliberately limit the query's world. Wider positions require wider validation and displacement arithmetic. A wrapping world needs a chosen wrap-distance rule; plain subtraction cannot infer which way around the world the projectile should travel.

## Mistake and repair

The wrong caller resets S to zero before every query. The helper correctly returns a stationary shot, so both saved velocity checks fail. Keep the intended speed until the aim calculation has used it. Repaired source and loaded program match normal exactly.

See `verification/wrong.png`.

## Cost and Maths for Games

A query validates five inputs, finds signed displacement and its dominant magnitude, then performs two bounded multiply/divides. Products can reach 3825, so they stay wide until scaled. It allocates nothing and owns no input device, timer or display state. A successful numerical query does not prove a complete projectile's collision, lifespan or frame budget.

[Maths for Games](/craft/maths-for-games/) connects displacement, ratios, quantisation and different distance measures. [The Craft](/craft/) connects aiming, shot commitment and deliberate homing behaviour.

## Global names and line numbers

BASIC numeric names, arrays and numbered lines are global. To combine helpers, rename public and private fields and renumber the helper together with every GO SUB/GO TO reference. Keep each state block under one owner. The maintained build.py rejects duplicate line numbers; it does not automatically namespace or renumber routines.

## Machine and measured size

Spectrum FOR variables must be single letters: this diagnostic uses Z/Q instead of the other callers’ JJ/KK. Numeric arrays start at one. AND/OR in these listings join comparisons; neither is being used as a bitwise operator. The diagnostic reserves its mailbox above CLEAR 59999.

The numbered helper occupies **504 tokenised program bytes** on this interpreter, including line headers. This excludes the caller, test tables, numeric scalar/array storage, interpreter stacks and ROM. Tokenised size is not machine-code size or a hardware-cycle count. No real-time or whole-game performance budget is inferred from the diagnostic. The caller’s AA/BB, JJ/KK and RAM mailbox are observation machinery, not required game state.

## Execution evidence

Working, custom, deliberately wrong and exact repaired callers executed through Spectrum's stock BASIC interpreter under Emu198x 0.44.2. Build198x 0.2.9 tokenises C64 PRG and Spectrum TAP programs. C64 enters stock RUN, Spectrum uses ROM tape loading, and BBC enters every numbered source line through MOS/BASIC. Actual loaded program bytes, complete state packets, positive completion/count/guards and visible result pixels are checked. After the positive completion marker, the observer advances two complete display frames before capturing, so a partially scanned final character cannot masquerade as a finished picture. Firmware is not distributed.

An independent mathematical/order model checks the trace and rejects altered source, configuration, loaded program, state, completion and image evidence. Host exhaustive checks complement the native boundary/sequential examples; those host ranges are not claimed as natively exhaustive. The supplied diagnostic callers deliberately end with STOP; the interpreter report is expected. The wrong caller prints 0,0 and the normal/custom/repaired callers print 1,1.

Public CI checks retained evidence; it does not execute restricted firmware. Refresh with `python3 scripts/verify-basic-aim.py aimed-projectile sinclair-zx-spectrum --tools /path/to/extracted/releases` and inspect with `python3 scripts/check-basic-aim.py aimed-projectile`.
