    org $8000
CUSTOM equ 0
BROKEN equ 0
SCORE_CAP equ 65535
QUEUE_CAP equ 4
REPEAT_DELAY equ 4
REPEAT_RATE equ 2
    include "caller.inc"
    include "exercise.inc"
component_start:
    include "component.inc"
    include "cases.inc"
    include "../../physics/rectangle-overlap/display.inc"
code_end:
STATE:
SCORE_LO: defb 0
SCORE_HI: defb 0
ADD_LO: defb 0
ADD_HI: defb 0
CLIPPED: defb 0
input_ptr: defw 0
output_ptr: defw 0
cases_left: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 1300,0
    end start
