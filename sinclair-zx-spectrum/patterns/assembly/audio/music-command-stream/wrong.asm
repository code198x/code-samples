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
NOTE: defb 0
EVENT: defb 0
FINISHED: defb 0
VALID: defb 0
INDEX: defb 0
REMAINING: defb 0
COUNT: defb 0
N0: defb 0
N1: defb 0
N2: defb 0
N3: defb 0
N4: defb 0
N5: defb 0
N6: defb 0
N7: defb 0
U0: defb 0
U1: defb 0
U2: defb 0
U3: defb 0
U4: defb 0
U5: defb 0
U6: defb 0
U7: defb 0
T0: defb 0
T1: defb 0
input_ptr: defw 0
output_ptr: defw 0
cases_left: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 1300,0
    end start
