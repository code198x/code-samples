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
RANK: defb 0
INSERTED: defb 0
VALID: defb 0
SCORE: defb 0
TAG: defb 0
COUNT: defb 0
S0: defb 0
S1: defb 0
S2: defb 0
S3: defb 0
I0: defb 0
I1: defb 0
I2: defb 0
I3: defb 0
T0: defb 0
T1: defb 0
T2: defb 0
T3: defb 0
EXPR_SAVE: defb 0
input_ptr: defw 0
output_ptr: defw 0
cases_left: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 1300,0
    end start
