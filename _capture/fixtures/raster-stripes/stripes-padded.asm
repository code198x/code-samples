; The verifier's other control: the same program with 64 harmless bytes
; after it. They change the tape, and so when loading finishes and in which
; phase the program starts, but not the effect. This build must pass on every
; model, which shows the references don't depend on loading time.
MISTIME_128K    equ 0
PADDING         equ 1
        include "effect.asm"
