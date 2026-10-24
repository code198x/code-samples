; SPDX-License-Identifier: MIT
; Reflect a Surface-normal Speed with Restitution. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
surface_response_init:
    move.b #0,d0
    move.b d0,NORMAL_OUT
    move.b d0,DIRECTION_OUT
    move.b d0,TANGENT_OUT
    move.b d0,VALID
    move.b d0,NORMAL_IN
    move.b d0,DIRECTION_IN
    move.b d0,TANGENT_IN
    move.b d0,RESTITUTION
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    rts
surface_response_step:
; NORMAL_OUT = 0
    move.b #0,d0
    move.b d0,NORMAL_OUT
; DIRECTION_OUT = 0
    move.b #0,d0
    move.b d0,DIRECTION_OUT
; TANGENT_OUT = 0
    move.b #0,d0
    move.b d0,TANGENT_OUT
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if DIRECTION_IN > 1:
    move.b DIRECTION_IN,d0
    cmp.b #1,d0
    bhi surface_response_L1
    jmp surface_response_L2
surface_response_L1:
; return
    rts
    jmp surface_response_L3
surface_response_L2:
surface_response_L3:
; if RESTITUTION > 4:
    move.b RESTITUTION,d0
    cmp.b #4,d0
    bhi surface_response_L4
    jmp surface_response_L5
surface_response_L4:
; return
    rts
    jmp surface_response_L6
surface_response_L5:
surface_response_L6:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; DIRECTION_OUT = DIRECTION_IN ^ 1
    move.b DIRECTION_IN,d0
    eor.b #1,d0
    move.b d0,DIRECTION_OUT
; TANGENT_OUT = TANGENT_IN
    move.b TANGENT_IN,d0
    move.b d0,TANGENT_OUT
; T0 = NORMAL_IN >> 2
    move.b NORMAL_IN,d0
    lsr.b #2,d0
    move.b d0,T0
; T1 = NORMAL_IN & 3
    move.b NORMAL_IN,d0
    and.b #3,d0
    move.b d0,T1
; T2 = 0
    move.b #0,d0
    move.b d0,T2
; T3 = RESTITUTION
    move.b RESTITUTION,d0
    move.b d0,T3
; while T3 != 0:
surface_response_L7:
    move.b T3,d0
    cmp.b #0,d0
    bne surface_response_L8
    jmp surface_response_L9
surface_response_L8:
; NORMAL_OUT = NORMAL_OUT + T0
    move.b NORMAL_OUT,d0
    move.b T0,d1
    add.b d1,d0
    move.b d0,NORMAL_OUT
; T2 = T2 + T1
    move.b T2,d0
    move.b T1,d1
    add.b d1,d0
    move.b d0,T2
; T3 = T3 - 1
    move.b T3,d0
    sub.b #1,d0
    move.b d0,T3
    jmp surface_response_L7
surface_response_L9:
; T2 = T2 >> 2
    move.b T2,d0
    lsr.b #2,d0
    move.b d0,T2
; NORMAL_OUT = NORMAL_OUT + T2
    move.b NORMAL_OUT,d0
    move.b T2,d1
    add.b d1,d0
    move.b d0,NORMAL_OUT
    rts
component_end:
