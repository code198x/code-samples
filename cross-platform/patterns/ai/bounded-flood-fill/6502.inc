; SPDX-License-Identifier: MIT
; Fill a Connected Grid Region. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_flood_fill_init:
    lda #0
    sta SEED
    sta REPLACEMENT
    sta CHANGED
    sta VALID
    sta C0
    sta C1
    sta C2
    sta C3
    sta C4
    sta C5
    sta C6
    sta C7
    sta C8
    sta C9
    sta C10
    sta C11
    sta C12
    sta C13
    sta C14
    sta C15
    sta T0
    sta T1
    sta T2
    sta T3
    sta T4
    sta T5
    sta T6
    sta T7
    sta EXPR_SAVE
    sta V0
    sta V1
    sta V2
    sta V3
    sta V4
    sta V5
    sta V6
    sta V7
    sta V8
    sta V9
    sta V10
    sta V11
    sta V12
    sta V13
    sta V14
    sta V15
    rts
bounded_flood_fill_step:
; VALID = 0
    lda #0
    sta VALID
; CHANGED = 0
    lda #0
    sta CHANGED
; if SEED >= 16:
    lda SEED
    cmp #16
    bcs bounded_flood_fill_L4
bounded_flood_fill_L5:
    jmp bounded_flood_fill_L2
bounded_flood_fill_L4:
    jmp bounded_flood_fill_L1
bounded_flood_fill_L1:
; return
    rts
    jmp bounded_flood_fill_L3
bounded_flood_fill_L2:
bounded_flood_fill_L3:
; VALID = 1
    lda #1
    sta VALID
; T0 = C[SEED]
    ldx SEED
    lda C0,x
    sta T0
; if T0 == REPLACEMENT:
    lda T0
    cmp REPLACEMENT
    beq bounded_flood_fill_L9
bounded_flood_fill_L10:
    jmp bounded_flood_fill_L7
bounded_flood_fill_L9:
    jmp bounded_flood_fill_L6
bounded_flood_fill_L6:
; return
    rts
    jmp bounded_flood_fill_L8
bounded_flood_fill_L7:
bounded_flood_fill_L8:
; T1 = 0
    lda #0
    sta T1
; while T1 < 16:
bounded_flood_fill_L11:
    lda T1
    cmp #16
    bcc bounded_flood_fill_L14
bounded_flood_fill_L15:
    jmp bounded_flood_fill_L13
bounded_flood_fill_L14:
    jmp bounded_flood_fill_L12
bounded_flood_fill_L12:
; V[T1] = 0
    lda #0
    sta EXPR_SAVE
    ldx T1
    lda EXPR_SAVE
    sta V0,x
; T1 = T1 + 1
    lda T1
    clc
    adc #1
    sta T1
    jmp bounded_flood_fill_L11
bounded_flood_fill_L13:
; V[SEED] = 1
    lda #1
    sta EXPR_SAVE
    ldx SEED
    lda EXPR_SAVE
    sta V0,x
; T2 = 1
    lda #1
    sta T2
; while T2 != 0:
bounded_flood_fill_L16:
    lda T2
    cmp #0
    bne bounded_flood_fill_L19
bounded_flood_fill_L20:
    jmp bounded_flood_fill_L18
bounded_flood_fill_L19:
    jmp bounded_flood_fill_L17
bounded_flood_fill_L17:
; T2 = 0
    lda #0
    sta T2
; T1 = 0
    lda #0
    sta T1
; while T1 < 16:
bounded_flood_fill_L21:
    lda T1
    cmp #16
    bcc bounded_flood_fill_L24
bounded_flood_fill_L25:
    jmp bounded_flood_fill_L23
bounded_flood_fill_L24:
    jmp bounded_flood_fill_L22
bounded_flood_fill_L22:
; T3 = V[T1]
    ldx T1
    lda V0,x
    sta T3
; if T3 == 0:
    lda T3
    cmp #0
    beq bounded_flood_fill_L29
bounded_flood_fill_L30:
    jmp bounded_flood_fill_L27
bounded_flood_fill_L29:
    jmp bounded_flood_fill_L26
bounded_flood_fill_L26:
; T3 = C[T1]
    ldx T1
    lda C0,x
    sta T3
; if T3 == T0:
    lda T3
    cmp T0
    beq bounded_flood_fill_L34
bounded_flood_fill_L35:
    jmp bounded_flood_fill_L32
bounded_flood_fill_L34:
    jmp bounded_flood_fill_L31
bounded_flood_fill_L31:
; T4 = 0
    lda #0
    sta T4
; T5 = T1 & 3
    lda T1
    and #3
    sta T5
; if T5 != 0:
    lda T5
    cmp #0
    bne bounded_flood_fill_L39
bounded_flood_fill_L40:
    jmp bounded_flood_fill_L37
bounded_flood_fill_L39:
    jmp bounded_flood_fill_L36
bounded_flood_fill_L36:
; T6 = T1 - 1
    lda T1
    sec
    sbc #1
    sta T6
; T4 = V[T6]
    ldx T6
    lda V0,x
    sta T4
    jmp bounded_flood_fill_L38
bounded_flood_fill_L37:
bounded_flood_fill_L38:
; if T5 != 3:
    lda T5
    cmp #3
    bne bounded_flood_fill_L44
bounded_flood_fill_L45:
    jmp bounded_flood_fill_L42
bounded_flood_fill_L44:
    jmp bounded_flood_fill_L41
bounded_flood_fill_L41:
; T6 = T1 + 1
    lda T1
    clc
    adc #1
    sta T6
; T7 = V[T6]
    ldx T6
    lda V0,x
    sta T7
; T4 = T4 | T7
    lda T4
    ora T7
    sta T4
    jmp bounded_flood_fill_L43
bounded_flood_fill_L42:
bounded_flood_fill_L43:
; if T1 >= 4:
    lda T1
    cmp #4
    bcs bounded_flood_fill_L49
bounded_flood_fill_L50:
    jmp bounded_flood_fill_L47
bounded_flood_fill_L49:
    jmp bounded_flood_fill_L46
bounded_flood_fill_L46:
; T6 = T1 - 4
    lda T1
    sec
    sbc #4
    sta T6
; T7 = V[T6]
    ldx T6
    lda V0,x
    sta T7
; T4 = T4 | T7
    lda T4
    ora T7
    sta T4
    jmp bounded_flood_fill_L48
bounded_flood_fill_L47:
bounded_flood_fill_L48:
; if T1 < 12:
    lda T1
    cmp #12
    bcc bounded_flood_fill_L54
bounded_flood_fill_L55:
    jmp bounded_flood_fill_L52
bounded_flood_fill_L54:
    jmp bounded_flood_fill_L51
bounded_flood_fill_L51:
; T6 = T1 + 4
    lda T1
    clc
    adc #4
    sta T6
; T7 = V[T6]
    ldx T6
    lda V0,x
    sta T7
; T4 = T4 | T7
    lda T4
    ora T7
    sta T4
    jmp bounded_flood_fill_L53
bounded_flood_fill_L52:
bounded_flood_fill_L53:
; if T4 != 0:
    lda T4
    cmp #0
    bne bounded_flood_fill_L59
bounded_flood_fill_L60:
    jmp bounded_flood_fill_L57
bounded_flood_fill_L59:
    jmp bounded_flood_fill_L56
bounded_flood_fill_L56:
; V[T1] = 1
    lda #1
    sta EXPR_SAVE
    ldx T1
    lda EXPR_SAVE
    sta V0,x
; T2 = 1
    lda #1
    sta T2
    jmp bounded_flood_fill_L58
bounded_flood_fill_L57:
bounded_flood_fill_L58:
    jmp bounded_flood_fill_L33
bounded_flood_fill_L32:
bounded_flood_fill_L33:
    jmp bounded_flood_fill_L28
bounded_flood_fill_L27:
bounded_flood_fill_L28:
; T1 = T1 + 1
    lda T1
    clc
    adc #1
    sta T1
    jmp bounded_flood_fill_L21
bounded_flood_fill_L23:
    jmp bounded_flood_fill_L16
bounded_flood_fill_L18:
; T1 = 0
    lda #0
    sta T1
; while T1 < 16:
bounded_flood_fill_L61:
    lda T1
    cmp #16
    bcc bounded_flood_fill_L64
bounded_flood_fill_L65:
    jmp bounded_flood_fill_L63
bounded_flood_fill_L64:
    jmp bounded_flood_fill_L62
bounded_flood_fill_L62:
; T3 = V[T1]
    ldx T1
    lda V0,x
    sta T3
; if T3 != 0:
    lda T3
    cmp #0
    bne bounded_flood_fill_L69
bounded_flood_fill_L70:
    jmp bounded_flood_fill_L67
bounded_flood_fill_L69:
    jmp bounded_flood_fill_L66
bounded_flood_fill_L66:
; C[T1] = REPLACEMENT
    lda REPLACEMENT
    sta EXPR_SAVE
    ldx T1
    lda EXPR_SAVE
    sta C0,x
; CHANGED = CHANGED + 1
    lda CHANGED
    clc
    adc #1
    sta CHANGED
    jmp bounded_flood_fill_L68
bounded_flood_fill_L67:
bounded_flood_fill_L68:
; T1 = T1 + 1
    lda T1
    clc
    adc #1
    sta T1
    jmp bounded_flood_fill_L61
bounded_flood_fill_L63:
    rts
component_end:
