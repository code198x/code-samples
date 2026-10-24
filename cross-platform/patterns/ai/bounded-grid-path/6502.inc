; SPDX-License-Identifier: MIT
; Find the First Step Along a Shortest Grid Path. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_grid_path_init:
    lda #0
    sta MOVE
    sta DISTANCE
    sta FOUND
    sta VALID
    sta FROM
    sta TO
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
bounded_grid_path_step:
; MOVE = 0
    lda #0
    sta MOVE
; DISTANCE = 255
    lda #255
    sta DISTANCE
; FOUND = 0
    lda #0
    sta FOUND
; VALID = 0
    lda #0
    sta VALID
; if FROM >= 16:
    lda FROM
    cmp #16
    bcs bounded_grid_path_L4
bounded_grid_path_L5:
    jmp bounded_grid_path_L2
bounded_grid_path_L4:
    jmp bounded_grid_path_L1
bounded_grid_path_L1:
; return
    rts
    jmp bounded_grid_path_L3
bounded_grid_path_L2:
bounded_grid_path_L3:
; if TO >= 16:
    lda TO
    cmp #16
    bcs bounded_grid_path_L9
bounded_grid_path_L10:
    jmp bounded_grid_path_L7
bounded_grid_path_L9:
    jmp bounded_grid_path_L6
bounded_grid_path_L6:
; return
    rts
    jmp bounded_grid_path_L8
bounded_grid_path_L7:
bounded_grid_path_L8:
; VALID = 1
    lda #1
    sta VALID
; T0 = C[FROM]
    ldx FROM
    lda C0,x
    sta T0
; if T0 != 0:
    lda T0
    cmp #0
    bne bounded_grid_path_L14
bounded_grid_path_L15:
    jmp bounded_grid_path_L12
bounded_grid_path_L14:
    jmp bounded_grid_path_L11
bounded_grid_path_L11:
; return
    rts
    jmp bounded_grid_path_L13
bounded_grid_path_L12:
bounded_grid_path_L13:
; T0 = C[TO]
    ldx TO
    lda C0,x
    sta T0
; if T0 != 0:
    lda T0
    cmp #0
    bne bounded_grid_path_L19
bounded_grid_path_L20:
    jmp bounded_grid_path_L17
bounded_grid_path_L19:
    jmp bounded_grid_path_L16
bounded_grid_path_L16:
; return
    rts
    jmp bounded_grid_path_L18
bounded_grid_path_L17:
bounded_grid_path_L18:
; T0 = 0
    lda #0
    sta T0
; while T0 < 16:
bounded_grid_path_L21:
    lda T0
    cmp #16
    bcc bounded_grid_path_L24
bounded_grid_path_L25:
    jmp bounded_grid_path_L23
bounded_grid_path_L24:
    jmp bounded_grid_path_L22
bounded_grid_path_L22:
; V[T0] = 255
    lda #255
    sta EXPR_SAVE
    ldx T0
    lda EXPR_SAVE
    sta V0,x
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp bounded_grid_path_L21
bounded_grid_path_L23:
; V[TO] = 0
    lda #0
    sta EXPR_SAVE
    ldx TO
    lda EXPR_SAVE
    sta V0,x
; T0 = 1
    lda #1
    sta T0
; while T0 < 16:
bounded_grid_path_L26:
    lda T0
    cmp #16
    bcc bounded_grid_path_L29
bounded_grid_path_L30:
    jmp bounded_grid_path_L28
bounded_grid_path_L29:
    jmp bounded_grid_path_L27
bounded_grid_path_L27:
; T1 = 0
    lda #0
    sta T1
; while T1 < 16:
bounded_grid_path_L31:
    lda T1
    cmp #16
    bcc bounded_grid_path_L34
bounded_grid_path_L35:
    jmp bounded_grid_path_L33
bounded_grid_path_L34:
    jmp bounded_grid_path_L32
bounded_grid_path_L32:
; T2 = C[T1]
    ldx T1
    lda C0,x
    sta T2
; T3 = V[T1]
    ldx T1
    lda V0,x
    sta T3
; if T2 == 0:
    lda T2
    cmp #0
    beq bounded_grid_path_L39
bounded_grid_path_L40:
    jmp bounded_grid_path_L37
bounded_grid_path_L39:
    jmp bounded_grid_path_L36
bounded_grid_path_L36:
; if T3 == 255:
    lda T3
    cmp #255
    beq bounded_grid_path_L44
bounded_grid_path_L45:
    jmp bounded_grid_path_L42
bounded_grid_path_L44:
    jmp bounded_grid_path_L41
bounded_grid_path_L41:
; T4 = T0 - 1
    lda T0
    sec
    sbc #1
    sta T4
; T5 = T1 & 3
    lda T1
    and #3
    sta T5
; if T5 != 0:
    lda T5
    cmp #0
    bne bounded_grid_path_L49
bounded_grid_path_L50:
    jmp bounded_grid_path_L47
bounded_grid_path_L49:
    jmp bounded_grid_path_L46
bounded_grid_path_L46:
; T6 = T1 - 1
    lda T1
    sec
    sbc #1
    sta T6
; T7 = V[T6]
    ldx T6
    lda V0,x
    sta T7
; if T7 == T4:
    lda T7
    cmp T4
    beq bounded_grid_path_L54
bounded_grid_path_L55:
    jmp bounded_grid_path_L52
bounded_grid_path_L54:
    jmp bounded_grid_path_L51
bounded_grid_path_L51:
; V[T1] = T0
    lda T0
    sta EXPR_SAVE
    ldx T1
    lda EXPR_SAVE
    sta V0,x
    jmp bounded_grid_path_L53
bounded_grid_path_L52:
bounded_grid_path_L53:
    jmp bounded_grid_path_L48
bounded_grid_path_L47:
bounded_grid_path_L48:
; if T5 != 3:
    lda T5
    cmp #3
    bne bounded_grid_path_L59
bounded_grid_path_L60:
    jmp bounded_grid_path_L57
bounded_grid_path_L59:
    jmp bounded_grid_path_L56
bounded_grid_path_L56:
; T6 = T1 + 1
    lda T1
    clc
    adc #1
    sta T6
; T7 = V[T6]
    ldx T6
    lda V0,x
    sta T7
; if T7 == T4:
    lda T7
    cmp T4
    beq bounded_grid_path_L64
bounded_grid_path_L65:
    jmp bounded_grid_path_L62
bounded_grid_path_L64:
    jmp bounded_grid_path_L61
bounded_grid_path_L61:
; V[T1] = T0
    lda T0
    sta EXPR_SAVE
    ldx T1
    lda EXPR_SAVE
    sta V0,x
    jmp bounded_grid_path_L63
bounded_grid_path_L62:
bounded_grid_path_L63:
    jmp bounded_grid_path_L58
bounded_grid_path_L57:
bounded_grid_path_L58:
; if T1 >= 4:
    lda T1
    cmp #4
    bcs bounded_grid_path_L69
bounded_grid_path_L70:
    jmp bounded_grid_path_L67
bounded_grid_path_L69:
    jmp bounded_grid_path_L66
bounded_grid_path_L66:
; T6 = T1 - 4
    lda T1
    sec
    sbc #4
    sta T6
; T7 = V[T6]
    ldx T6
    lda V0,x
    sta T7
; if T7 == T4:
    lda T7
    cmp T4
    beq bounded_grid_path_L74
bounded_grid_path_L75:
    jmp bounded_grid_path_L72
bounded_grid_path_L74:
    jmp bounded_grid_path_L71
bounded_grid_path_L71:
; V[T1] = T0
    lda T0
    sta EXPR_SAVE
    ldx T1
    lda EXPR_SAVE
    sta V0,x
    jmp bounded_grid_path_L73
bounded_grid_path_L72:
bounded_grid_path_L73:
    jmp bounded_grid_path_L68
bounded_grid_path_L67:
bounded_grid_path_L68:
; if T1 < 12:
    lda T1
    cmp #12
    bcc bounded_grid_path_L79
bounded_grid_path_L80:
    jmp bounded_grid_path_L77
bounded_grid_path_L79:
    jmp bounded_grid_path_L76
bounded_grid_path_L76:
; T6 = T1 + 4
    lda T1
    clc
    adc #4
    sta T6
; T7 = V[T6]
    ldx T6
    lda V0,x
    sta T7
; if T7 == T4:
    lda T7
    cmp T4
    beq bounded_grid_path_L84
bounded_grid_path_L85:
    jmp bounded_grid_path_L82
bounded_grid_path_L84:
    jmp bounded_grid_path_L81
bounded_grid_path_L81:
; V[T1] = T0
    lda T0
    sta EXPR_SAVE
    ldx T1
    lda EXPR_SAVE
    sta V0,x
    jmp bounded_grid_path_L83
bounded_grid_path_L82:
bounded_grid_path_L83:
    jmp bounded_grid_path_L78
bounded_grid_path_L77:
bounded_grid_path_L78:
    jmp bounded_grid_path_L43
bounded_grid_path_L42:
bounded_grid_path_L43:
    jmp bounded_grid_path_L38
bounded_grid_path_L37:
bounded_grid_path_L38:
; T1 = T1 + 1
    lda T1
    clc
    adc #1
    sta T1
    jmp bounded_grid_path_L31
bounded_grid_path_L33:
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp bounded_grid_path_L26
bounded_grid_path_L28:
; DISTANCE = V[FROM]
    ldx FROM
    lda V0,x
    sta DISTANCE
; if DISTANCE == 255:
    lda DISTANCE
    cmp #255
    beq bounded_grid_path_L89
bounded_grid_path_L90:
    jmp bounded_grid_path_L87
bounded_grid_path_L89:
    jmp bounded_grid_path_L86
bounded_grid_path_L86:
; return
    rts
    jmp bounded_grid_path_L88
bounded_grid_path_L87:
bounded_grid_path_L88:
; FOUND = 1
    lda #1
    sta FOUND
; if DISTANCE == 0:
    lda DISTANCE
    cmp #0
    beq bounded_grid_path_L94
bounded_grid_path_L95:
    jmp bounded_grid_path_L92
bounded_grid_path_L94:
    jmp bounded_grid_path_L91
bounded_grid_path_L91:
; return
    rts
    jmp bounded_grid_path_L93
bounded_grid_path_L92:
bounded_grid_path_L93:
; T0 = DISTANCE - 1
    lda DISTANCE
    sec
    sbc #1
    sta T0
; T1 = FROM & 3
    lda FROM
    and #3
    sta T1
; if T1 != 0:
    lda T1
    cmp #0
    bne bounded_grid_path_L99
bounded_grid_path_L100:
    jmp bounded_grid_path_L97
bounded_grid_path_L99:
    jmp bounded_grid_path_L96
bounded_grid_path_L96:
; T2 = FROM - 1
    lda FROM
    sec
    sbc #1
    sta T2
; T3 = V[T2]
    ldx T2
    lda V0,x
    sta T3
; if T3 == T0:
    lda T3
    cmp T0
    beq bounded_grid_path_L104
bounded_grid_path_L105:
    jmp bounded_grid_path_L102
bounded_grid_path_L104:
    jmp bounded_grid_path_L101
bounded_grid_path_L101:
; MOVE = 1
    lda #1
    sta MOVE
; return
    rts
    jmp bounded_grid_path_L103
bounded_grid_path_L102:
bounded_grid_path_L103:
    jmp bounded_grid_path_L98
bounded_grid_path_L97:
bounded_grid_path_L98:
; if T1 != 3:
    lda T1
    cmp #3
    bne bounded_grid_path_L109
bounded_grid_path_L110:
    jmp bounded_grid_path_L107
bounded_grid_path_L109:
    jmp bounded_grid_path_L106
bounded_grid_path_L106:
; T2 = FROM + 1
    lda FROM
    clc
    adc #1
    sta T2
; T3 = V[T2]
    ldx T2
    lda V0,x
    sta T3
; if T3 == T0:
    lda T3
    cmp T0
    beq bounded_grid_path_L114
bounded_grid_path_L115:
    jmp bounded_grid_path_L112
bounded_grid_path_L114:
    jmp bounded_grid_path_L111
bounded_grid_path_L111:
; MOVE = 2
    lda #2
    sta MOVE
; return
    rts
    jmp bounded_grid_path_L113
bounded_grid_path_L112:
bounded_grid_path_L113:
    jmp bounded_grid_path_L108
bounded_grid_path_L107:
bounded_grid_path_L108:
; if FROM >= 4:
    lda FROM
    cmp #4
    bcs bounded_grid_path_L119
bounded_grid_path_L120:
    jmp bounded_grid_path_L117
bounded_grid_path_L119:
    jmp bounded_grid_path_L116
bounded_grid_path_L116:
; T2 = FROM - 4
    lda FROM
    sec
    sbc #4
    sta T2
; T3 = V[T2]
    ldx T2
    lda V0,x
    sta T3
; if T3 == T0:
    lda T3
    cmp T0
    beq bounded_grid_path_L124
bounded_grid_path_L125:
    jmp bounded_grid_path_L122
bounded_grid_path_L124:
    jmp bounded_grid_path_L121
bounded_grid_path_L121:
; MOVE = 3
    lda #3
    sta MOVE
; return
    rts
    jmp bounded_grid_path_L123
bounded_grid_path_L122:
bounded_grid_path_L123:
    jmp bounded_grid_path_L118
bounded_grid_path_L117:
bounded_grid_path_L118:
; if FROM < 12:
    lda FROM
    cmp #12
    bcc bounded_grid_path_L129
bounded_grid_path_L130:
    jmp bounded_grid_path_L127
bounded_grid_path_L129:
    jmp bounded_grid_path_L126
bounded_grid_path_L126:
; T2 = FROM + 4
    lda FROM
    clc
    adc #4
    sta T2
; T3 = V[T2]
    ldx T2
    lda V0,x
    sta T3
; if T3 == T0:
    lda T3
    cmp T0
    beq bounded_grid_path_L134
bounded_grid_path_L135:
    jmp bounded_grid_path_L132
bounded_grid_path_L134:
    jmp bounded_grid_path_L131
bounded_grid_path_L131:
; MOVE = 4
    lda #4
    sta MOVE
    jmp bounded_grid_path_L133
bounded_grid_path_L132:
bounded_grid_path_L133:
    jmp bounded_grid_path_L128
bounded_grid_path_L127:
bounded_grid_path_L128:
    rts
component_end:
