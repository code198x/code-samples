; The verifier's control: the 128K family deliberately gets the 48K's 224
; T-state loop. This build must fail on the 128K and +2A, whose lines are 228
; T-states long, and still pass on the 48K and the Pentagon.
MISTIME_128K    equ 1
PADDING         equ 0
        include "effect.asm"
