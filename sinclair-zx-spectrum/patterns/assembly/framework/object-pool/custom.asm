    org $8000
POOL_CAPACITY equ 4
BROKEN equ 0
    include "caller.inc"
    include "exercise.inc"
component_start:
    include "pool.inc"
    include "age.inc"
    include "../../physics/rectangle-overlap/display.inc"
code_end:
guard_a: defb 0
pool_flags: defs POOL_CAPACITY,0
guard_b: defb 0
pool_life: defs POOL_CAPACITY,0
mask_index: defb 0
selected: defb 0
status_bits: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 1294,0
    end start
