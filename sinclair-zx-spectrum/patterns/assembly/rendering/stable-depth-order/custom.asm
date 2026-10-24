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
COUNT: defb 0
VALID: defb 0
Z0: defb 0
Z1: defb 0
Z2: defb 0
Z3: defb 0
Z4: defb 0
Z5: defb 0
Z6: defb 0
Z7: defb 0
I0: defb 0
I1: defb 0
I2: defb 0
I3: defb 0
I4: defb 0
I5: defb 0
I6: defb 0
I7: defb 0
T0: defb 0
T1: defb 0
T2: defb 0
T3: defb 0
T4: defb 0
T5: defb 0
T6: defb 0
EXPR_SAVE: defb 0
input_ptr: defw 0
output_ptr: defw 0
cases_left: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 1300,0
    end start
