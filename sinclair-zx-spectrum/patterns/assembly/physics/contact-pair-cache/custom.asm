    org $8000
CUSTOM equ 1
BROKEN equ 0
COYOTE_STEPS equ 2
BUFFER_STEPS equ 2
TEXT_CAP equ 4
PROPERTY_COUNT equ 16
STREAM_BYTES equ 13
CRC_POLY equ 49
    include "caller.inc"
    include "exercise.inc"
component_start:
    include "component.inc"
    include "data.inc"
    include "cases.inc"
    include "../../physics/rectangle-overlap/display.inc"
code_end:
STATE:
FIRST: defb 0
VALID: defb 0
MODE: defb 0
OBJECT_A: defb 0
OBJECT_B: defb 0
B0: defb 0
B1: defb 0
B2: defb 0
B3: defb 0
B4: defb 0
B5: defb 0
B6: defb 0
B7: defb 0
T0: defb 0
T1: defb 0
T2: defb 0
T3: defb 0
T4: defb 0
EXPR_SAVE: defb 0
input_ptr: defw 0
output_ptr: defw 0
cases_left: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 1300,0
    end start
