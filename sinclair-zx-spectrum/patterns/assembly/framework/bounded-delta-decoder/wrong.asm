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
WRITTEN: defb 0
VALID: defb 0
COUNT: defb 0
BASE: defb 0
Q0: defb 0
Q1: defb 0
Q2: defb 0
Q3: defb 0
Q4: defb 0
Q5: defb 0
Q6: defb 0
Q7: defb 0
R0: defb 0
R1: defb 0
R2: defb 0
R3: defb 0
R4: defb 0
R5: defb 0
R6: defb 0
R7: defb 0
T0: defb 0
T1: defb 0
T2: defb 0
EXPR_SAVE: defb 0
input_ptr: defw 0
output_ptr: defw 0
cases_left: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 1300,0
    end start
