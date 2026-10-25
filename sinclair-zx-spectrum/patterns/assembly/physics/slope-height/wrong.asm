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
LOCAL_X: defb 0
BASE_Y: defb 0
MIRROR_X: defb 0
SURFACE: defb 0
VALID: defb 0
H0: defb 0
H1: defb 0
H2: defb 0
H3: defb 0
H4: defb 0
H5: defb 0
H6: defb 0
H7: defb 0
T0: defb 0
T1: defb 0
T2: defb 0
input_ptr: defw 0
output_ptr: defw 0
cases_left: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 1300,0
    end start
