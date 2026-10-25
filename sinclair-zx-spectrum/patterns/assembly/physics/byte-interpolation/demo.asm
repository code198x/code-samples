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
VALUE: defb 0
START: defb 0
ENDPOINT: defb 0
FRACTION: defb 0
T0: defb 0
T1: defb 0
T2: defb 0
T4: defb 0
T5: defb 0
T6: defb 0
T7: defb 0
T8: defb 0
T9: defb 0
T10: defb 0
T11: defb 0
input_ptr: defw 0
output_ptr: defw 0
cases_left: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 1300,0
    end start
