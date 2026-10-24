; SPDX-License-Identifier: MIT
; Push an Actor with a Moving Solid. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
moving_solid_push_init:
    lda #0
    sta POSITION
    sta PUSHED
    sta BLOCKED
    sta VALID
    sta ACTOR_POSITION
    sta ACTOR_SIZE
    sta SOLID_OLD
    sta SOLID_NEW
    sta SOLID_SIZE
    sta MINIMUM
    sta MAXIMUM
    sta T0
    sta T1
    sta T2
    sta T3
    rts
moving_solid_push_step:
; POSITION = ACTOR_POSITION
    lda ACTOR_POSITION
    sta POSITION
; PUSHED = 0
    lda #0
    sta PUSHED
; BLOCKED = 0
    lda #0
    sta BLOCKED
; VALID = 0
    lda #0
    sta VALID
; if ACTOR_SIZE == 0:
    lda ACTOR_SIZE
    cmp #0
    beq moving_solid_push_L4
moving_solid_push_L5:
    jmp moving_solid_push_L2
moving_solid_push_L4:
    jmp moving_solid_push_L1
moving_solid_push_L1:
; return
    rts
    jmp moving_solid_push_L3
moving_solid_push_L2:
moving_solid_push_L3:
; if SOLID_SIZE == 0:
    lda SOLID_SIZE
    cmp #0
    beq moving_solid_push_L9
moving_solid_push_L10:
    jmp moving_solid_push_L7
moving_solid_push_L9:
    jmp moving_solid_push_L6
moving_solid_push_L6:
; return
    rts
    jmp moving_solid_push_L8
moving_solid_push_L7:
moving_solid_push_L8:
; if MINIMUM > MAXIMUM:
    lda MINIMUM
    cmp MAXIMUM
    beq moving_solid_push_L15
    bcs moving_solid_push_L14
moving_solid_push_L15:
    jmp moving_solid_push_L12
moving_solid_push_L14:
    jmp moving_solid_push_L11
moving_solid_push_L11:
; return
    rts
    jmp moving_solid_push_L13
moving_solid_push_L12:
moving_solid_push_L13:
; if ACTOR_POSITION < MINIMUM:
    lda ACTOR_POSITION
    cmp MINIMUM
    bcc moving_solid_push_L19
moving_solid_push_L20:
    jmp moving_solid_push_L17
moving_solid_push_L19:
    jmp moving_solid_push_L16
moving_solid_push_L16:
; return
    rts
    jmp moving_solid_push_L18
moving_solid_push_L17:
moving_solid_push_L18:
; if ACTOR_POSITION > MAXIMUM:
    lda ACTOR_POSITION
    cmp MAXIMUM
    beq moving_solid_push_L25
    bcs moving_solid_push_L24
moving_solid_push_L25:
    jmp moving_solid_push_L22
moving_solid_push_L24:
    jmp moving_solid_push_L21
moving_solid_push_L21:
; return
    rts
    jmp moving_solid_push_L23
moving_solid_push_L22:
moving_solid_push_L23:
; T0 = ACTOR_POSITION + ACTOR_SIZE
    lda ACTOR_POSITION
    clc
    adc ACTOR_SIZE
    sta T0
; if T0 < ACTOR_POSITION:
    lda T0
    cmp ACTOR_POSITION
    bcc moving_solid_push_L29
moving_solid_push_L30:
    jmp moving_solid_push_L27
moving_solid_push_L29:
    jmp moving_solid_push_L26
moving_solid_push_L26:
; return
    rts
    jmp moving_solid_push_L28
moving_solid_push_L27:
moving_solid_push_L28:
; T1 = SOLID_OLD + SOLID_SIZE
    lda SOLID_OLD
    clc
    adc SOLID_SIZE
    sta T1
; if T1 < SOLID_OLD:
    lda T1
    cmp SOLID_OLD
    bcc moving_solid_push_L34
moving_solid_push_L35:
    jmp moving_solid_push_L32
moving_solid_push_L34:
    jmp moving_solid_push_L31
moving_solid_push_L31:
; return
    rts
    jmp moving_solid_push_L33
moving_solid_push_L32:
moving_solid_push_L33:
; T2 = SOLID_NEW + SOLID_SIZE
    lda SOLID_NEW
    clc
    adc SOLID_SIZE
    sta T2
; if T2 < SOLID_NEW:
    lda T2
    cmp SOLID_NEW
    bcc moving_solid_push_L39
moving_solid_push_L40:
    jmp moving_solid_push_L37
moving_solid_push_L39:
    jmp moving_solid_push_L36
moving_solid_push_L36:
; return
    rts
    jmp moving_solid_push_L38
moving_solid_push_L37:
moving_solid_push_L38:
; if SOLID_OLD < T0:
    lda SOLID_OLD
    cmp T0
    bcc moving_solid_push_L44
moving_solid_push_L45:
    jmp moving_solid_push_L42
moving_solid_push_L44:
    jmp moving_solid_push_L41
moving_solid_push_L41:
; if T1 > ACTOR_POSITION:
    lda T1
    cmp ACTOR_POSITION
    beq moving_solid_push_L50
    bcs moving_solid_push_L49
moving_solid_push_L50:
    jmp moving_solid_push_L47
moving_solid_push_L49:
    jmp moving_solid_push_L46
moving_solid_push_L46:
; return
    rts
    jmp moving_solid_push_L48
moving_solid_push_L47:
moving_solid_push_L48:
    jmp moving_solid_push_L43
moving_solid_push_L42:
moving_solid_push_L43:
; VALID = 1
    lda #1
    sta VALID
; if SOLID_NEW > SOLID_OLD:
    lda SOLID_NEW
    cmp SOLID_OLD
    beq moving_solid_push_L55
    bcs moving_solid_push_L54
moving_solid_push_L55:
    jmp moving_solid_push_L52
moving_solid_push_L54:
    jmp moving_solid_push_L51
moving_solid_push_L51:
; if T1 <= ACTOR_POSITION:
    lda T1
    cmp ACTOR_POSITION
    bcc moving_solid_push_L59
    beq moving_solid_push_L59
moving_solid_push_L60:
    jmp moving_solid_push_L57
moving_solid_push_L59:
    jmp moving_solid_push_L56
moving_solid_push_L56:
; if T2 > ACTOR_POSITION:
    lda T2
    cmp ACTOR_POSITION
    beq moving_solid_push_L65
    bcs moving_solid_push_L64
moving_solid_push_L65:
    jmp moving_solid_push_L62
moving_solid_push_L64:
    jmp moving_solid_push_L61
moving_solid_push_L61:
; if T2 > MAXIMUM:
    lda T2
    cmp MAXIMUM
    beq moving_solid_push_L70
    bcs moving_solid_push_L69
moving_solid_push_L70:
    jmp moving_solid_push_L67
moving_solid_push_L69:
    jmp moving_solid_push_L66
moving_solid_push_L66:
; BLOCKED = 1
    lda #1
    sta BLOCKED
; return
    rts
    jmp moving_solid_push_L68
moving_solid_push_L67:
moving_solid_push_L68:
; T3 = T2 + ACTOR_SIZE
    lda T2
    clc
    adc ACTOR_SIZE
    sta T3
; if T3 < T2:
    lda T3
    cmp T2
    bcc moving_solid_push_L74
moving_solid_push_L75:
    jmp moving_solid_push_L72
moving_solid_push_L74:
    jmp moving_solid_push_L71
moving_solid_push_L71:
; BLOCKED = 1
    lda #1
    sta BLOCKED
; return
    rts
    jmp moving_solid_push_L73
moving_solid_push_L72:
moving_solid_push_L73:
; POSITION = T2
    lda T2
    sta POSITION
; PUSHED = 1
    lda #1
    sta PUSHED
    jmp moving_solid_push_L63
moving_solid_push_L62:
moving_solid_push_L63:
    jmp moving_solid_push_L58
moving_solid_push_L57:
moving_solid_push_L58:
    jmp moving_solid_push_L53
moving_solid_push_L52:
moving_solid_push_L53:
; if SOLID_NEW < SOLID_OLD:
    lda SOLID_NEW
    cmp SOLID_OLD
    bcc moving_solid_push_L79
moving_solid_push_L80:
    jmp moving_solid_push_L77
moving_solid_push_L79:
    jmp moving_solid_push_L76
moving_solid_push_L76:
; if SOLID_OLD >= T0:
    lda SOLID_OLD
    cmp T0
    bcs moving_solid_push_L84
moving_solid_push_L85:
    jmp moving_solid_push_L82
moving_solid_push_L84:
    jmp moving_solid_push_L81
moving_solid_push_L81:
; if SOLID_NEW < T0:
    lda SOLID_NEW
    cmp T0
    bcc moving_solid_push_L89
moving_solid_push_L90:
    jmp moving_solid_push_L87
moving_solid_push_L89:
    jmp moving_solid_push_L86
moving_solid_push_L86:
; if SOLID_NEW < ACTOR_SIZE:
    lda SOLID_NEW
    cmp ACTOR_SIZE
    bcc moving_solid_push_L94
moving_solid_push_L95:
    jmp moving_solid_push_L92
moving_solid_push_L94:
    jmp moving_solid_push_L91
moving_solid_push_L91:
; BLOCKED = 1
    lda #1
    sta BLOCKED
; return
    rts
    jmp moving_solid_push_L93
moving_solid_push_L92:
moving_solid_push_L93:
; T3 = SOLID_NEW - ACTOR_SIZE
    lda SOLID_NEW
    sec
    sbc ACTOR_SIZE
    sta T3
; if T3 < MINIMUM:
    lda T3
    cmp MINIMUM
    bcc moving_solid_push_L99
moving_solid_push_L100:
    jmp moving_solid_push_L97
moving_solid_push_L99:
    jmp moving_solid_push_L96
moving_solid_push_L96:
; BLOCKED = 1
    lda #1
    sta BLOCKED
; return
    rts
    jmp moving_solid_push_L98
moving_solid_push_L97:
moving_solid_push_L98:
; POSITION = T3
    lda T3
    sta POSITION
; PUSHED = 1
    lda #1
    sta PUSHED
    jmp moving_solid_push_L88
moving_solid_push_L87:
moving_solid_push_L88:
    jmp moving_solid_push_L83
moving_solid_push_L82:
moving_solid_push_L83:
    jmp moving_solid_push_L78
moving_solid_push_L77:
moving_solid_push_L78:
    rts
component_end:
