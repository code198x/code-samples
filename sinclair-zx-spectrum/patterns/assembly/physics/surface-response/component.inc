; SPDX-License-Identifier: MIT
; Reflect a Surface-normal Speed with Restitution. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
surface_response_init:
    ld a,0
    ld (NORMAL_OUT),a
    ld (DIRECTION_OUT),a
    ld (TANGENT_OUT),a
    ld (VALID),a
    ld (NORMAL_IN),a
    ld (DIRECTION_IN),a
    ld (TANGENT_IN),a
    ld (RESTITUTION),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ret
surface_response_step:
; NORMAL_OUT = 0
    ld a,0
    ld (NORMAL_OUT),a
; DIRECTION_OUT = 0
    ld a,0
    ld (DIRECTION_OUT),a
; TANGENT_OUT = 0
    ld a,0
    ld (TANGENT_OUT),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if DIRECTION_IN > 1:
    ld a,(DIRECTION_IN)
    cp 1
    jp z,surface_response_L2
    jp nc,surface_response_L1
    jp surface_response_L2
surface_response_L1:
; return
    ret
    jp surface_response_L3
surface_response_L2:
surface_response_L3:
; if RESTITUTION > 4:
    ld a,(RESTITUTION)
    cp 4
    jp z,surface_response_L5
    jp nc,surface_response_L4
    jp surface_response_L5
surface_response_L4:
; return
    ret
    jp surface_response_L6
surface_response_L5:
surface_response_L6:
; VALID = 1
    ld a,1
    ld (VALID),a
; DIRECTION_OUT = DIRECTION_IN ^ 1
    ld a,(DIRECTION_IN)
    xor 1
    ld (DIRECTION_OUT),a
; TANGENT_OUT = TANGENT_IN
    ld a,(TANGENT_IN)
    ld (TANGENT_OUT),a
; T0 = NORMAL_IN >> 2
    ld a,(NORMAL_IN)
    srl a
    srl a
    ld (T0),a
; T1 = NORMAL_IN & 3
    ld a,(NORMAL_IN)
    and 3
    ld (T1),a
; T2 = 0
    ld a,0
    ld (T2),a
; T3 = RESTITUTION
    ld a,(RESTITUTION)
    ld (T3),a
; while T3 != 0:
surface_response_L7:
    ld a,(T3)
    cp 0
    jp nz,surface_response_L8
    jp surface_response_L9
surface_response_L8:
; NORMAL_OUT = NORMAL_OUT + T0
    ld a,(NORMAL_OUT)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    add a,c
    ld (NORMAL_OUT),a
; T2 = T2 + T1
    ld a,(T2)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    add a,c
    ld (T2),a
; T3 = T3 - 1
    ld a,(T3)
    sub 1
    ld (T3),a
    jp surface_response_L7
surface_response_L9:
; T2 = T2 >> 2
    ld a,(T2)
    srl a
    srl a
    ld (T2),a
; NORMAL_OUT = NORMAL_OUT + T2
    ld a,(NORMAL_OUT)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    add a,c
    ld (NORMAL_OUT),a
    ret
component_end:
