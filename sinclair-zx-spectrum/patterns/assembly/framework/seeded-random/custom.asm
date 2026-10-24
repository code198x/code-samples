    org $8000
SEED equ 167
BROKEN equ 0
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
