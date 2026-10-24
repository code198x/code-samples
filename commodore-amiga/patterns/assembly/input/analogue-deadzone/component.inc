; SPDX-License-Identifier: MIT
; Turn an Analogue Axis into Intent. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
analogue_deadzone_init:
    move.b #0,d0
    move.b d0,SAMPLE
    move.b d0,CENTRE
    move.b d0,RADIUS
    move.b d0,DIRECTION
    move.b d0,MAGNITUDE
    move.b d0,VALID
    move.b d0,T0
    rts
analogue_deadzone_step:
; DIRECTION = 0
    move.b #0,d0
    move.b d0,DIRECTION
; MAGNITUDE = 0
    move.b #0,d0
    move.b d0,MAGNITUDE
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if RADIUS >= 128:
    move.b RADIUS,d0
    cmp.b #128,d0
    bcc analogue_deadzone_L1
    jmp analogue_deadzone_L2
analogue_deadzone_L1:
; return
    rts
    jmp analogue_deadzone_L3
analogue_deadzone_L2:
analogue_deadzone_L3:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if SAMPLE >= CENTRE:
    move.b SAMPLE,d0
    move.b CENTRE,d1
    cmp.b d1,d0
    bcc analogue_deadzone_L4
    jmp analogue_deadzone_L5
analogue_deadzone_L4:
; T0 = SAMPLE - CENTRE
    move.b SAMPLE,d0
    move.b CENTRE,d1
    sub.b d1,d0
    move.b d0,T0
; if T0 > RADIUS:
    move.b T0,d0
    move.b RADIUS,d1
    cmp.b d1,d0
    bhi analogue_deadzone_L7
    jmp analogue_deadzone_L8
analogue_deadzone_L7:
; MAGNITUDE = T0 - RADIUS
    move.b T0,d0
    move.b RADIUS,d1
    sub.b d1,d0
    move.b d0,MAGNITUDE
; DIRECTION = 2
    move.b #2,d0
    move.b d0,DIRECTION
    jmp analogue_deadzone_L9
analogue_deadzone_L8:
analogue_deadzone_L9:
    jmp analogue_deadzone_L6
analogue_deadzone_L5:
; T0 = CENTRE - SAMPLE
    move.b CENTRE,d0
    move.b SAMPLE,d1
    sub.b d1,d0
    move.b d0,T0
; if T0 > RADIUS:
    move.b T0,d0
    move.b RADIUS,d1
    cmp.b d1,d0
    bhi analogue_deadzone_L10
    jmp analogue_deadzone_L11
analogue_deadzone_L10:
; MAGNITUDE = T0 - RADIUS
    move.b T0,d0
    move.b RADIUS,d1
    sub.b d1,d0
    move.b d0,MAGNITUDE
; DIRECTION = 1
    move.b #1,d0
    move.b d0,DIRECTION
    jmp analogue_deadzone_L12
analogue_deadzone_L11:
analogue_deadzone_L12:
analogue_deadzone_L6:
    rts
component_end:
