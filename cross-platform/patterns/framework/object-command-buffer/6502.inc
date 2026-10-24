; SPDX-License-Identifier: MIT
; Defer Object Changes Until After Traversal. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
object_command_buffer_init:
    lda #0
    sta APPLIED
    sta REJECTED
    sta FULL
    sta VALID
    sta MODE
    sta SLOT
    sta GENERATION
    sta ACTIVE
    sta COUNT
    sta G0
    sta G1
    sta G2
    sta G3
    sta O0
    sta O1
    sta O2
    sta O3
    sta S0
    sta S1
    sta S2
    sta S3
    sta H0
    sta H1
    sta H2
    sta H3
    sta T0
    sta T1
    sta T2
    sta T3
    sta T4
    sta T5
    sta T6
    sta EXPR_SAVE
    rts
object_command_buffer_step:
; APPLIED = 0
    lda #0
    sta APPLIED
; REJECTED = 0
    lda #0
    sta REJECTED
; FULL = 0
    lda #0
    sta FULL
; VALID = 0
    lda #0
    sta VALID
; if ACTIVE >= 16:
    lda ACTIVE
    cmp #16
    bcs object_command_buffer_L4
object_command_buffer_L5:
    jmp object_command_buffer_L2
object_command_buffer_L4:
    jmp object_command_buffer_L1
object_command_buffer_L1:
; return
    rts
    jmp object_command_buffer_L3
object_command_buffer_L2:
object_command_buffer_L3:
; if COUNT > 4:
    lda COUNT
    cmp #4
    beq object_command_buffer_L10
    bcs object_command_buffer_L9
object_command_buffer_L10:
    jmp object_command_buffer_L7
object_command_buffer_L9:
    jmp object_command_buffer_L6
object_command_buffer_L6:
; return
    rts
    jmp object_command_buffer_L8
object_command_buffer_L7:
object_command_buffer_L8:
; if MODE > 3:
    lda MODE
    cmp #3
    beq object_command_buffer_L15
    bcs object_command_buffer_L14
object_command_buffer_L15:
    jmp object_command_buffer_L12
object_command_buffer_L14:
    jmp object_command_buffer_L11
object_command_buffer_L11:
; return
    rts
    jmp object_command_buffer_L13
object_command_buffer_L12:
object_command_buffer_L13:
; if MODE == 0:
    lda MODE
    cmp #0
    beq object_command_buffer_L19
object_command_buffer_L20:
    jmp object_command_buffer_L17
object_command_buffer_L19:
    jmp object_command_buffer_L16
object_command_buffer_L16:
; COUNT = 0
    lda #0
    sta COUNT
; VALID = 1
    lda #1
    sta VALID
; return
    rts
    jmp object_command_buffer_L18
object_command_buffer_L17:
object_command_buffer_L18:
; if MODE < 3:
    lda MODE
    cmp #3
    bcc object_command_buffer_L24
object_command_buffer_L25:
    jmp object_command_buffer_L22
object_command_buffer_L24:
    jmp object_command_buffer_L21
object_command_buffer_L21:
; if SLOT >= 4:
    lda SLOT
    cmp #4
    bcs object_command_buffer_L29
object_command_buffer_L30:
    jmp object_command_buffer_L27
object_command_buffer_L29:
    jmp object_command_buffer_L26
object_command_buffer_L26:
; return
    rts
    jmp object_command_buffer_L28
object_command_buffer_L27:
object_command_buffer_L28:
; VALID = 1
    lda #1
    sta VALID
; if COUNT == 4:
    lda COUNT
    cmp #4
    beq object_command_buffer_L34
object_command_buffer_L35:
    jmp object_command_buffer_L32
object_command_buffer_L34:
    jmp object_command_buffer_L31
object_command_buffer_L31:
; FULL = 1
    lda #1
    sta FULL
; return
    rts
    jmp object_command_buffer_L33
object_command_buffer_L32:
object_command_buffer_L33:
; O[COUNT] = MODE
    lda MODE
    sta EXPR_SAVE
    ldx COUNT
    lda EXPR_SAVE
    sta O0,x
; S[COUNT] = SLOT
    lda SLOT
    sta EXPR_SAVE
    ldx COUNT
    lda EXPR_SAVE
    sta S0,x
; H[COUNT] = GENERATION
    lda GENERATION
    sta EXPR_SAVE
    ldx COUNT
    lda EXPR_SAVE
    sta H0,x
; COUNT = COUNT + 1
    lda COUNT
    clc
    adc #1
    sta COUNT
; return
    rts
    jmp object_command_buffer_L23
object_command_buffer_L22:
object_command_buffer_L23:
; T0 = 0
    lda #0
    sta T0
; while T0 < COUNT:
object_command_buffer_L36:
    lda T0
    cmp COUNT
    bcc object_command_buffer_L39
object_command_buffer_L40:
    jmp object_command_buffer_L38
object_command_buffer_L39:
    jmp object_command_buffer_L37
object_command_buffer_L37:
; T1 = O[T0]
    ldx T0
    lda O0,x
    sta T1
; if T1 == 0:
    lda T1
    cmp #0
    beq object_command_buffer_L44
object_command_buffer_L45:
    jmp object_command_buffer_L42
object_command_buffer_L44:
    jmp object_command_buffer_L41
object_command_buffer_L41:
; return
    rts
    jmp object_command_buffer_L43
object_command_buffer_L42:
object_command_buffer_L43:
; if T1 > 2:
    lda T1
    cmp #2
    beq object_command_buffer_L50
    bcs object_command_buffer_L49
object_command_buffer_L50:
    jmp object_command_buffer_L47
object_command_buffer_L49:
    jmp object_command_buffer_L46
object_command_buffer_L46:
; return
    rts
    jmp object_command_buffer_L48
object_command_buffer_L47:
object_command_buffer_L48:
; T1 = S[T0]
    ldx T0
    lda S0,x
    sta T1
; if T1 >= 4:
    lda T1
    cmp #4
    bcs object_command_buffer_L54
object_command_buffer_L55:
    jmp object_command_buffer_L52
object_command_buffer_L54:
    jmp object_command_buffer_L51
object_command_buffer_L51:
; return
    rts
    jmp object_command_buffer_L53
object_command_buffer_L52:
object_command_buffer_L53:
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp object_command_buffer_L36
object_command_buffer_L38:
; VALID = 1
    lda #1
    sta VALID
; T0 = 0
    lda #0
    sta T0
; while T0 < COUNT:
object_command_buffer_L56:
    lda T0
    cmp COUNT
    bcc object_command_buffer_L59
object_command_buffer_L60:
    jmp object_command_buffer_L58
object_command_buffer_L59:
    jmp object_command_buffer_L57
object_command_buffer_L57:
; T1 = S[T0]
    ldx T0
    lda S0,x
    sta T1
; T2 = 1
    lda #1
    sta T2
; T3 = T1
    lda T1
    sta T3
; while T3 != 0:
object_command_buffer_L61:
    lda T3
    cmp #0
    bne object_command_buffer_L64
object_command_buffer_L65:
    jmp object_command_buffer_L63
object_command_buffer_L64:
    jmp object_command_buffer_L62
object_command_buffer_L62:
; T2 = T2 << 1
    lda T2
    asl
    sta T2
; T3 = T3 - 1
    lda T3
    sec
    sbc #1
    sta T3
    jmp object_command_buffer_L61
object_command_buffer_L63:
; T3 = ACTIVE & T2
    lda ACTIVE
    and T2
    sta T3
; T4 = O[T0]
    ldx T0
    lda O0,x
    sta T4
; T5 = 0
    lda #0
    sta T5
; if T4 == 1:
    lda T4
    cmp #1
    beq object_command_buffer_L69
object_command_buffer_L70:
    jmp object_command_buffer_L67
object_command_buffer_L69:
    jmp object_command_buffer_L66
object_command_buffer_L66:
; if T3 == 0:
    lda T3
    cmp #0
    beq object_command_buffer_L74
object_command_buffer_L75:
    jmp object_command_buffer_L72
object_command_buffer_L74:
    jmp object_command_buffer_L71
object_command_buffer_L71:
; ACTIVE = ACTIVE | T2
    lda ACTIVE
    ora T2
    sta ACTIVE
; T4 = G[T1]
    ldx T1
    lda G0,x
    sta T4
; T4 = T4 + 1
    lda T4
    clc
    adc #1
    sta T4
; G[T1] = T4
    lda T4
    sta EXPR_SAVE
    ldx T1
    lda EXPR_SAVE
    sta G0,x
; T5 = 1
    lda #1
    sta T5
    jmp object_command_buffer_L73
object_command_buffer_L72:
object_command_buffer_L73:
    jmp object_command_buffer_L68
object_command_buffer_L67:
; if T3 != 0:
    lda T3
    cmp #0
    bne object_command_buffer_L79
object_command_buffer_L80:
    jmp object_command_buffer_L77
object_command_buffer_L79:
    jmp object_command_buffer_L76
object_command_buffer_L76:
; T4 = G[T1]
    ldx T1
    lda G0,x
    sta T4
; T6 = H[T0]
    ldx T0
    lda H0,x
    sta T6
; if T4 == T6:
    lda T4
    cmp T6
    beq object_command_buffer_L84
object_command_buffer_L85:
    jmp object_command_buffer_L82
object_command_buffer_L84:
    jmp object_command_buffer_L81
object_command_buffer_L81:
; ACTIVE = ACTIVE ^ T2
    lda ACTIVE
    eor T2
    sta ACTIVE
; T5 = 1
    lda #1
    sta T5
    jmp object_command_buffer_L83
object_command_buffer_L82:
object_command_buffer_L83:
    jmp object_command_buffer_L78
object_command_buffer_L77:
object_command_buffer_L78:
object_command_buffer_L68:
; if T5 != 0:
    lda T5
    cmp #0
    bne object_command_buffer_L89
object_command_buffer_L90:
    jmp object_command_buffer_L87
object_command_buffer_L89:
    jmp object_command_buffer_L86
object_command_buffer_L86:
; APPLIED = APPLIED + 1
    lda APPLIED
    clc
    adc #1
    sta APPLIED
    jmp object_command_buffer_L88
object_command_buffer_L87:
; REJECTED = REJECTED + 1
    lda REJECTED
    clc
    adc #1
    sta REJECTED
object_command_buffer_L88:
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp object_command_buffer_L56
object_command_buffer_L58:
; COUNT = 0
    lda #0
    sta COUNT
    rts
component_end:
