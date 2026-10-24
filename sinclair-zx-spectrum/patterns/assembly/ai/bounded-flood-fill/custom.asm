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
SEED: defb 0
REPLACEMENT: defb 0
CHANGED: defb 0
VALID: defb 0
C0: defb 0
C1: defb 0
C2: defb 0
C3: defb 0
C4: defb 0
C5: defb 0
C6: defb 0
C7: defb 0
C8: defb 0
C9: defb 0
C10: defb 0
C11: defb 0
C12: defb 0
C13: defb 0
C14: defb 0
C15: defb 0
T0: defb 0
T1: defb 0
T2: defb 0
T3: defb 0
T4: defb 0
T5: defb 0
T6: defb 0
T7: defb 0
EXPR_SAVE: defb 0
V0: defb 0
V1: defb 0
V2: defb 0
V3: defb 0
V4: defb 0
V5: defb 0
V6: defb 0
V7: defb 0
V8: defb 0
V9: defb 0
V10: defb 0
V11: defb 0
V12: defb 0
V13: defb 0
V14: defb 0
V15: defb 0
input_ptr: defw 0
output_ptr: defw 0
cases_left: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 1300,0
    end start
