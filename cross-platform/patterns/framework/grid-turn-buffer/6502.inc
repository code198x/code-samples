; SPDX-License-Identifier: MIT
; Buffer Turns Through a Grid. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
grid_turn_buffer_init:
    lda #0
    sta CELL
    sta DIRECTION
    sta PENDING
    sta MOVED
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
    rts
grid_turn_buffer_step:
; MOVED = 0
    lda #0
    sta MOVED
; VALID = 0
    lda #0
    sta VALID
; if CELL >= 16:
    lda CELL
    cmp #16
    bcs grid_turn_buffer_L4
grid_turn_buffer_L5:
    jmp grid_turn_buffer_L2
grid_turn_buffer_L4:
    jmp grid_turn_buffer_L1
grid_turn_buffer_L1:
; return
    rts
    jmp grid_turn_buffer_L3
grid_turn_buffer_L2:
grid_turn_buffer_L3:
; if DIRECTION > 4:
    lda DIRECTION
    cmp #4
    beq grid_turn_buffer_L10
    bcs grid_turn_buffer_L9
grid_turn_buffer_L10:
    jmp grid_turn_buffer_L7
grid_turn_buffer_L9:
    jmp grid_turn_buffer_L6
grid_turn_buffer_L6:
; return
    rts
    jmp grid_turn_buffer_L8
grid_turn_buffer_L7:
grid_turn_buffer_L8:
; if PENDING > 4:
    lda PENDING
    cmp #4
    beq grid_turn_buffer_L15
    bcs grid_turn_buffer_L14
grid_turn_buffer_L15:
    jmp grid_turn_buffer_L12
grid_turn_buffer_L14:
    jmp grid_turn_buffer_L11
grid_turn_buffer_L11:
; return
    rts
    jmp grid_turn_buffer_L13
grid_turn_buffer_L12:
grid_turn_buffer_L13:
; if REQUEST > 4:
    lda REQUEST
    cmp #4
    beq grid_turn_buffer_L20
    bcs grid_turn_buffer_L19
grid_turn_buffer_L20:
    jmp grid_turn_buffer_L17
grid_turn_buffer_L19:
    jmp grid_turn_buffer_L16
grid_turn_buffer_L16:
; return
    rts
    jmp grid_turn_buffer_L18
grid_turn_buffer_L17:
grid_turn_buffer_L18:
; T0 = C[CELL]
    ldx CELL
    lda C0,x
    sta T0
; if T0 != 0:
    lda T0
    cmp #0
    bne grid_turn_buffer_L24
grid_turn_buffer_L25:
    jmp grid_turn_buffer_L22
grid_turn_buffer_L24:
    jmp grid_turn_buffer_L21
grid_turn_buffer_L21:
; return
    rts
    jmp grid_turn_buffer_L23
grid_turn_buffer_L22:
grid_turn_buffer_L23:
; VALID = 1
    lda #1
    sta VALID
; if REQUEST != 0:
    lda REQUEST
    cmp #0
    bne grid_turn_buffer_L29
grid_turn_buffer_L30:
    jmp grid_turn_buffer_L27
grid_turn_buffer_L29:
    jmp grid_turn_buffer_L26
grid_turn_buffer_L26:
; PENDING = REQUEST
    lda REQUEST
    sta PENDING
    jmp grid_turn_buffer_L28
grid_turn_buffer_L27:
grid_turn_buffer_L28:
; T4 = 2
    lda #2
    sta T4
; T0 = PENDING
    lda PENDING
    sta T0
; while T4 != 0:
grid_turn_buffer_L31:
    lda T4
    cmp #0
    bne grid_turn_buffer_L34
grid_turn_buffer_L35:
    jmp grid_turn_buffer_L33
grid_turn_buffer_L34:
    jmp grid_turn_buffer_L32
grid_turn_buffer_L32:
; T1 = 255
    lda #255
    sta T1
; T2 = CELL & 3
    lda CELL
    and #3
    sta T2
; if T0 == 1:
    lda T0
    cmp #1
    beq grid_turn_buffer_L39
grid_turn_buffer_L40:
    jmp grid_turn_buffer_L37
grid_turn_buffer_L39:
    jmp grid_turn_buffer_L36
grid_turn_buffer_L36:
; if T2 != 0:
    lda T2
    cmp #0
    bne grid_turn_buffer_L44
grid_turn_buffer_L45:
    jmp grid_turn_buffer_L42
grid_turn_buffer_L44:
    jmp grid_turn_buffer_L41
grid_turn_buffer_L41:
; T1 = CELL - 1
    lda CELL
    sec
    sbc #1
    sta T1
    jmp grid_turn_buffer_L43
grid_turn_buffer_L42:
grid_turn_buffer_L43:
    jmp grid_turn_buffer_L38
grid_turn_buffer_L37:
grid_turn_buffer_L38:
; if T0 == 2:
    lda T0
    cmp #2
    beq grid_turn_buffer_L49
grid_turn_buffer_L50:
    jmp grid_turn_buffer_L47
grid_turn_buffer_L49:
    jmp grid_turn_buffer_L46
grid_turn_buffer_L46:
; if T2 != 3:
    lda T2
    cmp #3
    bne grid_turn_buffer_L54
grid_turn_buffer_L55:
    jmp grid_turn_buffer_L52
grid_turn_buffer_L54:
    jmp grid_turn_buffer_L51
grid_turn_buffer_L51:
; T1 = CELL + 1
    lda CELL
    clc
    adc #1
    sta T1
    jmp grid_turn_buffer_L53
grid_turn_buffer_L52:
grid_turn_buffer_L53:
    jmp grid_turn_buffer_L48
grid_turn_buffer_L47:
grid_turn_buffer_L48:
; if T0 == 3:
    lda T0
    cmp #3
    beq grid_turn_buffer_L59
grid_turn_buffer_L60:
    jmp grid_turn_buffer_L57
grid_turn_buffer_L59:
    jmp grid_turn_buffer_L56
grid_turn_buffer_L56:
; if CELL >= 4:
    lda CELL
    cmp #4
    bcs grid_turn_buffer_L64
grid_turn_buffer_L65:
    jmp grid_turn_buffer_L62
grid_turn_buffer_L64:
    jmp grid_turn_buffer_L61
grid_turn_buffer_L61:
; T1 = CELL - 4
    lda CELL
    sec
    sbc #4
    sta T1
    jmp grid_turn_buffer_L63
grid_turn_buffer_L62:
grid_turn_buffer_L63:
    jmp grid_turn_buffer_L58
grid_turn_buffer_L57:
grid_turn_buffer_L58:
; if T0 == 4:
    lda T0
    cmp #4
    beq grid_turn_buffer_L69
grid_turn_buffer_L70:
    jmp grid_turn_buffer_L67
grid_turn_buffer_L69:
    jmp grid_turn_buffer_L66
grid_turn_buffer_L66:
; if CELL < 12:
    lda CELL
    cmp #12
    bcc grid_turn_buffer_L74
grid_turn_buffer_L75:
    jmp grid_turn_buffer_L72
grid_turn_buffer_L74:
    jmp grid_turn_buffer_L71
grid_turn_buffer_L71:
; T1 = CELL + 4
    lda CELL
    clc
    adc #4
    sta T1
    jmp grid_turn_buffer_L73
grid_turn_buffer_L72:
grid_turn_buffer_L73:
    jmp grid_turn_buffer_L68
grid_turn_buffer_L67:
grid_turn_buffer_L68:
; if T1 < 16:
    lda T1
    cmp #16
    bcc grid_turn_buffer_L79
grid_turn_buffer_L80:
    jmp grid_turn_buffer_L77
grid_turn_buffer_L79:
    jmp grid_turn_buffer_L76
grid_turn_buffer_L76:
; T3 = C[T1]
    ldx T1
    lda C0,x
    sta T3
; if T3 == 0:
    lda T3
    cmp #0
    beq grid_turn_buffer_L84
grid_turn_buffer_L85:
    jmp grid_turn_buffer_L82
grid_turn_buffer_L84:
    jmp grid_turn_buffer_L81
grid_turn_buffer_L81:
; CELL = T1
    lda T1
    sta CELL
; DIRECTION = T0
    lda T0
    sta DIRECTION
; if T4 == 2:
    lda T4
    cmp #2
    beq grid_turn_buffer_L89
grid_turn_buffer_L90:
    jmp grid_turn_buffer_L87
grid_turn_buffer_L89:
    jmp grid_turn_buffer_L86
grid_turn_buffer_L86:
; PENDING = 0
    lda #0
    sta PENDING
    jmp grid_turn_buffer_L88
grid_turn_buffer_L87:
grid_turn_buffer_L88:
; MOVED = 1
    lda #1
    sta MOVED
; return
    rts
    jmp grid_turn_buffer_L83
grid_turn_buffer_L82:
grid_turn_buffer_L83:
    jmp grid_turn_buffer_L78
grid_turn_buffer_L77:
grid_turn_buffer_L78:
; T4 = T4 - 1
    lda T4
    sec
    sbc #1
    sta T4
; T0 = DIRECTION
    lda DIRECTION
    sta T0
    jmp grid_turn_buffer_L31
grid_turn_buffer_L33:
    rts
component_end:
