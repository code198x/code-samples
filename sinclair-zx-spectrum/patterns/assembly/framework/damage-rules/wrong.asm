    org $8000
PERIOD equ 3
BROKEN equ 1
    include "caller.inc"
    include "exercise.inc"
component_start:
    include "component.inc"
    include "cases.inc"
    include "../../physics/rectangle-overlap/display.inc"
code_end:
HEALTH: defb 0
REMAINING: defb 0
AMOUNT: defb 0
APPLIED: defb 0
KILLED: defb 0
accepted: defb 0
first_death: defb 0
deaths: defb 0
blocked: defb 0
snapshot: defb 0
trace_index: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 1248,0
    end start
