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
OUT_LEFT: defb 0
OUT_TOP: defb 0
OUT_RIGHT: defb 0
OUT_BOTTOM: defb 0
VISIBLE: defb 0
VALID: defb 0
LEFT: defb 0
TOP: defb 0
RIGHT: defb 0
BOTTOM: defb 0
VIEW_LEFT: defb 0
VIEW_TOP: defb 0
VIEW_RIGHT: defb 0
VIEW_BOTTOM: defb 0
T0: defb 0
T1: defb 0
T2: defb 0
T3: defb 0
input_ptr: defw 0
output_ptr: defw 0
cases_left: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 1300,0
    end start
