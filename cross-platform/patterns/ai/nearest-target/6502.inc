; SPDX-License-Identifier: MIT
; Select the Nearest Active Target. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
nearest_target_init:
    lda #0
    sta SLOT
    sta DISTANCE_LO
    sta DISTANCE_HI
    sta FOUND
    sta ACTIVE
    sta ORIGIN_X
    sta ORIGIN_Y
    sta PX0
    sta PX1
    sta PX2
    sta PX3
    sta PY0
    sta PY1
    sta PY2
    sta PY3
    sta T0
    sta T1
    sta T2
    sta T3
    sta T4
    sta T5
    sta T6
    sta T7
    rts
nearest_target_step:
; SLOT = 255
    lda #255
    sta SLOT
; DISTANCE_LO = 0
    lda #0
    sta DISTANCE_LO
; DISTANCE_HI = 0
    lda #0
    sta DISTANCE_HI
; FOUND = 0
    lda #0
    sta FOUND
; T0 = 0
    lda #0
    sta T0
; T1 = 1
    lda #1
    sta T1
; while T0 < 4:
nearest_target_L1:
    lda T0
    cmp #4
    bcc nearest_target_L4
nearest_target_L5:
    jmp nearest_target_L3
nearest_target_L4:
    jmp nearest_target_L2
nearest_target_L2:
; T2 = ACTIVE & T1
    lda ACTIVE
    and T1
    sta T2
; if T2 != 0:
    lda T2
    cmp #0
    bne nearest_target_L9
nearest_target_L10:
    jmp nearest_target_L7
nearest_target_L9:
    jmp nearest_target_L6
nearest_target_L6:
; T2 = PX[T0]
    ldx T0
    lda PX0,x
    sta T2
; if T2 >= ORIGIN_X:
    lda T2
    cmp ORIGIN_X
    bcs nearest_target_L14
nearest_target_L15:
    jmp nearest_target_L12
nearest_target_L14:
    jmp nearest_target_L11
nearest_target_L11:
; T3 = T2 - ORIGIN_X
    lda T2
    sec
    sbc ORIGIN_X
    sta T3
    jmp nearest_target_L13
nearest_target_L12:
; T3 = ORIGIN_X - T2
    lda ORIGIN_X
    sec
    sbc T2
    sta T3
nearest_target_L13:
; T2 = PY[T0]
    ldx T0
    lda PY0,x
    sta T2
; if T2 >= ORIGIN_Y:
    lda T2
    cmp ORIGIN_Y
    bcs nearest_target_L19
nearest_target_L20:
    jmp nearest_target_L17
nearest_target_L19:
    jmp nearest_target_L16
nearest_target_L16:
; T4 = T2 - ORIGIN_Y
    lda T2
    sec
    sbc ORIGIN_Y
    sta T4
    jmp nearest_target_L18
nearest_target_L17:
; T4 = ORIGIN_Y - T2
    lda ORIGIN_Y
    sec
    sbc T2
    sta T4
nearest_target_L18:
; T5 = T3 + T4
    lda T3
    clc
    adc T4
    sta T5
; T6 = 0
    lda #0
    sta T6
; if T5 < T3:
    lda T5
    cmp T3
    bcc nearest_target_L24
nearest_target_L25:
    jmp nearest_target_L22
nearest_target_L24:
    jmp nearest_target_L21
nearest_target_L21:
; T6 = 1
    lda #1
    sta T6
    jmp nearest_target_L23
nearest_target_L22:
nearest_target_L23:
; T7 = 0
    lda #0
    sta T7
; if FOUND == 0:
    lda FOUND
    cmp #0
    beq nearest_target_L29
nearest_target_L30:
    jmp nearest_target_L27
nearest_target_L29:
    jmp nearest_target_L26
nearest_target_L26:
; T7 = 1
    lda #1
    sta T7
    jmp nearest_target_L28
nearest_target_L27:
nearest_target_L28:
; if T6 < DISTANCE_HI:
    lda T6
    cmp DISTANCE_HI
    bcc nearest_target_L34
nearest_target_L35:
    jmp nearest_target_L32
nearest_target_L34:
    jmp nearest_target_L31
nearest_target_L31:
; T7 = 1
    lda #1
    sta T7
    jmp nearest_target_L33
nearest_target_L32:
nearest_target_L33:
; if T6 == DISTANCE_HI:
    lda T6
    cmp DISTANCE_HI
    beq nearest_target_L39
nearest_target_L40:
    jmp nearest_target_L37
nearest_target_L39:
    jmp nearest_target_L36
nearest_target_L36:
; if T5 < DISTANCE_LO:
    lda T5
    cmp DISTANCE_LO
    bcc nearest_target_L44
nearest_target_L45:
    jmp nearest_target_L42
nearest_target_L44:
    jmp nearest_target_L41
nearest_target_L41:
; T7 = 1
    lda #1
    sta T7
    jmp nearest_target_L43
nearest_target_L42:
nearest_target_L43:
    jmp nearest_target_L38
nearest_target_L37:
nearest_target_L38:
; if T7 != 0:
    lda T7
    cmp #0
    bne nearest_target_L49
nearest_target_L50:
    jmp nearest_target_L47
nearest_target_L49:
    jmp nearest_target_L46
nearest_target_L46:
; SLOT = T0
    lda T0
    sta SLOT
; DISTANCE_LO = T5
    lda T5
    sta DISTANCE_LO
; DISTANCE_HI = T6
    lda T6
    sta DISTANCE_HI
; FOUND = 1
    lda #1
    sta FOUND
    jmp nearest_target_L48
nearest_target_L47:
nearest_target_L48:
    jmp nearest_target_L8
nearest_target_L7:
nearest_target_L8:
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
; T1 = T1 << 1
    lda T1
    asl
    sta T1
    jmp nearest_target_L1
nearest_target_L3:
    rts
component_end:
