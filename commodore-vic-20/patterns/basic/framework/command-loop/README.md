# Wait for a command: unexpanded PAL VIC-20, basic

A advances TURN 0 to TURN 1, then TURN 2. X leaves it alone; Q returns to BASIC.
The rules have no deadline. Firmware clocks and keyboard/display services remain
active. Delivered commands are not a physical-key edge contract.

Enter caller.bas and routines.bas as one numbered BASIC program, then RUN.
complete.bas is their complete combination. INPUT requires Return. Use uppercase
A/X/Q. This is a tiny command decision, not a parser; punctuation, quoted strings
and empty input follow the interpreter's INPUT rules.

Copy lines 1000–1050 into free numbers and GOSUB 1000. Set N and S to integers
0..255; A$ is the submitted command. N becomes (N+S) modulo 256 only for A;
C is replaced with 1 for accepted, 0 otherwise. S/A$ are preserved. Initialise
N/S once in the caller. One subtraction suffices because their sum is <=510.
BASIC numbers use the interpreter's floating-point representation here.

All four variables are global: rename consistently, including all callers.
Only the first two name characters distinguish numeric names. The routine does
no input/output and reserves no absolute RAM. It uses the BASIC return stack;
call with GOSUB, never GOTO. The caller clears the entire text screen per command.
Keep the routine separate if your UI must retain a status panel.

customise.bas replaces the caller, not the routine: S=3 produces 0,3,6.
mistakes/reset-each-command.bas is deliberately broken: it clears N before every
rule call. A,X,A produces 1,0,1 instead of 1,1,2. Replace it with caller.bas to
repair the fault. The native runs observe both versions independently.

The original demo.bas probe, where present, remains unchanged with its original
record and reproduction path. The reusable caller and new evidence live beside
it; old probe evidence has not been relabelled as proof of this implementation.

## Waiting, costs and extensions

INPUT blocks in BASIC; assembly keeps polling GETIN, consuming CPU while it
waits. Neither is a frame limiter. Redrawing the whole screen costs more than
updating one counter; no frame-rate or cycle benchmark is claimed. Keep the
rule routine and replace the caller when you need animation, deadlines or sound
servicing. Specify what happens when a command and timeout coincide.

The counter is a stand-in for a world update. Replace the A decision with your
command rules and use the acceptance result to decide whether enemies move.
A parser, physical press detection and timed turns are separate extensions.

## Reproduce

    python3 scripts/verify-commodore-command-loops.py --native /path/to/native/bin --assembler /path/to/asm198x --only commodore-vic-20/basic

verification/reusable/results.json binds sources, producer identity, firmware
hashes and six separately started callers. Each waits 120 fields before and
after an accepted command, rejects X, accepts two As, tests Q, and captures the
actual framebuffer plus screen RAM. Step-three, reset fault, repair, 254→255→0
and a nonzero start/step255 run independently. No counter state is injected.

check-commodore-command-loops.py validates the retained observations against
independent modulo arithmetic and decoded screen text; test_commodore_command_loops.py
must reject falsified counts/screens, absent source bindings/stages and altered
capture hashes. Retained evidence checks do not rerun firmware. No original
hardware, complete emulator or untested display/model claim follows.

The maintained reproduction script qualifies the aarch64 macOS releases above.
Place the three native executable links and asm198x in one bin/ directory;
keep each release's matching *-aarch64-apple-darwin-source-lock.json in its parent.
Use --assembler /path/to/tools/bin/asm198x with --native /path/to/tools/bin.
Firmware stays in the normal local ROM directory (or pass --firmware-root).
No firmware is redistributed. Other hosts can adapt the transport, but need
separate execution evidence rather than inheriting this record.
