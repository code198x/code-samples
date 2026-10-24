; SPDX-License-Identifier: MIT
; Enter and Leave a Ladder. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
ladder_controller_init:
    lda #0
    sta MODE
    sta POSITION
    sta GRAVITY
    sta JUMPED
    sta VALID
    sta ON_LADDER
    sta UP
    sta DOWN
    sta JUMP
    sta MINIMUM
    sta MAXIMUM
    rts
ladder_controller_step:
; GRAVITY = 0
    lda #0
    sta GRAVITY
; JUMPED = 0
    lda #0
    sta JUMPED
; VALID = 0
    lda #0
    sta VALID
; if MODE > 1:
    lda MODE
    cmp #1
    beq ladder_controller_L5
    bcs ladder_controller_L4
ladder_controller_L5:
    jmp ladder_controller_L2
ladder_controller_L4:
    jmp ladder_controller_L1
ladder_controller_L1:
; return
    rts
    jmp ladder_controller_L3
ladder_controller_L2:
ladder_controller_L3:
; if MINIMUM > POSITION:
    lda MINIMUM
    cmp POSITION
    beq ladder_controller_L10
    bcs ladder_controller_L9
ladder_controller_L10:
    jmp ladder_controller_L7
ladder_controller_L9:
    jmp ladder_controller_L6
ladder_controller_L6:
; return
    rts
    jmp ladder_controller_L8
ladder_controller_L7:
ladder_controller_L8:
; if POSITION > MAXIMUM:
    lda POSITION
    cmp MAXIMUM
    beq ladder_controller_L15
    bcs ladder_controller_L14
ladder_controller_L15:
    jmp ladder_controller_L12
ladder_controller_L14:
    jmp ladder_controller_L11
ladder_controller_L11:
; return
    rts
    jmp ladder_controller_L13
ladder_controller_L12:
ladder_controller_L13:
; VALID = 1
    lda #1
    sta VALID
; if ON_LADDER == 0:
    lda ON_LADDER
    cmp #0
    beq ladder_controller_L19
ladder_controller_L20:
    jmp ladder_controller_L17
ladder_controller_L19:
    jmp ladder_controller_L16
ladder_controller_L16:
; MODE = 0
    lda #0
    sta MODE
    jmp ladder_controller_L18
ladder_controller_L17:
; if MODE == 0:
    lda MODE
    cmp #0
    beq ladder_controller_L24
ladder_controller_L25:
    jmp ladder_controller_L22
ladder_controller_L24:
    jmp ladder_controller_L21
ladder_controller_L21:
; if UP != 0:
    lda UP
    cmp #0
    bne ladder_controller_L29
ladder_controller_L30:
    jmp ladder_controller_L27
ladder_controller_L29:
    jmp ladder_controller_L26
ladder_controller_L26:
; MODE = 1
    lda #1
    sta MODE
    jmp ladder_controller_L28
ladder_controller_L27:
ladder_controller_L28:
; if DOWN != 0:
    lda DOWN
    cmp #0
    bne ladder_controller_L34
ladder_controller_L35:
    jmp ladder_controller_L32
ladder_controller_L34:
    jmp ladder_controller_L31
ladder_controller_L31:
; MODE = 1
    lda #1
    sta MODE
    jmp ladder_controller_L33
ladder_controller_L32:
ladder_controller_L33:
    jmp ladder_controller_L23
ladder_controller_L22:
ladder_controller_L23:
; if MODE == 1:
    lda MODE
    cmp #1
    beq ladder_controller_L39
ladder_controller_L40:
    jmp ladder_controller_L37
ladder_controller_L39:
    jmp ladder_controller_L36
ladder_controller_L36:
; if JUMP != 0:
    lda JUMP
    cmp #0
    bne ladder_controller_L44
ladder_controller_L45:
    jmp ladder_controller_L42
ladder_controller_L44:
    jmp ladder_controller_L41
ladder_controller_L41:
; MODE = 0
    lda #0
    sta MODE
; JUMPED = 1
    lda #1
    sta JUMPED
    jmp ladder_controller_L43
ladder_controller_L42:
; if UP != 0:
    lda UP
    cmp #0
    bne ladder_controller_L49
ladder_controller_L50:
    jmp ladder_controller_L47
ladder_controller_L49:
    jmp ladder_controller_L46
ladder_controller_L46:
; if DOWN == 0:
    lda DOWN
    cmp #0
    beq ladder_controller_L54
ladder_controller_L55:
    jmp ladder_controller_L52
ladder_controller_L54:
    jmp ladder_controller_L51
ladder_controller_L51:
; if POSITION > MINIMUM:
    lda POSITION
    cmp MINIMUM
    beq ladder_controller_L60
    bcs ladder_controller_L59
ladder_controller_L60:
    jmp ladder_controller_L57
ladder_controller_L59:
    jmp ladder_controller_L56
ladder_controller_L56:
; POSITION = POSITION - 1
    lda POSITION
    sec
    sbc #1
    sta POSITION
    jmp ladder_controller_L58
ladder_controller_L57:
ladder_controller_L58:
    jmp ladder_controller_L53
ladder_controller_L52:
ladder_controller_L53:
    jmp ladder_controller_L48
ladder_controller_L47:
; if DOWN != 0:
    lda DOWN
    cmp #0
    bne ladder_controller_L64
ladder_controller_L65:
    jmp ladder_controller_L62
ladder_controller_L64:
    jmp ladder_controller_L61
ladder_controller_L61:
; if POSITION < MAXIMUM:
    lda POSITION
    cmp MAXIMUM
    bcc ladder_controller_L69
ladder_controller_L70:
    jmp ladder_controller_L67
ladder_controller_L69:
    jmp ladder_controller_L66
ladder_controller_L66:
; POSITION = POSITION + 1
    lda POSITION
    clc
    adc #1
    sta POSITION
    jmp ladder_controller_L68
ladder_controller_L67:
ladder_controller_L68:
    jmp ladder_controller_L63
ladder_controller_L62:
ladder_controller_L63:
ladder_controller_L48:
ladder_controller_L43:
    jmp ladder_controller_L38
ladder_controller_L37:
ladder_controller_L38:
ladder_controller_L18:
; if MODE == 0:
    lda MODE
    cmp #0
    beq ladder_controller_L74
ladder_controller_L75:
    jmp ladder_controller_L72
ladder_controller_L74:
    jmp ladder_controller_L71
ladder_controller_L71:
; GRAVITY = 1
    lda #1
    sta GRAVITY
    jmp ladder_controller_L73
ladder_controller_L72:
ladder_controller_L73:
    rts
component_end:
