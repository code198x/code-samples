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
VALUE_LO: defb 0
VALUE_HI: defb 0
DIGIT0: defb 0
DIGIT1: defb 0
DIGIT2: defb 0
DIGIT3: defb 0
DIGIT4: defb 0
WORK_LO: defb 0
WORK_HI: defb 0
input_ptr: defw 0
output_ptr: defw 0
cases_left: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 1300,0
    end start
