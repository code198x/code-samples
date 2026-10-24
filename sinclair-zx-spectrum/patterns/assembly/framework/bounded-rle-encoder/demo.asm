    org $8000
CUSTOM equ 0
BROKEN equ 0
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
ERROR: defb 0
VALID: defb 0
INPUT_COUNT: defb 0
CAPACITY: defb 0
B0: defb 0
B1: defb 0
B2: defb 0
B3: defb 0
B4: defb 0
B5: defb 0
B6: defb 0
B7: defb 0
R0: defb 0
R1: defb 0
R2: defb 0
R3: defb 0
R4: defb 0
R5: defb 0
R6: defb 0
R7: defb 0
R8: defb 0
R9: defb 0
R10: defb 0
R11: defb 0
R12: defb 0
R13: defb 0
R14: defb 0
R15: defb 0
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
