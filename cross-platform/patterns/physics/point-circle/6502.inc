; SPDX-License-Identifier: MIT
; Test a Point Against a Circle. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
point_circle_init:
    lda #0
    sta HIT
    sta DX
    sta DY
    sta POINT_X
    sta POINT_Y
    sta CENTRE_X
    sta CENTRE_Y
    sta RADIUS
    sta T0
    sta T1
    sta T2
    sta T3
    sta T4
    sta T5
    sta T6
    sta T7
    sta T8
    sta T9
    rts
point_circle_step:
; HIT = 0
    lda #0
    sta HIT
; if POINT_X >= CENTRE_X:
    lda POINT_X
    cmp CENTRE_X
    bcs point_circle_L4
point_circle_L5:
    jmp point_circle_L2
point_circle_L4:
    jmp point_circle_L1
point_circle_L1:
; DX = POINT_X - CENTRE_X
    lda POINT_X
    sec
    sbc CENTRE_X
    sta DX
    jmp point_circle_L3
point_circle_L2:
; DX = CENTRE_X - POINT_X
    lda CENTRE_X
    sec
    sbc POINT_X
    sta DX
point_circle_L3:
; if POINT_Y >= CENTRE_Y:
    lda POINT_Y
    cmp CENTRE_Y
    bcs point_circle_L9
point_circle_L10:
    jmp point_circle_L7
point_circle_L9:
    jmp point_circle_L6
point_circle_L6:
; DY = POINT_Y - CENTRE_Y
    lda POINT_Y
    sec
    sbc CENTRE_Y
    sta DY
    jmp point_circle_L8
point_circle_L7:
; DY = CENTRE_Y - POINT_Y
    lda CENTRE_Y
    sec
    sbc POINT_Y
    sta DY
point_circle_L8:
; if DX > RADIUS:
    lda DX
    cmp RADIUS
    beq point_circle_L15
    bcs point_circle_L14
point_circle_L15:
    jmp point_circle_L12
point_circle_L14:
    jmp point_circle_L11
point_circle_L11:
; return
    rts
    jmp point_circle_L13
point_circle_L12:
point_circle_L13:
; if DY > RADIUS:
    lda DY
    cmp RADIUS
    beq point_circle_L20
    bcs point_circle_L19
point_circle_L20:
    jmp point_circle_L17
point_circle_L19:
    jmp point_circle_L16
point_circle_L16:
; return
    rts
    jmp point_circle_L18
point_circle_L17:
point_circle_L18:
; T4 = RADIUS
    lda RADIUS
    sta T4
; T5 = 0
    lda #0
    sta T5
; T1 = RADIUS
    lda RADIUS
    sta T1
; T6 = 0
    lda #0
    sta T6
; T7 = 0
    lda #0
    sta T7
; T0 = 8
    lda #8
    sta T0
; while T0 != 0:
point_circle_L21:
    lda T0
    cmp #0
    bne point_circle_L24
point_circle_L25:
    jmp point_circle_L23
point_circle_L24:
    jmp point_circle_L22
point_circle_L22:
; T9 = T1 & 1
    lda T1
    and #1
    sta T9
; if T9 != 0:
    lda T9
    cmp #0
    bne point_circle_L29
point_circle_L30:
    jmp point_circle_L27
point_circle_L29:
    jmp point_circle_L26
point_circle_L26:
; T8 = T6
    lda T6
    sta T8
; T6 = T6 + T4
    lda T6
    clc
    adc T4
    sta T6
; T9 = 0
    lda #0
    sta T9
; if T6 < T8:
    lda T6
    cmp T8
    bcc point_circle_L34
point_circle_L35:
    jmp point_circle_L32
point_circle_L34:
    jmp point_circle_L31
point_circle_L31:
; T9 = 1
    lda #1
    sta T9
    jmp point_circle_L33
point_circle_L32:
point_circle_L33:
; T7 = T7 + T5
    lda T7
    clc
    adc T5
    sta T7
; T7 = T7 + T9
    lda T7
    clc
    adc T9
    sta T7
    jmp point_circle_L28
point_circle_L27:
point_circle_L28:
; T9 = T4 >> 7
    lda T4
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    sta T9
; T4 = T4 << 1
    lda T4
    asl
    sta T4
; T5 = T5 << 1
    lda T5
    asl
    sta T5
; T5 = T5 | T9
    lda T5
    ora T9
    sta T5
; T1 = T1 >> 1
    lda T1
    lsr
    sta T1
; T0 = T0 - 1
    lda T0
    sec
    sbc #1
    sta T0
    jmp point_circle_L21
point_circle_L23:
; T2 = T6
    lda T6
    sta T2
; T3 = T7
    lda T7
    sta T3
; T4 = DX
    lda DX
    sta T4
; T5 = 0
    lda #0
    sta T5
; T1 = DX
    lda DX
    sta T1
; T6 = 0
    lda #0
    sta T6
; T7 = 0
    lda #0
    sta T7
; T0 = 8
    lda #8
    sta T0
; while T0 != 0:
point_circle_L36:
    lda T0
    cmp #0
    bne point_circle_L39
point_circle_L40:
    jmp point_circle_L38
point_circle_L39:
    jmp point_circle_L37
point_circle_L37:
; T9 = T1 & 1
    lda T1
    and #1
    sta T9
; if T9 != 0:
    lda T9
    cmp #0
    bne point_circle_L44
point_circle_L45:
    jmp point_circle_L42
point_circle_L44:
    jmp point_circle_L41
point_circle_L41:
; T8 = T6
    lda T6
    sta T8
; T6 = T6 + T4
    lda T6
    clc
    adc T4
    sta T6
; T9 = 0
    lda #0
    sta T9
; if T6 < T8:
    lda T6
    cmp T8
    bcc point_circle_L49
point_circle_L50:
    jmp point_circle_L47
point_circle_L49:
    jmp point_circle_L46
point_circle_L46:
; T9 = 1
    lda #1
    sta T9
    jmp point_circle_L48
point_circle_L47:
point_circle_L48:
; T7 = T7 + T5
    lda T7
    clc
    adc T5
    sta T7
; T7 = T7 + T9
    lda T7
    clc
    adc T9
    sta T7
    jmp point_circle_L43
point_circle_L42:
point_circle_L43:
; T9 = T4 >> 7
    lda T4
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    sta T9
; T4 = T4 << 1
    lda T4
    asl
    sta T4
; T5 = T5 << 1
    lda T5
    asl
    sta T5
; T5 = T5 | T9
    lda T5
    ora T9
    sta T5
; T1 = T1 >> 1
    lda T1
    lsr
    sta T1
; T0 = T0 - 1
    lda T0
    sec
    sbc #1
    sta T0
    jmp point_circle_L36
point_circle_L38:
; T8 = 0
    lda #0
    sta T8
; if T2 < T6:
    lda T2
    cmp T6
    bcc point_circle_L54
point_circle_L55:
    jmp point_circle_L52
point_circle_L54:
    jmp point_circle_L51
point_circle_L51:
; T8 = 1
    lda #1
    sta T8
    jmp point_circle_L53
point_circle_L52:
point_circle_L53:
; T2 = T2 - T6
    lda T2
    sec
    sbc T6
    sta T2
; T3 = T3 - T7
    lda T3
    sec
    sbc T7
    sta T3
; T3 = T3 - T8
    lda T3
    sec
    sbc T8
    sta T3
; T4 = DY
    lda DY
    sta T4
; T5 = 0
    lda #0
    sta T5
; T1 = DY
    lda DY
    sta T1
; T6 = 0
    lda #0
    sta T6
; T7 = 0
    lda #0
    sta T7
; T0 = 8
    lda #8
    sta T0
; while T0 != 0:
point_circle_L56:
    lda T0
    cmp #0
    bne point_circle_L59
point_circle_L60:
    jmp point_circle_L58
point_circle_L59:
    jmp point_circle_L57
point_circle_L57:
; T9 = T1 & 1
    lda T1
    and #1
    sta T9
; if T9 != 0:
    lda T9
    cmp #0
    bne point_circle_L64
point_circle_L65:
    jmp point_circle_L62
point_circle_L64:
    jmp point_circle_L61
point_circle_L61:
; T8 = T6
    lda T6
    sta T8
; T6 = T6 + T4
    lda T6
    clc
    adc T4
    sta T6
; T9 = 0
    lda #0
    sta T9
; if T6 < T8:
    lda T6
    cmp T8
    bcc point_circle_L69
point_circle_L70:
    jmp point_circle_L67
point_circle_L69:
    jmp point_circle_L66
point_circle_L66:
; T9 = 1
    lda #1
    sta T9
    jmp point_circle_L68
point_circle_L67:
point_circle_L68:
; T7 = T7 + T5
    lda T7
    clc
    adc T5
    sta T7
; T7 = T7 + T9
    lda T7
    clc
    adc T9
    sta T7
    jmp point_circle_L63
point_circle_L62:
point_circle_L63:
; T9 = T4 >> 7
    lda T4
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    sta T9
; T4 = T4 << 1
    lda T4
    asl
    sta T4
; T5 = T5 << 1
    lda T5
    asl
    sta T5
; T5 = T5 | T9
    lda T5
    ora T9
    sta T5
; T1 = T1 >> 1
    lda T1
    lsr
    sta T1
; T0 = T0 - 1
    lda T0
    sec
    sbc #1
    sta T0
    jmp point_circle_L56
point_circle_L58:
; if T7 > T3:
    lda T7
    cmp T3
    beq point_circle_L75
    bcs point_circle_L74
point_circle_L75:
    jmp point_circle_L72
point_circle_L74:
    jmp point_circle_L71
point_circle_L71:
; return
    rts
    jmp point_circle_L73
point_circle_L72:
point_circle_L73:
; if T7 == T3:
    lda T7
    cmp T3
    beq point_circle_L79
point_circle_L80:
    jmp point_circle_L77
point_circle_L79:
    jmp point_circle_L76
point_circle_L76:
; if T6 > T2:
    lda T6
    cmp T2
    beq point_circle_L85
    bcs point_circle_L84
point_circle_L85:
    jmp point_circle_L82
point_circle_L84:
    jmp point_circle_L81
point_circle_L81:
; return
    rts
    jmp point_circle_L83
point_circle_L82:
point_circle_L83:
    jmp point_circle_L78
point_circle_L77:
point_circle_L78:
; HIT = 1
    lda #1
    sta HIT
    rts
component_end:
