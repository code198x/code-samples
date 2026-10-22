# Wait for a command: 40-column PET, assembly

A advances TURN 0 to TURN 1, then TURN 2. X leaves it alone; Q returns to BASIC.
The rules have no deadline. Firmware clocks and keyboard/display services remain
active. Delivered commands are not a physical-key edge contract.

Build with Asm198x 0.0.71:

    make ASM198X=/path/to/asm198x

Load build/demo.prg at its recorded address $0401; RUN executes its BASIC
SYS 1040 stub. The verified emulator path imports that PRG through program-1,
then executes the ROM's RUN/SYS route. It does not qualify a physical tape/disk
transport. Q returns through the original SYS stack; do not reset the stack.

Copy routines.inc into your own assembly project. Before calling apply_command,
clear decimal mode, put a PETSCII command in A and set turn_count/turn_step bytes.
It preserves X/Y, replaces A/flags and turn_accepted (1 for A, 0 otherwise), and
changes turn_count modulo 256 only for A. It does no I/O and needs no zero-page
scratch. The three labelled bytes are caller-owned persistent state; relocate
with the program, don't overlap them with another owner.

The standalone caller leaves firmware IRQs and vectors intact. GETIN $FFE4
returns a delivered character or zero; the caller polls zero without changing
rule state. CHROUT $FFD2 draws to the normal screen. This requires normal booted
firmware, its keyboard scan and default input/output channels. Do not combine
this caller with a ROM-banked-out or IRQ-disabled takeover loop unchanged.
GETIN is buffered input, not a matrix sample or a guaranteed new physical press.

presentation.inc is separate: it clears the screen, converts the count to three
decimal digits with subtraction and prints them. It clobbers A/X/Y, flags and
its own two scratch bytes. Firmware also owns the hardware stack and workspace.
No VIC/VIA/CRTC setup is hidden inside the rule routine.

customise.inc replaces caller.inc: immediate step 3 gives 000,003,006, with no
extra state or code bytes. The deliberately broken mistake caller clears the
count before every delivered command; A,X,A gives 001,000,001. Restore caller.inc
to repair it. The byte arithmetic naturally wraps; ADC requires D=0 and an
explicit CLC. The saved command on the hardware stack lets the faulty caller
illustrate the reset without accidentally replacing the command itself.

The standalone PRG occupies BASIC program RAM. Treat its loaded range as owned;
do not append BASIC variables or another program over the code. In a mixed
BASIC/assembly project reserve a separate code range and relocate the caller.
The firmware workspace, character screen and program-load address differ between
PET and VIC-20 even though the rule/presentation instructions are identical.

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

    python3 scripts/verify-commodore-command-loops.py --native /path/to/native/bin --assembler /path/to/asm198x --only commodore-pet/assembly

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
