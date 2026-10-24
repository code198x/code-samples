; SPDX-License-Identifier: MIT
; Find an Integer Square Root. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
integer_square_root_init:
    lda #0
    sta ROOT
    sta REMAINDER_LO
    sta REMAINDER_HI
    sta NUMBER_LO
    sta NUMBER_HI
    sta T0
    sta T1
    sta T2
    sta T3
    rts
integer_square_root_step:
; ROOT = 0
    lda #0
    sta ROOT
; REMAINDER_LO = NUMBER_LO
    lda NUMBER_LO
    sta REMAINDER_LO
; REMAINDER_HI = NUMBER_HI
    lda NUMBER_HI
    sta REMAINDER_HI
; T0 = 1
    lda #1
    sta T0
; T1 = 0
    lda #0
    sta T1
; T2 = 1
    lda #1
    sta T2
; while T2 == 1:
integer_square_root_L1:
    lda T2
    cmp #1
    beq integer_square_root_L4
integer_square_root_L5:
    jmp integer_square_root_L3
integer_square_root_L4:
    jmp integer_square_root_L2
integer_square_root_L2:
; if REMAINDER_HI < T1:
    lda REMAINDER_HI
    cmp T1
    bcc integer_square_root_L9
integer_square_root_L10:
    jmp integer_square_root_L7
integer_square_root_L9:
    jmp integer_square_root_L6
integer_square_root_L6:
; return
    rts
    jmp integer_square_root_L8
integer_square_root_L7:
integer_square_root_L8:
; if REMAINDER_HI == T1:
    lda REMAINDER_HI
    cmp T1
    beq integer_square_root_L14
integer_square_root_L15:
    jmp integer_square_root_L12
integer_square_root_L14:
    jmp integer_square_root_L11
integer_square_root_L11:
; if REMAINDER_LO < T0:
    lda REMAINDER_LO
    cmp T0
    bcc integer_square_root_L19
integer_square_root_L20:
    jmp integer_square_root_L17
integer_square_root_L19:
    jmp integer_square_root_L16
integer_square_root_L16:
; return
    rts
    jmp integer_square_root_L18
integer_square_root_L17:
integer_square_root_L18:
    jmp integer_square_root_L13
integer_square_root_L12:
integer_square_root_L13:
; T3 = 0
    lda #0
    sta T3
; if REMAINDER_LO < T0:
    lda REMAINDER_LO
    cmp T0
    bcc integer_square_root_L24
integer_square_root_L25:
    jmp integer_square_root_L22
integer_square_root_L24:
    jmp integer_square_root_L21
integer_square_root_L21:
; T3 = 1
    lda #1
    sta T3
    jmp integer_square_root_L23
integer_square_root_L22:
integer_square_root_L23:
; REMAINDER_LO = REMAINDER_LO - T0
    lda REMAINDER_LO
    sec
    sbc T0
    sta REMAINDER_LO
; REMAINDER_HI = REMAINDER_HI - T1
    lda REMAINDER_HI
    sec
    sbc T1
    sta REMAINDER_HI
; REMAINDER_HI = REMAINDER_HI - T3
    lda REMAINDER_HI
    sec
    sbc T3
    sta REMAINDER_HI
; ROOT = ROOT + 1
    lda ROOT
    clc
    adc #1
    sta ROOT
; T3 = T0
    lda T0
    sta T3
; T0 = T0 + 2
    lda T0
    clc
    adc #2
    sta T0
; if T0 < T3:
    lda T0
    cmp T3
    bcc integer_square_root_L29
integer_square_root_L30:
    jmp integer_square_root_L27
integer_square_root_L29:
    jmp integer_square_root_L26
integer_square_root_L26:
; T1 = T1 + 1
    lda T1
    clc
    adc #1
    sta T1
    jmp integer_square_root_L28
integer_square_root_L27:
integer_square_root_L28:
    jmp integer_square_root_L1
integer_square_root_L3:
    rts
component_end:
