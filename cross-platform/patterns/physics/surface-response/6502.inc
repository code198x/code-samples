; SPDX-License-Identifier: MIT
; Reflect a Surface-normal Speed with Restitution. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
surface_response_init:
    lda #0
    sta NORMAL_OUT
    sta DIRECTION_OUT
    sta TANGENT_OUT
    sta VALID
    sta NORMAL_IN
    sta DIRECTION_IN
    sta TANGENT_IN
    sta RESTITUTION
    sta T0
    sta T1
    sta T2
    sta T3
    rts
surface_response_step:
; NORMAL_OUT = 0
    lda #0
    sta NORMAL_OUT
; DIRECTION_OUT = 0
    lda #0
    sta DIRECTION_OUT
; TANGENT_OUT = 0
    lda #0
    sta TANGENT_OUT
; VALID = 0
    lda #0
    sta VALID
; if DIRECTION_IN > 1:
    lda DIRECTION_IN
    cmp #1
    beq surface_response_L5
    bcs surface_response_L4
surface_response_L5:
    jmp surface_response_L2
surface_response_L4:
    jmp surface_response_L1
surface_response_L1:
; return
    rts
    jmp surface_response_L3
surface_response_L2:
surface_response_L3:
; if RESTITUTION > 4:
    lda RESTITUTION
    cmp #4
    beq surface_response_L10
    bcs surface_response_L9
surface_response_L10:
    jmp surface_response_L7
surface_response_L9:
    jmp surface_response_L6
surface_response_L6:
; return
    rts
    jmp surface_response_L8
surface_response_L7:
surface_response_L8:
; VALID = 1
    lda #1
    sta VALID
; DIRECTION_OUT = DIRECTION_IN ^ 1
    lda DIRECTION_IN
    eor #1
    sta DIRECTION_OUT
; TANGENT_OUT = TANGENT_IN
    lda TANGENT_IN
    sta TANGENT_OUT
; T0 = NORMAL_IN >> 2
    lda NORMAL_IN
    lsr
    lsr
    sta T0
; T1 = NORMAL_IN & 3
    lda NORMAL_IN
    and #3
    sta T1
; T2 = 0
    lda #0
    sta T2
; T3 = RESTITUTION
    lda RESTITUTION
    sta T3
; while T3 != 0:
surface_response_L11:
    lda T3
    cmp #0
    bne surface_response_L14
surface_response_L15:
    jmp surface_response_L13
surface_response_L14:
    jmp surface_response_L12
surface_response_L12:
; NORMAL_OUT = NORMAL_OUT + T0
    lda NORMAL_OUT
    clc
    adc T0
    sta NORMAL_OUT
; T2 = T2 + T1
    lda T2
    clc
    adc T1
    sta T2
; T3 = T3 - 1
    lda T3
    sec
    sbc #1
    sta T3
    jmp surface_response_L11
surface_response_L13:
; T2 = T2 >> 2
    lda T2
    lsr
    lsr
    sta T2
; NORMAL_OUT = NORMAL_OUT + T2
    lda NORMAL_OUT
    clc
    adc T2
    sta NORMAL_OUT
    rts
component_end:
