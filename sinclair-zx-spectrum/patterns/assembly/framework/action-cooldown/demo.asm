    org $8000
PERIOD equ 3
BROKEN equ 0
    include "caller.inc"
    include "exercise.inc"
component_start:
    include "component.inc"
    include "cases.inc"
    include "../../physics/rectangle-overlap/display.inc"
code_end:
REMAINING: defb 0
REQUEST: defb 0
AVAILABLE: defb 0
GRANTED: defb 0
accepted: defb 0
blocked: defb 0
at_three: defb 0
at_six: defb 0
availability_guard: defb 0
case_kind: defb 0
trace_index: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 1335,0
    end start
