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
RESULT: defb 0
VALID: defb 0
COUNT: defb 0
MODE: defb 0
CELL: defb 0
VALUE: defb 0
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
J0: defb 0
J1: defb 0
J2: defb 0
J3: defb 0
K0: defb 0
K1: defb 0
K2: defb 0
K3: defb 0
T0: defb 0
T1: defb 0
T2: defb 0
EXPR_SAVE: defb 0
input_ptr: defw 0
output_ptr: defw 0
cases_left: defb 0
ready: defb 0
preview: defs 8,0
OUTPUT: defs 1300,0
    end start
