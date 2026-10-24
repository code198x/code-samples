    org $8000
SEED equ 0
BROKEN equ 1
    include "caller.inc"
    include "exercise.inc"
    include "rng.inc"
    include "../../physics/rectangle-overlap/display.inc"
code_end:
rng_state: defb 0
checkpoint: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 795,0
    end start
