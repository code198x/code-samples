; SPDX-License-Identifier: MIT
; Push a Block Atomically. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
push_block_transaction_init:
    lda #0
    sta CELL
    sta RESULT
    sta VALID
    sta REQUEST
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
    sta EXPR_SAVE
    rts
push_block_transaction_step:
; RESULT = 0
    lda #0
    sta RESULT
; VALID = 0
    lda #0
    sta VALID
; if CELL >= 16:
    lda CELL
    cmp #16
    bcs push_block_transaction_L4
push_block_transaction_L5:
    jmp push_block_transaction_L2
push_block_transaction_L4:
    jmp push_block_transaction_L1
push_block_transaction_L1:
; return
    rts
    jmp push_block_transaction_L3
push_block_transaction_L2:
push_block_transaction_L3:
; if REQUEST == 0:
    lda REQUEST
    cmp #0
    beq push_block_transaction_L9
push_block_transaction_L10:
    jmp push_block_transaction_L7
push_block_transaction_L9:
    jmp push_block_transaction_L6
push_block_transaction_L6:
; return
    rts
    jmp push_block_transaction_L8
push_block_transaction_L7:
push_block_transaction_L8:
; if REQUEST > 4:
    lda REQUEST
    cmp #4
    beq push_block_transaction_L15
    bcs push_block_transaction_L14
push_block_transaction_L15:
    jmp push_block_transaction_L12
push_block_transaction_L14:
    jmp push_block_transaction_L11
push_block_transaction_L11:
; return
    rts
    jmp push_block_transaction_L13
push_block_transaction_L12:
push_block_transaction_L13:
; T0 = C[CELL]
    ldx CELL
    lda C0,x
    sta T0
; if T0 != 0:
    lda T0
    cmp #0
    bne push_block_transaction_L19
push_block_transaction_L20:
    jmp push_block_transaction_L17
push_block_transaction_L19:
    jmp push_block_transaction_L16
push_block_transaction_L16:
; return
    rts
    jmp push_block_transaction_L18
push_block_transaction_L17:
push_block_transaction_L18:
; VALID = 1
    lda #1
    sta VALID
; T0 = CELL
    lda CELL
    sta T0
; T4 = 0
    lda #0
    sta T4
; while T4 < 2:
push_block_transaction_L21:
    lda T4
    cmp #2
    bcc push_block_transaction_L24
push_block_transaction_L25:
    jmp push_block_transaction_L23
push_block_transaction_L24:
    jmp push_block_transaction_L22
push_block_transaction_L22:
; T1 = 255
    lda #255
    sta T1
; T2 = T0 & 3
    lda T0
    and #3
    sta T2
; if REQUEST == 1:
    lda REQUEST
    cmp #1
    beq push_block_transaction_L29
push_block_transaction_L30:
    jmp push_block_transaction_L27
push_block_transaction_L29:
    jmp push_block_transaction_L26
push_block_transaction_L26:
; if T2 != 0:
    lda T2
    cmp #0
    bne push_block_transaction_L34
push_block_transaction_L35:
    jmp push_block_transaction_L32
push_block_transaction_L34:
    jmp push_block_transaction_L31
push_block_transaction_L31:
; T1 = T0 - 1
    lda T0
    sec
    sbc #1
    sta T1
    jmp push_block_transaction_L33
push_block_transaction_L32:
push_block_transaction_L33:
    jmp push_block_transaction_L28
push_block_transaction_L27:
push_block_transaction_L28:
; if REQUEST == 2:
    lda REQUEST
    cmp #2
    beq push_block_transaction_L39
push_block_transaction_L40:
    jmp push_block_transaction_L37
push_block_transaction_L39:
    jmp push_block_transaction_L36
push_block_transaction_L36:
; if T2 != 3:
    lda T2
    cmp #3
    bne push_block_transaction_L44
push_block_transaction_L45:
    jmp push_block_transaction_L42
push_block_transaction_L44:
    jmp push_block_transaction_L41
push_block_transaction_L41:
; T1 = T0 + 1
    lda T0
    clc
    adc #1
    sta T1
    jmp push_block_transaction_L43
push_block_transaction_L42:
push_block_transaction_L43:
    jmp push_block_transaction_L38
push_block_transaction_L37:
push_block_transaction_L38:
; if REQUEST == 3:
    lda REQUEST
    cmp #3
    beq push_block_transaction_L49
push_block_transaction_L50:
    jmp push_block_transaction_L47
push_block_transaction_L49:
    jmp push_block_transaction_L46
push_block_transaction_L46:
; if T0 >= 4:
    lda T0
    cmp #4
    bcs push_block_transaction_L54
push_block_transaction_L55:
    jmp push_block_transaction_L52
push_block_transaction_L54:
    jmp push_block_transaction_L51
push_block_transaction_L51:
; T1 = T0 - 4
    lda T0
    sec
    sbc #4
    sta T1
    jmp push_block_transaction_L53
push_block_transaction_L52:
push_block_transaction_L53:
    jmp push_block_transaction_L48
push_block_transaction_L47:
push_block_transaction_L48:
; if REQUEST == 4:
    lda REQUEST
    cmp #4
    beq push_block_transaction_L59
push_block_transaction_L60:
    jmp push_block_transaction_L57
push_block_transaction_L59:
    jmp push_block_transaction_L56
push_block_transaction_L56:
; if T0 < 12:
    lda T0
    cmp #12
    bcc push_block_transaction_L64
push_block_transaction_L65:
    jmp push_block_transaction_L62
push_block_transaction_L64:
    jmp push_block_transaction_L61
push_block_transaction_L61:
; T1 = T0 + 4
    lda T0
    clc
    adc #4
    sta T1
    jmp push_block_transaction_L63
push_block_transaction_L62:
push_block_transaction_L63:
    jmp push_block_transaction_L58
push_block_transaction_L57:
push_block_transaction_L58:
; if T1 >= 16:
    lda T1
    cmp #16
    bcs push_block_transaction_L69
push_block_transaction_L70:
    jmp push_block_transaction_L67
push_block_transaction_L69:
    jmp push_block_transaction_L66
push_block_transaction_L66:
; return
    rts
    jmp push_block_transaction_L68
push_block_transaction_L67:
push_block_transaction_L68:
; T3 = C[T1]
    ldx T1
    lda C0,x
    sta T3
; if T4 == 0:
    lda T4
    cmp #0
    beq push_block_transaction_L74
push_block_transaction_L75:
    jmp push_block_transaction_L72
push_block_transaction_L74:
    jmp push_block_transaction_L71
push_block_transaction_L71:
; if T3 == 0:
    lda T3
    cmp #0
    beq push_block_transaction_L79
push_block_transaction_L80:
    jmp push_block_transaction_L77
push_block_transaction_L79:
    jmp push_block_transaction_L76
push_block_transaction_L76:
; CELL = T1
    lda T1
    sta CELL
; RESULT = 1
    lda #1
    sta RESULT
; return
    rts
    jmp push_block_transaction_L78
push_block_transaction_L77:
push_block_transaction_L78:
; if T3 != 2:
    lda T3
    cmp #2
    bne push_block_transaction_L84
push_block_transaction_L85:
    jmp push_block_transaction_L82
push_block_transaction_L84:
    jmp push_block_transaction_L81
push_block_transaction_L81:
; return
    rts
    jmp push_block_transaction_L83
push_block_transaction_L82:
push_block_transaction_L83:
; T5 = T1
    lda T1
    sta T5
    jmp push_block_transaction_L73
push_block_transaction_L72:
; if T3 != 0:
    lda T3
    cmp #0
    bne push_block_transaction_L89
push_block_transaction_L90:
    jmp push_block_transaction_L87
push_block_transaction_L89:
    jmp push_block_transaction_L86
push_block_transaction_L86:
; return
    rts
    jmp push_block_transaction_L88
push_block_transaction_L87:
push_block_transaction_L88:
; C[T1] = 2
    lda #2
    sta EXPR_SAVE
    ldx T1
    lda EXPR_SAVE
    sta C0,x
; C[T5] = 0
    lda #0
    sta EXPR_SAVE
    ldx T5
    lda EXPR_SAVE
    sta C0,x
; CELL = T5
    lda T5
    sta CELL
; RESULT = 2
    lda #2
    sta RESULT
; return
    rts
push_block_transaction_L73:
; T0 = T1
    lda T1
    sta T0
; T4 = T4 + 1
    lda T4
    clc
    adc #1
    sta T4
    jmp push_block_transaction_L21
push_block_transaction_L23:
    rts
component_end:
