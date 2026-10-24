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
WRITTEN: defb 0
ERROR: defb 0
INPUT_START: defb 0
INPUT_END: defb 0
OUTPUT_LIMIT: defb 0
BUF0: defb 0
BUF1: defb 0
BUF2: defb 0
BUF3: defb 0
BUF4: defb 0
BUF5: defb 0
BUF6: defb 0
BUF7: defb 0
input_ptr: defw 0
output_ptr: defw 0
cases_left: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 1300,0
    end start
