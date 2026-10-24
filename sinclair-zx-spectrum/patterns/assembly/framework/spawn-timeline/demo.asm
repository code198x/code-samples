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
EVENT: defb 0
FIRED: defb 0
INDEX: defb 0
WAIT: defb 0
COUNT: defb 0
DONE: defb 0
VALID: defb 0
E0: defb 0
E1: defb 0
E2: defb 0
E3: defb 0
L0: defb 0
L1: defb 0
L2: defb 0
L3: defb 0
T0: defb 0
input_ptr: defw 0
output_ptr: defw 0
cases_left: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 1300,0
    end start
