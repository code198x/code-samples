; SPDX-License-Identifier: MIT
; Service a Logical Attack–Decay–Sustain–Release Envelope. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
logical_envelope_init:
    lda #0
    sta LEVEL
    sta PHASE
    sta PREVIOUS
    sta VALID
    sta GATE
    sta ATTACK
    sta DECAY
    sta SUSTAIN
    sta RELEASE
    sta T0
    rts
logical_envelope_step:
; VALID = 0
    lda #0
    sta VALID
; if LEVEL > 15:
    lda LEVEL
    cmp #15
    beq logical_envelope_L5
    bcs logical_envelope_L4
logical_envelope_L5:
    jmp logical_envelope_L2
logical_envelope_L4:
    jmp logical_envelope_L1
logical_envelope_L1:
; return
    rts
    jmp logical_envelope_L3
logical_envelope_L2:
logical_envelope_L3:
; if PHASE > 4:
    lda PHASE
    cmp #4
    beq logical_envelope_L10
    bcs logical_envelope_L9
logical_envelope_L10:
    jmp logical_envelope_L7
logical_envelope_L9:
    jmp logical_envelope_L6
logical_envelope_L6:
; return
    rts
    jmp logical_envelope_L8
logical_envelope_L7:
logical_envelope_L8:
; if ATTACK == 0:
    lda ATTACK
    cmp #0
    beq logical_envelope_L14
logical_envelope_L15:
    jmp logical_envelope_L12
logical_envelope_L14:
    jmp logical_envelope_L11
logical_envelope_L11:
; return
    rts
    jmp logical_envelope_L13
logical_envelope_L12:
logical_envelope_L13:
; if ATTACK > 15:
    lda ATTACK
    cmp #15
    beq logical_envelope_L20
    bcs logical_envelope_L19
logical_envelope_L20:
    jmp logical_envelope_L17
logical_envelope_L19:
    jmp logical_envelope_L16
logical_envelope_L16:
; return
    rts
    jmp logical_envelope_L18
logical_envelope_L17:
logical_envelope_L18:
; if DECAY == 0:
    lda DECAY
    cmp #0
    beq logical_envelope_L24
logical_envelope_L25:
    jmp logical_envelope_L22
logical_envelope_L24:
    jmp logical_envelope_L21
logical_envelope_L21:
; return
    rts
    jmp logical_envelope_L23
logical_envelope_L22:
logical_envelope_L23:
; if DECAY > 15:
    lda DECAY
    cmp #15
    beq logical_envelope_L30
    bcs logical_envelope_L29
logical_envelope_L30:
    jmp logical_envelope_L27
logical_envelope_L29:
    jmp logical_envelope_L26
logical_envelope_L26:
; return
    rts
    jmp logical_envelope_L28
logical_envelope_L27:
logical_envelope_L28:
; if RELEASE == 0:
    lda RELEASE
    cmp #0
    beq logical_envelope_L34
logical_envelope_L35:
    jmp logical_envelope_L32
logical_envelope_L34:
    jmp logical_envelope_L31
logical_envelope_L31:
; return
    rts
    jmp logical_envelope_L33
logical_envelope_L32:
logical_envelope_L33:
; if RELEASE > 15:
    lda RELEASE
    cmp #15
    beq logical_envelope_L40
    bcs logical_envelope_L39
logical_envelope_L40:
    jmp logical_envelope_L37
logical_envelope_L39:
    jmp logical_envelope_L36
logical_envelope_L36:
; return
    rts
    jmp logical_envelope_L38
logical_envelope_L37:
logical_envelope_L38:
; if SUSTAIN > 15:
    lda SUSTAIN
    cmp #15
    beq logical_envelope_L45
    bcs logical_envelope_L44
logical_envelope_L45:
    jmp logical_envelope_L42
logical_envelope_L44:
    jmp logical_envelope_L41
logical_envelope_L41:
; return
    rts
    jmp logical_envelope_L43
logical_envelope_L42:
logical_envelope_L43:
; VALID = 1
    lda #1
    sta VALID
; if GATE != 0:
    lda GATE
    cmp #0
    bne logical_envelope_L49
logical_envelope_L50:
    jmp logical_envelope_L47
logical_envelope_L49:
    jmp logical_envelope_L46
logical_envelope_L46:
; if PREVIOUS == 0:
    lda PREVIOUS
    cmp #0
    beq logical_envelope_L54
logical_envelope_L55:
    jmp logical_envelope_L52
logical_envelope_L54:
    jmp logical_envelope_L51
logical_envelope_L51:
; LEVEL = 0
    lda #0
    sta LEVEL
; PHASE = 1
    lda #1
    sta PHASE
    jmp logical_envelope_L53
logical_envelope_L52:
logical_envelope_L53:
; PREVIOUS = 1
    lda #1
    sta PREVIOUS
    jmp logical_envelope_L48
logical_envelope_L47:
; PREVIOUS = 0
    lda #0
    sta PREVIOUS
; if PHASE != 0:
    lda PHASE
    cmp #0
    bne logical_envelope_L59
logical_envelope_L60:
    jmp logical_envelope_L57
logical_envelope_L59:
    jmp logical_envelope_L56
logical_envelope_L56:
; PHASE = 4
    lda #4
    sta PHASE
    jmp logical_envelope_L58
logical_envelope_L57:
logical_envelope_L58:
logical_envelope_L48:
; if PHASE == 0:
    lda PHASE
    cmp #0
    beq logical_envelope_L64
logical_envelope_L65:
    jmp logical_envelope_L62
logical_envelope_L64:
    jmp logical_envelope_L61
logical_envelope_L61:
; LEVEL = 0
    lda #0
    sta LEVEL
; return
    rts
    jmp logical_envelope_L63
logical_envelope_L62:
logical_envelope_L63:
; if PHASE == 1:
    lda PHASE
    cmp #1
    beq logical_envelope_L69
logical_envelope_L70:
    jmp logical_envelope_L67
logical_envelope_L69:
    jmp logical_envelope_L66
logical_envelope_L66:
; T0 = 15 - LEVEL
    lda #15
    sec
    sbc LEVEL
    sta T0
; if ATTACK >= T0:
    lda ATTACK
    cmp T0
    bcs logical_envelope_L74
logical_envelope_L75:
    jmp logical_envelope_L72
logical_envelope_L74:
    jmp logical_envelope_L71
logical_envelope_L71:
; LEVEL = 15
    lda #15
    sta LEVEL
; PHASE = 2
    lda #2
    sta PHASE
    jmp logical_envelope_L73
logical_envelope_L72:
; LEVEL = LEVEL + ATTACK
    lda LEVEL
    clc
    adc ATTACK
    sta LEVEL
logical_envelope_L73:
; return
    rts
    jmp logical_envelope_L68
logical_envelope_L67:
logical_envelope_L68:
; if PHASE == 2:
    lda PHASE
    cmp #2
    beq logical_envelope_L79
logical_envelope_L80:
    jmp logical_envelope_L77
logical_envelope_L79:
    jmp logical_envelope_L76
logical_envelope_L76:
; if LEVEL <= SUSTAIN:
    lda LEVEL
    cmp SUSTAIN
    bcc logical_envelope_L84
    beq logical_envelope_L84
logical_envelope_L85:
    jmp logical_envelope_L82
logical_envelope_L84:
    jmp logical_envelope_L81
logical_envelope_L81:
; LEVEL = SUSTAIN
    lda SUSTAIN
    sta LEVEL
; PHASE = 3
    lda #3
    sta PHASE
; return
    rts
    jmp logical_envelope_L83
logical_envelope_L82:
logical_envelope_L83:
; T0 = LEVEL - SUSTAIN
    lda LEVEL
    sec
    sbc SUSTAIN
    sta T0
; if DECAY >= T0:
    lda DECAY
    cmp T0
    bcs logical_envelope_L89
logical_envelope_L90:
    jmp logical_envelope_L87
logical_envelope_L89:
    jmp logical_envelope_L86
logical_envelope_L86:
; LEVEL = SUSTAIN
    lda SUSTAIN
    sta LEVEL
; PHASE = 3
    lda #3
    sta PHASE
    jmp logical_envelope_L88
logical_envelope_L87:
; LEVEL = LEVEL - DECAY
    lda LEVEL
    sec
    sbc DECAY
    sta LEVEL
logical_envelope_L88:
; return
    rts
    jmp logical_envelope_L78
logical_envelope_L77:
logical_envelope_L78:
; if PHASE == 3:
    lda PHASE
    cmp #3
    beq logical_envelope_L94
logical_envelope_L95:
    jmp logical_envelope_L92
logical_envelope_L94:
    jmp logical_envelope_L91
logical_envelope_L91:
; LEVEL = SUSTAIN
    lda SUSTAIN
    sta LEVEL
; return
    rts
    jmp logical_envelope_L93
logical_envelope_L92:
logical_envelope_L93:
; if RELEASE >= LEVEL:
    lda RELEASE
    cmp LEVEL
    bcs logical_envelope_L99
logical_envelope_L100:
    jmp logical_envelope_L97
logical_envelope_L99:
    jmp logical_envelope_L96
logical_envelope_L96:
; LEVEL = 0
    lda #0
    sta LEVEL
; PHASE = 0
    lda #0
    sta PHASE
    jmp logical_envelope_L98
logical_envelope_L97:
; LEVEL = LEVEL - RELEASE
    lda LEVEL
    sec
    sbc RELEASE
    sta LEVEL
logical_envelope_L98:
    rts
component_end:
