# Aquarius: reusable untimed BASIC command loop

Type GO and Return: TURN 0 becomes TURN 1. Submit it again for TURN 2. Waiting or submitting NO keeps the previous state. Q ends the program.

Enter `reusable.bas` as one complete program and RUN it under the normal firmware. `caller.bas` and `routines.bas` are the same program split for reuse: include both sets of numbered lines, not a second copy of the complete listing. The older Aquarius `demo.bas` remains a separate baseline where present.

## Use the rule in another program

Copy lines 1000–1050 into free line numbers. Put the submitted command in A$, keep the current integer 0–255 in N and the integer step 0–255 in S, then GOSUB 1000. C is replaced on every call: 1 if accepted, 0 otherwise. The accepted command adds S, subtracting 256 once on overflow. N+S is at most 510 under that contract. Fractional, negative or larger values require another contract. Commands and S are preserved.

The routine performs no input, drawing, fixed-address RAM writes or sound. Ordinary BASIC variables and GOSUB's stack belong to the interpreter. These globals and line numbers belong to your program: rename consistently, renumber every call target and retain RETURN. The caller initialises once, clears/redraws, submits input and applies the rule. Its INPUT blocks until Return; malformed input follows the dialect's own behaviour, not a parser supplied here.

Aquarius uses PRINT CHR$(11) to clear its text screen, not CLS. This is the unexpanded stock S2 BASIC/character-ROM configuration. No cartridge or AY expansion is required. The new bounded rule is independent from the older append-only GO probe.

## Customise and diagnose

`customise.bas` sets S=3: two accepted commands give 0 → 3 → 6 without adding globals or another routine. It spends three progress units for one action; it does not run the whole game three times.

`mistakes/reset-each-command.bas` is deliberately broken: its jump returns through line 10, erasing N at every iteration. Both accepted actions end back at zero. Restore the jump to line 20; initialisation remains outside the loop. The repaired caller is executed separately. Keep persistent world state across rejected input too.

For a timed decision, replace the blocking input policy with one that checks an explicit clock and decides how a command competes with an expired deadline. Faster assembly is not a substitute for that policy. The machine can keep servicing its display while the game waits.

## Verification

`scripts/verify-aquarius-mtx-loops.py --native /path/to/binaries-and-locks --assembler /path/to/asm198x --system mattel-aquarius --track basic` cold-starts six variants: normal use, step three, reset fault and repair, 254 → 255 → 0 and a nonzero start with step 255. Idle waits bracket actions; an ignored command must preserve state. `scripts/check-aquarius-mtx-loops.py` independently decodes retained video RAM/name-table dumps and checks source and image bindings. Native images accompany each observation. No host write supplies the game state. The record pins Emu198x 0.44.1, actual firmware, source and observation code; this is not original-hardware, a complete parser or whole-emulator qualification.

## Primary references

Mattel, *Aquarius Guide to Home Computing* (1982), clear-screen/CHR$ and BASIC control/input reference. Original S2 ROM, with Kenny Millar's annotated disassembly at https://aquarius.mattpilz.com/s2-disassembly.php, provides the firmware context; its comments about copyright status are not a licence grant.
