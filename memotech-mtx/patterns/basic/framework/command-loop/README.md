# MTX500: reusable untimed BASIC command loop

Type 1 and Return: TURN 0 becomes TURN 1. Submit it again for TURN 2. Waiting or submitting 0 keeps the previous state. 9 stops the program.

Enter `reusable.bas` as one complete program and RUN it under the normal firmware. `caller.bas` and `routines.bas` are the same program split for reuse: include both sets of numbered lines, not a second copy of the complete listing. The older Aquarius `demo.bas` remains a separate baseline where present.

## Use the rule in another program

Copy lines 1000–1050 into free line numbers. Put the submitted command in A, keep the current integer 0–255 in N and the integer step 0–255 in S, then GOSUB 1000. C is replaced on every call: 1 if accepted, 0 otherwise. The accepted command adds S, subtracting 256 once on overflow. N+S is at most 510 under that contract. Fractional, negative or larger values require another contract. Commands and S are preserved.

The routine performs no input, drawing, fixed-address RAM writes or sound. Ordinary BASIC variables and GOSUB's stack belong to the interpreter. These globals and line numbers belong to your program: rename consistently, renumber every call target and retain RETURN. The caller initialises once, clears/redraws, submits input and applies the rule. Its INPUT blocks until Return; malformed input follows the dialect's own behaviour, not a parser supplied here.

MTX BASIC uses explicit LET assignments. CLS and PRINT use its normal VS5 text screen, whose name table is VDP memory rather than CPU-mapped screen RAM. The game routine has no assembly dependency. Only the qualification harness adds a 44-byte USR reader: it copies actual VS5 name-table bytes to $D000–$D3BF after PRINT. That observer owns code at $E000–$E02B in this small bounded verification program, preserves registers/interrupt-enable state and does not supply N or C. Remove its loader and line 25 when using the ordinary maintained listing. It is observation code, not an alternative game-state implementation or a general RAM allocator.

The named released-emulator run types the interactive editor with deliberately separated modifier chords and waits after each line. A submitted-character count is not proof of delivered source: the verifier independently decodes the rendered turn and checks exact observer bytes. Ordinary fast bulk typing was not reliable in this configuration; the retained record states the actual input method.

## Customise and diagnose

`customise.bas` sets S=3: two accepted commands give 0 → 3 → 6 without adding globals or another routine. It spends three progress units for one action; it does not run the whole game three times.

`mistakes/reset-each-command.bas` is deliberately broken: its jump returns through line 10, erasing N at every iteration. Both accepted actions end back at zero. Restore the jump to line 20; initialisation remains outside the loop. The repaired caller is executed separately. Keep persistent world state across rejected input too.

For a timed decision, replace the blocking input policy with one that checks an explicit clock and decides how a command competes with an expired deadline. Faster assembly is not a substitute for that policy. The machine can keep servicing its display while the game waits.

## Verification

`scripts/verify-aquarius-mtx-loops.py --native /path/to/binaries-and-locks --assembler /path/to/asm198x --system memotech-mtx --track basic` cold-starts six variants: normal use, step three, reset fault and repair, 254 → 255 → 0 and a nonzero start with step 255. Idle waits bracket actions; an ignored command must preserve state. `scripts/check-aquarius-mtx-loops.py` independently decodes retained video RAM/name-table dumps and checks source and image bindings. Native images accompany each observation. No host write supplies the game state. The record pins Emu198x 0.44.1, actual firmware, source and observation code; this is not original-hardware, a complete parser or whole-emulator qualification.

## Primary references

Memotech, *MTX Series BASIC Tutor, Reference and Operator's Manual*, printed p. 45 (Boolean relations), p. 53 (FOR/control variables) and the LET, GOSUB/RETURN and USR reference entries: http://www.primrosebank.net/computers/mtx/documents/MTX_Operators_Manual.pdf. Memotech's *MTX Video Memory Mapping*, §1.2–1.6 and Appendix A, describes VDP ports and the VS5 name table.

The pinned native observer enters MTX source with separately phased modifier/key presses and a settling interval after each line. Bulk `type_string` acknowledgement alone did not establish that the interpreter received the same program. Exact loaded-byte and observed-screen guards remain required; this is an input-delivery observation, not a finding that valid FOR syntax is unsupported.
