; SPDX-License-Identifier: MIT
; Query a Small Slope Height Profile. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
slope_height_init:
    lda #0
    sta LOCAL_X
    sta BASE_Y
    sta MIRROR
    sta SURFACE
    sta VALID
    sta H0
    sta H1
    sta H2
    sta H3
    sta H4
    sta H5
    sta H6
    sta H7
    sta T0
    sta T1
    sta T2
    rts
slope_height_step:
; SURFACE = 255
    lda #255
    sta SURFACE
; VALID = 0
    lda #0
    sta VALID
; if LOCAL_X >= 8:
    lda LOCAL_X
    cmp #8
    bcs slope_height_L4
slope_height_L5:
    jmp slope_height_L2
slope_height_L4:
    jmp slope_height_L1
slope_height_L1:
; return
    rts
    jmp slope_height_L3
slope_height_L2:
slope_height_L3:
; T0 = LOCAL_X
    lda LOCAL_X
    sta T0
; if MIRROR != 0:
    lda MIRROR
    cmp #0
    bne slope_height_L9
slope_height_L10:
    jmp slope_height_L7
slope_height_L9:
    jmp slope_height_L6
slope_height_L6:
; T0 = 7 - T0
    lda #7
    sec
    sbc T0
    sta T0
    jmp slope_height_L8
slope_height_L7:
slope_height_L8:
; T1 = H[T0]
    ldx T0
    lda H0,x
    sta T1
; T2 = 255 - BASE_Y
    lda #255
    sec
    sbc BASE_Y
    sta T2
; if T1 > T2:
    lda T1
    cmp T2
    beq slope_height_L15
    bcs slope_height_L14
slope_height_L15:
    jmp slope_height_L12
slope_height_L14:
    jmp slope_height_L11
slope_height_L11:
; return
    rts
    jmp slope_height_L13
slope_height_L12:
slope_height_L13:
; SURFACE = BASE_Y + T1
    lda BASE_Y
    clc
    adc T1
    sta SURFACE
; VALID = 1
    lda #1
    sta VALID
    rts
component_end:
