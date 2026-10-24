; SPDX-License-Identifier: MIT
; Choose a Bounded Text Line. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_text_wrap_init:
    lda #0
    sta LENGTH
    sta NEXT
    sta VALID
    sta START
    sta WIDTH
    sta COUNT
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
    rts
bounded_text_wrap_step:
; LENGTH = 0
    lda #0
    sta LENGTH
; NEXT = START
    lda START
    sta NEXT
; VALID = 0
    lda #0
    sta VALID
; if COUNT > 16:
    lda COUNT
    cmp #16
    beq bounded_text_wrap_L5
    bcs bounded_text_wrap_L4
bounded_text_wrap_L5:
    jmp bounded_text_wrap_L2
bounded_text_wrap_L4:
    jmp bounded_text_wrap_L1
bounded_text_wrap_L1:
; return
    rts
    jmp bounded_text_wrap_L3
bounded_text_wrap_L2:
bounded_text_wrap_L3:
; if START > COUNT:
    lda START
    cmp COUNT
    beq bounded_text_wrap_L10
    bcs bounded_text_wrap_L9
bounded_text_wrap_L10:
    jmp bounded_text_wrap_L7
bounded_text_wrap_L9:
    jmp bounded_text_wrap_L6
bounded_text_wrap_L6:
; return
    rts
    jmp bounded_text_wrap_L8
bounded_text_wrap_L7:
bounded_text_wrap_L8:
; if WIDTH == 0:
    lda WIDTH
    cmp #0
    beq bounded_text_wrap_L14
bounded_text_wrap_L15:
    jmp bounded_text_wrap_L12
bounded_text_wrap_L14:
    jmp bounded_text_wrap_L11
bounded_text_wrap_L11:
; return
    rts
    jmp bounded_text_wrap_L13
bounded_text_wrap_L12:
bounded_text_wrap_L13:
; if WIDTH > 16:
    lda WIDTH
    cmp #16
    beq bounded_text_wrap_L20
    bcs bounded_text_wrap_L19
bounded_text_wrap_L20:
    jmp bounded_text_wrap_L17
bounded_text_wrap_L19:
    jmp bounded_text_wrap_L16
bounded_text_wrap_L16:
; return
    rts
    jmp bounded_text_wrap_L18
bounded_text_wrap_L17:
bounded_text_wrap_L18:
; VALID = 1
    lda #1
    sta VALID
; while START < COUNT:
bounded_text_wrap_L21:
    lda START
    cmp COUNT
    bcc bounded_text_wrap_L24
bounded_text_wrap_L25:
    jmp bounded_text_wrap_L23
bounded_text_wrap_L24:
    jmp bounded_text_wrap_L22
bounded_text_wrap_L22:
; T0 = C[START]
    ldx START
    lda C0,x
    sta T0
; if T0 != 32:
    lda T0
    cmp #32
    bne bounded_text_wrap_L29
bounded_text_wrap_L30:
    jmp bounded_text_wrap_L27
bounded_text_wrap_L29:
    jmp bounded_text_wrap_L26
bounded_text_wrap_L26:
; break
    jmp bounded_text_wrap_L23
    jmp bounded_text_wrap_L28
bounded_text_wrap_L27:
bounded_text_wrap_L28:
; START = START + 1
    lda START
    clc
    adc #1
    sta START
    jmp bounded_text_wrap_L21
bounded_text_wrap_L23:
; NEXT = START
    lda START
    sta NEXT
; T0 = START
    lda START
    sta T0
; T1 = 255
    lda #255
    sta T1
; while T0 < COUNT:
bounded_text_wrap_L31:
    lda T0
    cmp COUNT
    bcc bounded_text_wrap_L34
bounded_text_wrap_L35:
    jmp bounded_text_wrap_L33
bounded_text_wrap_L34:
    jmp bounded_text_wrap_L32
bounded_text_wrap_L32:
; T2 = T0 - START
    lda T0
    sec
    sbc START
    sta T2
; if T2 == WIDTH:
    lda T2
    cmp WIDTH
    beq bounded_text_wrap_L39
bounded_text_wrap_L40:
    jmp bounded_text_wrap_L37
bounded_text_wrap_L39:
    jmp bounded_text_wrap_L36
bounded_text_wrap_L36:
; break
    jmp bounded_text_wrap_L33
    jmp bounded_text_wrap_L38
bounded_text_wrap_L37:
bounded_text_wrap_L38:
; T2 = C[T0]
    ldx T0
    lda C0,x
    sta T2
; if T2 == 32:
    lda T2
    cmp #32
    beq bounded_text_wrap_L44
bounded_text_wrap_L45:
    jmp bounded_text_wrap_L42
bounded_text_wrap_L44:
    jmp bounded_text_wrap_L41
bounded_text_wrap_L41:
; T1 = T0
    lda T0
    sta T1
    jmp bounded_text_wrap_L43
bounded_text_wrap_L42:
bounded_text_wrap_L43:
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp bounded_text_wrap_L31
bounded_text_wrap_L33:
; T2 = T0
    lda T0
    sta T2
; if T0 < COUNT:
    lda T0
    cmp COUNT
    bcc bounded_text_wrap_L49
bounded_text_wrap_L50:
    jmp bounded_text_wrap_L47
bounded_text_wrap_L49:
    jmp bounded_text_wrap_L46
bounded_text_wrap_L46:
; T3 = C[T0]
    ldx T0
    lda C0,x
    sta T3
; if T3 != 32:
    lda T3
    cmp #32
    bne bounded_text_wrap_L54
bounded_text_wrap_L55:
    jmp bounded_text_wrap_L52
bounded_text_wrap_L54:
    jmp bounded_text_wrap_L51
bounded_text_wrap_L51:
; if T1 != 255:
    lda T1
    cmp #255
    bne bounded_text_wrap_L59
bounded_text_wrap_L60:
    jmp bounded_text_wrap_L57
bounded_text_wrap_L59:
    jmp bounded_text_wrap_L56
bounded_text_wrap_L56:
; T2 = T1
    lda T1
    sta T2
    jmp bounded_text_wrap_L58
bounded_text_wrap_L57:
bounded_text_wrap_L58:
    jmp bounded_text_wrap_L53
bounded_text_wrap_L52:
bounded_text_wrap_L53:
    jmp bounded_text_wrap_L48
bounded_text_wrap_L47:
bounded_text_wrap_L48:
; LENGTH = T2 - START
    lda T2
    sec
    sbc START
    sta LENGTH
; NEXT = T2
    lda T2
    sta NEXT
; while NEXT < COUNT:
bounded_text_wrap_L61:
    lda NEXT
    cmp COUNT
    bcc bounded_text_wrap_L64
bounded_text_wrap_L65:
    jmp bounded_text_wrap_L63
bounded_text_wrap_L64:
    jmp bounded_text_wrap_L62
bounded_text_wrap_L62:
; T3 = C[NEXT]
    ldx NEXT
    lda C0,x
    sta T3
; if T3 != 32:
    lda T3
    cmp #32
    bne bounded_text_wrap_L69
bounded_text_wrap_L70:
    jmp bounded_text_wrap_L67
bounded_text_wrap_L69:
    jmp bounded_text_wrap_L66
bounded_text_wrap_L66:
; break
    jmp bounded_text_wrap_L63
    jmp bounded_text_wrap_L68
bounded_text_wrap_L67:
bounded_text_wrap_L68:
; NEXT = NEXT + 1
    lda NEXT
    clc
    adc #1
    sta NEXT
    jmp bounded_text_wrap_L61
bounded_text_wrap_L63:
    rts
component_end:
