# MSX1: reusable untimed BASIC command update

Enter GO and Return: TURN 0 becomes TURN 1. A second GO gives TURN 2. Waiting and NO preserve the count; Q ends the caller. This is a command gate, not an adventure parser.

Enter `reusable.bas` and RUN under the recorded MSX1 NTSC BIOS/BASIC. `caller.bas` followed by `routines.bas` is the same complete program. The caller selects SCREEN 0 and 40 columns; it owns the whole text redraw. Keep other UI outside that clear, or replace the presentation block with your own status area.

## Reuse the rule

Copy lines 1000–1050 into a free line range. Put the submitted string in A$, current whole-number byte value in N and whole-number byte step in S, then GOSUB 1000. C is replaced every call: 1 if accepted, 0 otherwise. GO adds S modulo 256; rejected commands preserve N. A$ and S are preserved. Keep N/S initialisation outside the repeated path.

The rule performs no keyboard, screen, clock, sound or fixed-address write. BASIC owns variable storage, GOSUB's return stack, keyboard scanning, display services and interrupts. Names and line numbers are global to your program: reserve or rename them consistently and update every call target. INPUT blocks until Return. The counter uses ordinary BASIC numeric storage; the byte range is the routine's contract, not its storage format. Fractional, negative or larger values need another contract.

The maintained sample needs no fixed RAM reservation. For verification only, the runner inserts CLEAR 200,53247 and a VPEEK loop that copies actual SCREEN 0 name-table cells into $D000–$D3BF after PRINT and before INPUT. It copies video output, not N or a host-provided count. This diagnostic allocation is not a general BASIC allocator, and the reusable program does not require it. The older demo.bas retains its separate historical counter-mirror probe and record.

## Customise and diagnose

`customise.bas` uses STEP/S=3: two actions give 0 → 3 → 6. One action still invokes the rule once. The byte contract needs a whole-number starting value and step from 0 through 255. Adding them gives at most 510, so one subtraction of 256 suffices in BASIC; the CPU's byte addition wraps naturally in assembly. The nonzero check starts at 100 with step 255 and reaches 99 then 98.

`mistakes/reset-each-command.bas` is deliberately broken: initialisation runs inside the repeated path, so the next iteration erases progress. Keep initialisation at startup and jump back to the command/update path to repair it. Repair is cold-started separately; the fault is not relabelled as a successful variation.



An untimed world waits for an accepted action. A timed turn needs its own clock, expiry policy and ordering when a command arrives at the deadline. Display refresh or firmware interrupt activity does not automatically advance game rules. Blocking input is useful when nothing else needs main-loop service; continuing animation, music or deadlines require a different input/service policy.

## Verification

The original baseline probe remains separate. Run `scripts/verify-msx-gameboy-loops.py --native /path/to/binaries-and-locks --assembler /path/to/asm198x --system msx --track basic` from the repository root. The qualified released tools are Emu198x 0.44.1 and Asm198x 0.0.71, with verified archive and executable hashes plus before/after/committed producer locks.

The six common cold starts check normal use, step three, reset fault/repair, wraparound and nonzero initialisation. Idle, first accepted action, waiting/holding, ignored input and a second accepted action are retained as native captures and actual observations. BASIC verification reads the actual VPEEK-derived text cells and finds one displayed TURN count; its held stage is an idle wait after a submitted line, not an assembly physical-key edge test.

`scripts/check-msx-gameboy-loops.py` independently decodes the records; falsification tests reject missing cases/stages, altered source/capture/payload/counts and false repairs. The additive three-route inventory does not expand the broad input/drawing/sound probe count or qualify new audio. No original-hardware, cassette-transfer, other model/firmware or whole-emulator claim follows.

## Primary references

ASCII/Microsoft, *MSX Technical Data Book*: BASIC Reference Guide entries SCREEN, WIDTH, CLEAR, INPUT, VPEEK and GOSUB/RETURN; Advanced Programming Guide, BIOS interface policy. Use the actual firmware and language configuration named by the retained record.
