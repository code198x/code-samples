    org $8000
CUSTOM equ 0
BROKEN equ 1
COYOTE_STEPS equ 4
BUFFER_STEPS equ 4
TEXT_CAP equ 8
PROPERTY_COUNT equ 16
STREAM_BYTES equ 13
CRC_POLY equ 7
    include "caller.inc"
    include "exercise.inc"
component_start:
    include "component.inc"
    include "data.inc"
    include "cases.inc"
    include "../../physics/rectangle-overlap/display.inc"
code_end:
STATE:
OUT_X: defb 0
OUT_Y: defb 0
VALID: defb 0
HEAD: defb 0
COUNT: defb 0
INPUT_X: defb 0
INPUT_Y: defb 0
LAG: defb 0
APPEND_SAMPLE: defb 0
HX0: defb 0
HX1: defb 0
HX2: defb 0
HX3: defb 0
HX4: defb 0
HX5: defb 0
HX6: defb 0
HX7: defb 0
HY0: defb 0
HY1: defb 0
HY2: defb 0
HY3: defb 0
HY4: defb 0
HY5: defb 0
HY6: defb 0
HY7: defb 0
T0: defb 0
EXPR_SAVE: defb 0
input_ptr: defw 0
output_ptr: defw 0
cases_left: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 1300,0
    end start
