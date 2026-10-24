    org $8000
RESET_HEALTH equ 3
BROKEN equ 1
    include "caller.inc"
    include "exercise.inc"
component_start:
    include "flow.inc"
    include "../../physics/rectangle-overlap/display.inc"
code_end:
flow_state: defb 0
flow_events: defb 0
flow_changed: defb 0
flow_fresh: defb 0
flow_error: defb 0
previous: defb 0
held: defb 0
score: defb 0
health: defb 0
resets: defb 0
resumed: defb 0
finished: defb 0
invalid_seen: defb 0
case_state: defb 0
case_events: defb 0
trace_index: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 1405,0
    end start
