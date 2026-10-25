# Keep Camera Shake Alive Across Updates in Spectrum BASIC

A hit can make the view jolt without moving the player or the world. Keep the effect's lifetime between updates, generate a small offset, and apply it only when converting world positions to the rendered view.

## Include and initialise

Reserve public X/Y/R/A/O/T/S/D/N/M, private P/U/V and lines **3000–3250**. There are no arrays. Combine routines.bas with a caller using build.py, keeping END, STOP or a jump before the helper. C64/BBC use GOSUB; Spectrum uses GO SUB. Call **3000** to clear public fields at a reset boundary.

R is remaining updates and A the retained amplitude. Supply trigger T, requested strength S, duration D and two caller-owned noise bytes N/M. All inputs and retained state are integral bytes. Strength is limited to zero through fifteen. Retained A must also be in that range unless a nonzero trigger is about to replace it.

## Trigger once, then retain the effect

Call **3100** once per intended effect update. A nonzero T reloads A=S and R=D. With positive R, each noise value is reduced modulo 2*A+1 and shifted down by A. The helper returns signed X/Y offsets encoded in bytes, then decrements R. R=0 returns zero offsets. O=1 means valid input.

See `routines.bas`.

Decode an output byte of 128 or more by subtracting 256 before adding it to a wider render coordinate. The maximum amplitude is fifteen, so an encoded 253 means minus three. Adding the encoded byte directly to an ordinary BASIC coordinate would move the camera the wrong way.

Invalid input clears offsets and O while preserving R/A and all caller inputs. A valid retrigger can replace an old amplitude byte of 255; without a trigger that retained amplitude is invalid. A trigger with duration zero deliberately cancels the effect. Strength zero produces zero offsets while its positive lifetime still counts down.

## Follow the lifetime

The normal caller requests strength three for three updates. The custom caller requests strength five for four. Each triggers only on the first call and supplies different noise values on later calls. The saved second offset proves the effect survived beyond the trigger; a separate counter checks the intended number of active calls.

See the retained-state section in `demo.bas`; the file also contains its boundary table and observation writer.

The final active call can return R=0 after producing a nonzero offset. Consume that call's X/Y; do not decide whether it was active solely from the decremented R. The caller counts active calls before the helper for precisely that reason. AA/BB/NN/JJ (Z on Spectrum), line 2000 and the mailbox are diagnostics.

## Keep the offset out of authoritative world state

Add the decoded offset to a temporary render camera or screen coordinate, then discard it after drawing. Keep collision, movement and the stable camera origin separate. These native examples verify the logical offsets and lifetime; they do not implement hardware scrolling or demonstrate a rendered shaking scene.

The caller owns the clock and noise generator. Reducing a byte by a remainder does not guarantee an exactly uniform distribution for every span. Smoother motion can use a table or filtered noise; a decaying envelope can vary strength over time. Neither is secretly provided here. Repeated triggers restart this effect rather than accumulating impulses or choosing a stronger request.

## Mistake and repair

The wrong caller clears R before every call. The first trigger still works, but later updates lose the effect. Both saved second-offset and lifetime checks fail. Retain R/A until expiry, an intentional reset or a new trigger. Repaired source and loaded program match normal exactly.

See `verification/wrong.png`.

## Cost and Maths for Games

Each valid active call validates bounded fields, computes two remainders and encodes two signed values. It allocates nothing and owns no timer, RNG or display register. More elaborate noise and decay need separate state and work; amplitude alone does not establish a visual-quality or frame-time budget.

[Maths for Games](/craft/maths-for-games/) connects modular arithmetic, signed representation and bounded displacement. [The Craft](/craft/) connects an effect's strength, duration and rendering ownership to readable feedback.

## Global names and line numbers

BASIC numeric names, arrays and numbered lines are global. To combine helpers, rename public and private fields and renumber the helper together with every GO SUB/GO TO reference. Keep each state block under one owner. The maintained build.py rejects duplicate line numbers; it does not automatically namespace or renumber routines.

## Machine and measured size

Spectrum FOR variables must be single letters: this diagnostic uses Z instead of the other callers’ JJ. The helper uses scalar numeric fields and allocates no arrays. AND/OR in these listings join comparisons; neither is being used as a bitwise operator. The diagnostic reserves its mailbox above CLEAR 59999.

The numbered helper occupies **635 tokenised program bytes** on this interpreter, including line headers. This excludes the caller, test tables, numeric scalar/array storage, interpreter stacks and ROM. Tokenised size is not machine-code size or a hardware-cycle count. No real-time or whole-game performance budget is inferred from the diagnostic. The caller’s AA/BB/NN, Z and RAM mailbox are observation machinery, not required game state.

## Execution evidence

Working, custom, deliberately wrong and exact repaired callers executed through Spectrum's stock BASIC interpreter under Emu198x 0.44.2. Build198x 0.2.9 tokenises C64 PRG and Spectrum TAP programs. C64 enters stock RUN, Spectrum uses ROM tape loading, and BBC enters every numbered source line through MOS/BASIC. Actual loaded program bytes, complete state packets, positive completion/count/guards and visible result pixels are checked. After the positive completion marker, the observer advances two complete display frames before capturing, so a partially scanned final character cannot masquerade as a finished picture. Firmware is not distributed.

An independent mathematical/order model checks the trace and rejects altered source, configuration, loaded program, state, completion and image evidence. Host exhaustive checks complement the native boundary/sequential examples; those host ranges are not claimed as natively exhaustive. The supplied diagnostic callers deliberately end with STOP; the interpreter report is expected. The wrong caller prints 0,0 and the normal/custom/repaired callers print 1,1.

Public CI checks retained evidence; it does not execute restricted firmware. Refresh with `python3 scripts/verify-basic-contacts.py camera-shake sinclair-zx-spectrum --tools /path/to/extracted/releases` and inspect with `python3 scripts/check-basic-contacts.py camera-shake`.
