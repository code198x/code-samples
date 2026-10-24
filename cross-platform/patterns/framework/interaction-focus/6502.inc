; SPDX-License-Identifier: MIT
; Keep a Stable Interaction Focus. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
interaction_focus_init:
    lda #0
    sta SELECTED
    sta VALID
    sta CURRENT
    sta ACTIVE
    sta RANGE
    sta MARGIN
    sta D0
    sta D1
    sta D2
    sta D3
    sta T0
    sta T1
    sta T2
    sta T3
    sta T4
    sta T5
    rts
interaction_focus_step:
; SELECTED = 255
    lda #255
    sta SELECTED
; VALID = 0
    lda #0
    sta VALID
; if CURRENT != 255:
    lda CURRENT
    cmp #255
    bne interaction_focus_L4
interaction_focus_L5:
    jmp interaction_focus_L2
interaction_focus_L4:
    jmp interaction_focus_L1
interaction_focus_L1:
; if CURRENT >= 4:
    lda CURRENT
    cmp #4
    bcs interaction_focus_L9
interaction_focus_L10:
    jmp interaction_focus_L7
interaction_focus_L9:
    jmp interaction_focus_L6
interaction_focus_L6:
; return
    rts
    jmp interaction_focus_L8
interaction_focus_L7:
interaction_focus_L8:
    jmp interaction_focus_L3
interaction_focus_L2:
interaction_focus_L3:
; if ACTIVE >= 16:
    lda ACTIVE
    cmp #16
    bcs interaction_focus_L14
interaction_focus_L15:
    jmp interaction_focus_L12
interaction_focus_L14:
    jmp interaction_focus_L11
interaction_focus_L11:
; return
    rts
    jmp interaction_focus_L13
interaction_focus_L12:
interaction_focus_L13:
; VALID = 1
    lda #1
    sta VALID
; T0 = 0
    lda #0
    sta T0
; T1 = ACTIVE
    lda ACTIVE
    sta T1
; T2 = 255
    lda #255
    sta T2
; T3 = 0
    lda #0
    sta T3
; T4 = 255
    lda #255
    sta T4
; while T0 < 4:
interaction_focus_L16:
    lda T0
    cmp #4
    bcc interaction_focus_L19
interaction_focus_L20:
    jmp interaction_focus_L18
interaction_focus_L19:
    jmp interaction_focus_L17
interaction_focus_L17:
; T5 = T1 & 1
    lda T1
    and #1
    sta T5
; if T5 != 0:
    lda T5
    cmp #0
    bne interaction_focus_L24
interaction_focus_L25:
    jmp interaction_focus_L22
interaction_focus_L24:
    jmp interaction_focus_L21
interaction_focus_L21:
; T5 = D[T0]
    ldx T0
    lda D0,x
    sta T5
; if T5 <= RANGE:
    lda T5
    cmp RANGE
    bcc interaction_focus_L29
    beq interaction_focus_L29
interaction_focus_L30:
    jmp interaction_focus_L27
interaction_focus_L29:
    jmp interaction_focus_L26
interaction_focus_L26:
; if SELECTED == 255:
    lda SELECTED
    cmp #255
    beq interaction_focus_L34
interaction_focus_L35:
    jmp interaction_focus_L32
interaction_focus_L34:
    jmp interaction_focus_L31
interaction_focus_L31:
; SELECTED = T0
    lda T0
    sta SELECTED
; T2 = T5
    lda T5
    sta T2
    jmp interaction_focus_L33
interaction_focus_L32:
; if T5 < T2:
    lda T5
    cmp T2
    bcc interaction_focus_L39
interaction_focus_L40:
    jmp interaction_focus_L37
interaction_focus_L39:
    jmp interaction_focus_L36
interaction_focus_L36:
; SELECTED = T0
    lda T0
    sta SELECTED
; T2 = T5
    lda T5
    sta T2
    jmp interaction_focus_L38
interaction_focus_L37:
interaction_focus_L38:
interaction_focus_L33:
; if T0 == CURRENT:
    lda T0
    cmp CURRENT
    beq interaction_focus_L44
interaction_focus_L45:
    jmp interaction_focus_L42
interaction_focus_L44:
    jmp interaction_focus_L41
interaction_focus_L41:
; T3 = 1
    lda #1
    sta T3
; T4 = T5
    lda T5
    sta T4
    jmp interaction_focus_L43
interaction_focus_L42:
interaction_focus_L43:
    jmp interaction_focus_L28
interaction_focus_L27:
interaction_focus_L28:
    jmp interaction_focus_L23
interaction_focus_L22:
interaction_focus_L23:
; T1 = T1 >> 1
    lda T1
    lsr
    sta T1
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp interaction_focus_L16
interaction_focus_L18:
; if T3 != 0:
    lda T3
    cmp #0
    bne interaction_focus_L49
interaction_focus_L50:
    jmp interaction_focus_L47
interaction_focus_L49:
    jmp interaction_focus_L46
interaction_focus_L46:
; T5 = T4 - T2
    lda T4
    sec
    sbc T2
    sta T5
; if T5 <= MARGIN:
    lda T5
    cmp MARGIN
    bcc interaction_focus_L54
    beq interaction_focus_L54
interaction_focus_L55:
    jmp interaction_focus_L52
interaction_focus_L54:
    jmp interaction_focus_L51
interaction_focus_L51:
; SELECTED = CURRENT
    lda CURRENT
    sta SELECTED
    jmp interaction_focus_L53
interaction_focus_L52:
interaction_focus_L53:
    jmp interaction_focus_L48
interaction_focus_L47:
interaction_focus_L48:
    rts
component_end:
