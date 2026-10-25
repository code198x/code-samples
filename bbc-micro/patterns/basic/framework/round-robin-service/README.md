# Give Ready Jobs a Fair Turn in BBC Micro BASIC

A game can have more background jobs than it wants to run in one update. Always starting at job zero lets that job monopolise the available turns. A rotating start position gives the other ready jobs a chance.

## Include and initialise

Reserve public S/F/N/M/O and private I/K/P/T. Reserve lines **3000–3210**, combine routines.bas and your caller with build.py and keep END, STOP or a jump before the helper. C64/BBC use GOSUB; Spectrum uses GO SUB. Private I is not available as an outer caller's FOR variable.

Call **3000** at a deliberate scheduling reset. It clears every public field. Set ready mask M afterwards and retain next position N between decisions. Bit zero represents slot 0; bit seven represents slot 7. Add powers of two to mark several ready slots.

## Select one ready slot

Call **3100**. Starting at N modulo eight, the helper examines each slot at most once, wrapping after seven. If it finds a set bit, S is that slot, F=1 and N becomes the following slot modulo eight. M is preserved; the caller decides whether a job remains ready after doing its work.

| Field | Use |
|---|---|
| N | Retained next starting position; byte input, normalised modulo eight |
| M | Ready-task bit mask, 0..255; preserved |
| S / F | Returned slot / found flag |
| O | Fresh valid-input flag |

No ready slots returns S=255,F=0 and normalises N without advancing it. A valid request sets O=1. Invalid non-byte/non-integral N or M returns O=0,S=255,F=0 and preserves N/M. This BASIC guard extends the assembly helper's byte-input representation. S=0 is a real task; check F.

## The reusable routine

See `routines.bas`.

The arithmetic bit test extracts one mask bit without assuming common bitwise syntax across dialects. Advancing N after a successful choice creates rotation; the mask by itself does not supply fairness.

## Retain the next start

With M=21, bits 0, 2 and 4 are ready. Six decisions return 0, 2, 4, 0, 2, 4. The custom caller starts at 7 with bits 7 and 0 ready, showing wraparound as 7, 0, 7, 0, 7, 0.

See the retained-state section in `demo.bas`; the file also contains its boundary table and observation writer.

The diagnostic's line 2000, AA/BB/SS/NN/JJ/KK (Z/Q on Spectrum) and mailbox record those decisions. Your game calls 3100, checks O/F and runs one bounded piece of the selected job. The helper does not run the job itself or read elapsed time.

## Customise the ready mask

Change M as work becomes ready or finishes. With a stable mask, every ready slot receives one selection per cycle. If readiness changes, the next search uses the new mask from the retained N. This says nothing about equal CPU time: a long job can still block every other job.

For predictable update cost, each selected job must do a limited piece of work and return. Fixed priority is useful for urgent work but can starve other jobs. Weighted service, deadlines or a mixed urgent/background budget need explicit policies and additional state. Rotation alone does not enforce a frame budget.

## Mistake and repair

The wrong caller resets N to zero before every decision. Slot zero is continuously ready and wins every time. The sum and membership checks both fail because later slots never run. Retain N between calls. Repaired source and loaded program match the normal caller.

See `verification/wrong.png`.

## Cost and Maths for Games

Each decision checks at most eight candidates with division, powers and remainder arithmetic. There are no arrays or dynamic allocation in the helper. These are operation bounds, not measured cycle or frame-time guarantees.

[Maths for Games](/craft/maths-for-games/) connects cyclic order, modulo arithmetic and bit sets. [The Craft](/craft/) connects fair background service to the work that must finish in time for responsive play.

## Machine and measured size

BBC BASIC arrays include element zero; this one-based array interface leaves it unused. Its diagnostic uses MODE 7 and HIMEM=&6000 to separate program storage, mailbox and screen. The helper itself changes neither mode nor HIMEM.

The numbered helper occupies **330 tokenised program bytes** on this interpreter, including line headers. This excludes the caller, test tables, numeric scalar/array storage, interpreter stacks and ROM. Tokenised size is not machine-code size or a hardware-cycle count. No real-time or whole-game performance budget is inferred from the diagnostic. The caller’s AA/BB, JJ/KK and RAM mailbox are observation machinery, not required game state.

## Execution evidence

Working, custom, deliberately wrong and exact repaired callers executed through BBC Micro's stock BASIC interpreter under Emu198x 0.44.2. Build198x 0.2.9 tokenises C64 PRG and Spectrum TAP programs. C64 enters stock RUN, Spectrum uses ROM tape loading, and BBC enters every numbered source line through MOS/BASIC. Actual loaded program bytes, complete state packets, positive completion/count/guards and visible result pixels are checked. After the positive completion marker, the observer advances two complete display frames before capturing, so a partially scanned final character cannot masquerade as a finished picture. Firmware is not distributed.

An independent mathematical/order model checks the trace and rejects altered source, configuration, loaded program, state, completion and image evidence. Host exhaustive checks complement the native boundary/sequential examples; those host ranges are not claimed as natively exhaustive. The supplied diagnostic callers deliberately end with STOP; the interpreter report is expected. The wrong caller prints 0,0 and the normal/custom/repaired callers print 1,1.

Public CI checks retained evidence; it does not execute restricted firmware. Refresh with `python3 scripts/verify-basic-services.py round-robin-service bbc-micro --tools /path/to/extracted/releases` and inspect with `python3 scripts/check-basic-services.py round-robin-service`.
