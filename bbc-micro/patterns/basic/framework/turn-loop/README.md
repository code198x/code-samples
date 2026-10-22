# BASIC sampled turn loop: BBC Micro and Electron

Enter `caller.bas`, then `routines.bas`, as one numbered program. Type RUN.
Tap Space: TURN advances once. Hold it: the loop keeps running, but the turn
counter waits for release and a new press. The same source runs independently
on BBC Model B and Acorn Electron; each has a separate execution record.

## Reuse

Reserve lines 1000–1130, or renumber the GOSUB targets and routines together.
GOSUB 1000 waits for MOS OSBYTE 19 through `*FX 19`. Keep normal MOS IRQ handling.
Do not call it with interrupts disabled or after replacing its clock service.
GOSUB 1100 consumes `K%`, a TRUE/FALSE sample, and `P%`, the previous sample.
Initialise `P%=FALSE` once. Set `N%` to the counter and `S%` to the step.
It returns `C%=1` for a new accepted press, zero otherwise, updates N% modulo 256
and stores K% in P%. It performs no input, drawing or timing itself.

These are BASIC globals, not local variables. K%, S% are preserved. N%, P%, C%
are owned/mutated by the rule routine; F% belongs to the caller and counts loop
iterations modulo 65536. Rename consistently to avoid clashes. Each GOSUB needs
a BASIC return frame; no assembly scratch space or private interrupt is used.
The *FX command passes through the MOS command interpreter on every iteration;
a direct assembly wait is cheaper for a tighter budget.

The complete caller selects MODE 6 and owns the text display. It lowers HIMEM
to &3000; &3000–&3003 mirror counter, iteration low/high and accepted flag for
observing the running program. &3004–&3005 are diagnostic guards. These six bytes
are a caller diagnostic, not a requirement of the reusable routines. Remove the
mirror writes and reserve no addresses if you do not need that observer. Keep
HIMEM above your growing BASIC program and below any separately allocated state.

## Customise and diagnose

Change S%=1 to S%=2: successive presses produce 0, 2, 4, while a held key still
produces one turn. Change N%=0 to N%=254 to see the explicit 254, 255, 0 wrap.
Changing the key means replacing INKEY(-99); use the machine's documented
negative key number, not an ASCII character code. A very short tap between
samples can be missed; an input queue needs a different contract.

The deliberately faulty `mistakes/no-edge.bas` replaces the routine and turns
held state directly into turns. The counter runs away while Space is held.
Restore `routines.bas`, preserving P% between calls, to fix it.
`mistakes/no-wait.bas` isolates another fault: removing the wait counts interpreter
iterations rather than display fields. Restore GOSUB 1000's MOS wait. Native
checks run each fault and the repair from fresh firmware, rather than inferring
the fix from source alone.

The loop is field-paced, not a timer for an entire game. Work that overruns a
field misses that opportunity; do not speed the whole world up to catch it.
Draw only when the state changes. Redrawing every field made the tested Electron
caller miss alternate fields; keeping a wait does not make slow work free.
Use a real elapsed-time source for timed turns or deadlines. OSBYTE 19 provides
synchronisation, not elapsed time and not a permanent event history.

## Qualification and references

Run the shared native verifier described in
`cross-platform/patterns/framework/command-turns/README.md`.
`verification/results.json` and native captures are separate for BBC and Electron.
Released tool identities are in `qualification-toolchain.json`. No ROMs are
included; the record identifies the supplied firmware. This is a tested small
workload, not a whole-game budget or physical-hardware timing claim.

Primary references: Acorn *BBC Microcomputer User Guide*, INKEY and OSBYTE 19;
Acorn *Electron User Guide*, INKEY and *FX 19. The MOS calls have a common API;
the machines' video hardware and available CPU time differ.
