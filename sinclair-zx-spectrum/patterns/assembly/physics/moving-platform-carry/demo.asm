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
POSITION: defb 0
CLAMPED: defb 0
VALID: defb 0
PASSENGER: defb 0
PLATFORM_OLD: defb 0
PLATFORM_NEW: defb 0
SUPPORTED: defb 0
MINIMUM: defb 0
MAXIMUM: defb 0
T0: defb 0
T1: defb 0
input_ptr: defw 0
output_ptr: defw 0
cases_left: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 1300,0
    end start
