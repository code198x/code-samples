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
BUCKET: defb 0
COUNT: defb 0
INSERTED: defb 0
FULL: defb 0
VALID: defb 0
MODE: defb 0
INPUT_X: defb 0
INPUT_Y: defb 0
ITEM: defb 0
C0: defb 0
C1: defb 0
C2: defb 0
C3: defb 0
S0: defb 0
S1: defb 0
S2: defb 0
S3: defb 0
S4: defb 0
S5: defb 0
S6: defb 0
S7: defb 0
S8: defb 0
S9: defb 0
S10: defb 0
S11: defb 0
S12: defb 0
S13: defb 0
S14: defb 0
S15: defb 0
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
