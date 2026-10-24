    org $8000
CUSTOM equ 1
BROKEN equ 0
SCORE_CAP equ 999
QUEUE_CAP equ 2
REPEAT_DELAY equ 6
REPEAT_RATE equ 3
    include "caller.inc"
    include "exercise.inc"
component_start:
    include "component.inc"
    include "cases.inc"
    include "../../physics/rectangle-overlap/display.inc"
code_end:
STATE:
POSITION: defb 0
LOWER: defb 0
UPPER: defb 0
DIRECTION: defb 0
input_ptr: defw 0
output_ptr: defw 0
cases_left: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 1300,0
    end start
