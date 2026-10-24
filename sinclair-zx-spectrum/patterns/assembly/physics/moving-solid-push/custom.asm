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
POSITION: defb 0
PUSHED: defb 0
BLOCKED: defb 0
VALID: defb 0
ACTOR_POSITION: defb 0
ACTOR_SIZE: defb 0
SOLID_OLD: defb 0
SOLID_NEW: defb 0
SOLID_SIZE: defb 0
MINIMUM: defb 0
MAXIMUM: defb 0
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
