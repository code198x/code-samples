; SPDX-License-Identifier: MIT
; Encode a Small Run-length Block. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_rle_encoder_init:
    lda #0
    sta WRITTEN
    sta ERROR
    sta VALID
    sta INPUT_COUNT
    sta CAPACITY
    sta B0
    sta B1
    sta B2
    sta B3
    sta B4
    sta B5
    sta B6
    sta B7
    sta R0
    sta R1
    sta R2
    sta R3
    sta R4
    sta R5
    sta R6
    sta R7
    sta R8
    sta R9
    sta R10
    sta R11
    sta R12
    sta R13
    sta R14
    sta R15
    sta T0
    sta T1
    sta T2
    sta T3
    sta T4
    sta EXPR_SAVE
    rts
bounded_rle_encoder_step:
; WRITTEN = 0
    lda #0
    sta WRITTEN
; ERROR = 1
    lda #1
    sta ERROR
; VALID = 0
    lda #0
    sta VALID
; if INPUT_COUNT > 8:
    lda INPUT_COUNT
    cmp #8
    beq bounded_rle_encoder_L5
    bcs bounded_rle_encoder_L4
bounded_rle_encoder_L5:
    jmp bounded_rle_encoder_L2
bounded_rle_encoder_L4:
    jmp bounded_rle_encoder_L1
bounded_rle_encoder_L1:
; return
    rts
    jmp bounded_rle_encoder_L3
bounded_rle_encoder_L2:
bounded_rle_encoder_L3:
; if CAPACITY > 16:
    lda CAPACITY
    cmp #16
    beq bounded_rle_encoder_L10
    bcs bounded_rle_encoder_L9
bounded_rle_encoder_L10:
    jmp bounded_rle_encoder_L7
bounded_rle_encoder_L9:
    jmp bounded_rle_encoder_L6
bounded_rle_encoder_L6:
; return
    rts
    jmp bounded_rle_encoder_L8
bounded_rle_encoder_L7:
bounded_rle_encoder_L8:
; VALID = 1
    lda #1
    sta VALID
; ERROR = 0
    lda #0
    sta ERROR
; if INPUT_COUNT == 0:
    lda INPUT_COUNT
    cmp #0
    beq bounded_rle_encoder_L14
bounded_rle_encoder_L15:
    jmp bounded_rle_encoder_L12
bounded_rle_encoder_L14:
    jmp bounded_rle_encoder_L11
bounded_rle_encoder_L11:
; return
    rts
    jmp bounded_rle_encoder_L13
bounded_rle_encoder_L12:
bounded_rle_encoder_L13:
; T0 = 1
    lda #1
    sta T0
; T1 = B[0]
    ldx #0
    lda B0,x
    sta T1
; T2 = 1
    lda #1
    sta T2
; while T0 < INPUT_COUNT:
bounded_rle_encoder_L16:
    lda T0
    cmp INPUT_COUNT
    bcc bounded_rle_encoder_L19
bounded_rle_encoder_L20:
    jmp bounded_rle_encoder_L18
bounded_rle_encoder_L19:
    jmp bounded_rle_encoder_L17
bounded_rle_encoder_L17:
; T3 = B[T0]
    ldx T0
    lda B0,x
    sta T3
; if T3 != T1:
    lda T3
    cmp T1
    bne bounded_rle_encoder_L24
bounded_rle_encoder_L25:
    jmp bounded_rle_encoder_L22
bounded_rle_encoder_L24:
    jmp bounded_rle_encoder_L21
bounded_rle_encoder_L21:
; T2 = T2 + 1
    lda T2
    clc
    adc #1
    sta T2
; T1 = T3
    lda T3
    sta T1
    jmp bounded_rle_encoder_L23
bounded_rle_encoder_L22:
bounded_rle_encoder_L23:
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp bounded_rle_encoder_L16
bounded_rle_encoder_L18:
; T2 = T2 << 1
    lda T2
    asl
    sta T2
; if T2 > CAPACITY:
    lda T2
    cmp CAPACITY
    beq bounded_rle_encoder_L30
    bcs bounded_rle_encoder_L29
bounded_rle_encoder_L30:
    jmp bounded_rle_encoder_L27
bounded_rle_encoder_L29:
    jmp bounded_rle_encoder_L26
bounded_rle_encoder_L26:
; ERROR = 2
    lda #2
    sta ERROR
; return
    rts
    jmp bounded_rle_encoder_L28
bounded_rle_encoder_L27:
bounded_rle_encoder_L28:
; T0 = 0
    lda #0
    sta T0
; T1 = 0
    lda #0
    sta T1
; while T0 < INPUT_COUNT:
bounded_rle_encoder_L31:
    lda T0
    cmp INPUT_COUNT
    bcc bounded_rle_encoder_L34
bounded_rle_encoder_L35:
    jmp bounded_rle_encoder_L33
bounded_rle_encoder_L34:
    jmp bounded_rle_encoder_L32
bounded_rle_encoder_L32:
; T2 = B[T0]
    ldx T0
    lda B0,x
    sta T2
; T3 = 1
    lda #1
    sta T3
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
; while T0 < INPUT_COUNT:
bounded_rle_encoder_L36:
    lda T0
    cmp INPUT_COUNT
    bcc bounded_rle_encoder_L39
bounded_rle_encoder_L40:
    jmp bounded_rle_encoder_L38
bounded_rle_encoder_L39:
    jmp bounded_rle_encoder_L37
bounded_rle_encoder_L37:
; T4 = B[T0]
    ldx T0
    lda B0,x
    sta T4
; if T4 != T2:
    lda T4
    cmp T2
    bne bounded_rle_encoder_L44
bounded_rle_encoder_L45:
    jmp bounded_rle_encoder_L42
bounded_rle_encoder_L44:
    jmp bounded_rle_encoder_L41
bounded_rle_encoder_L41:
; break
    jmp bounded_rle_encoder_L38
    jmp bounded_rle_encoder_L43
bounded_rle_encoder_L42:
bounded_rle_encoder_L43:
; T3 = T3 + 1
    lda T3
    clc
    adc #1
    sta T3
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp bounded_rle_encoder_L36
bounded_rle_encoder_L38:
; R[T1] = T3
    lda T3
    sta EXPR_SAVE
    ldx T1
    lda EXPR_SAVE
    sta R0,x
; T1 = T1 + 1
    lda T1
    clc
    adc #1
    sta T1
; R[T1] = T2
    lda T2
    sta EXPR_SAVE
    ldx T1
    lda EXPR_SAVE
    sta R0,x
; T1 = T1 + 1
    lda T1
    clc
    adc #1
    sta T1
    jmp bounded_rle_encoder_L31
bounded_rle_encoder_L33:
; WRITTEN = T1
    lda T1
    sta WRITTEN
    rts
component_end:
