; SPDX-License-Identifier: MIT
; Clip a Rectangle to a Viewport. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
rectangle_clipping_init:
    lda #0
    sta OUT_LEFT
    sta OUT_TOP
    sta OUT_RIGHT
    sta OUT_BOTTOM
    sta VISIBLE
    sta VALID
    sta LEFT
    sta TOP
    sta RIGHT
    sta BOTTOM
    sta VIEW_LEFT
    sta VIEW_TOP
    sta VIEW_RIGHT
    sta VIEW_BOTTOM
    sta T0
    sta T1
    sta T2
    sta T3
    rts
rectangle_clipping_step:
; OUT_LEFT = 0
    lda #0
    sta OUT_LEFT
; OUT_TOP = 0
    lda #0
    sta OUT_TOP
; OUT_RIGHT = 0
    lda #0
    sta OUT_RIGHT
; OUT_BOTTOM = 0
    lda #0
    sta OUT_BOTTOM
; VISIBLE = 0
    lda #0
    sta VISIBLE
; VALID = 0
    lda #0
    sta VALID
; if LEFT > RIGHT:
    lda LEFT
    cmp RIGHT
    beq rectangle_clipping_L5
    bcs rectangle_clipping_L4
rectangle_clipping_L5:
    jmp rectangle_clipping_L2
rectangle_clipping_L4:
    jmp rectangle_clipping_L1
rectangle_clipping_L1:
; return
    rts
    jmp rectangle_clipping_L3
rectangle_clipping_L2:
rectangle_clipping_L3:
; if TOP > BOTTOM:
    lda TOP
    cmp BOTTOM
    beq rectangle_clipping_L10
    bcs rectangle_clipping_L9
rectangle_clipping_L10:
    jmp rectangle_clipping_L7
rectangle_clipping_L9:
    jmp rectangle_clipping_L6
rectangle_clipping_L6:
; return
    rts
    jmp rectangle_clipping_L8
rectangle_clipping_L7:
rectangle_clipping_L8:
; if VIEW_LEFT > VIEW_RIGHT:
    lda VIEW_LEFT
    cmp VIEW_RIGHT
    beq rectangle_clipping_L15
    bcs rectangle_clipping_L14
rectangle_clipping_L15:
    jmp rectangle_clipping_L12
rectangle_clipping_L14:
    jmp rectangle_clipping_L11
rectangle_clipping_L11:
; return
    rts
    jmp rectangle_clipping_L13
rectangle_clipping_L12:
rectangle_clipping_L13:
; if VIEW_TOP > VIEW_BOTTOM:
    lda VIEW_TOP
    cmp VIEW_BOTTOM
    beq rectangle_clipping_L20
    bcs rectangle_clipping_L19
rectangle_clipping_L20:
    jmp rectangle_clipping_L17
rectangle_clipping_L19:
    jmp rectangle_clipping_L16
rectangle_clipping_L16:
; return
    rts
    jmp rectangle_clipping_L18
rectangle_clipping_L17:
rectangle_clipping_L18:
; VALID = 1
    lda #1
    sta VALID
; T0 = LEFT
    lda LEFT
    sta T0
; if VIEW_LEFT > T0:
    lda VIEW_LEFT
    cmp T0
    beq rectangle_clipping_L25
    bcs rectangle_clipping_L24
rectangle_clipping_L25:
    jmp rectangle_clipping_L22
rectangle_clipping_L24:
    jmp rectangle_clipping_L21
rectangle_clipping_L21:
; T0 = VIEW_LEFT
    lda VIEW_LEFT
    sta T0
    jmp rectangle_clipping_L23
rectangle_clipping_L22:
rectangle_clipping_L23:
; T1 = TOP
    lda TOP
    sta T1
; if VIEW_TOP > T1:
    lda VIEW_TOP
    cmp T1
    beq rectangle_clipping_L30
    bcs rectangle_clipping_L29
rectangle_clipping_L30:
    jmp rectangle_clipping_L27
rectangle_clipping_L29:
    jmp rectangle_clipping_L26
rectangle_clipping_L26:
; T1 = VIEW_TOP
    lda VIEW_TOP
    sta T1
    jmp rectangle_clipping_L28
rectangle_clipping_L27:
rectangle_clipping_L28:
; T2 = RIGHT
    lda RIGHT
    sta T2
; if VIEW_RIGHT < T2:
    lda VIEW_RIGHT
    cmp T2
    bcc rectangle_clipping_L34
rectangle_clipping_L35:
    jmp rectangle_clipping_L32
rectangle_clipping_L34:
    jmp rectangle_clipping_L31
rectangle_clipping_L31:
; T2 = VIEW_RIGHT
    lda VIEW_RIGHT
    sta T2
    jmp rectangle_clipping_L33
rectangle_clipping_L32:
rectangle_clipping_L33:
; T3 = BOTTOM
    lda BOTTOM
    sta T3
; if VIEW_BOTTOM < T3:
    lda VIEW_BOTTOM
    cmp T3
    bcc rectangle_clipping_L39
rectangle_clipping_L40:
    jmp rectangle_clipping_L37
rectangle_clipping_L39:
    jmp rectangle_clipping_L36
rectangle_clipping_L36:
; T3 = VIEW_BOTTOM
    lda VIEW_BOTTOM
    sta T3
    jmp rectangle_clipping_L38
rectangle_clipping_L37:
rectangle_clipping_L38:
; if T0 >= T2:
    lda T0
    cmp T2
    bcs rectangle_clipping_L44
rectangle_clipping_L45:
    jmp rectangle_clipping_L42
rectangle_clipping_L44:
    jmp rectangle_clipping_L41
rectangle_clipping_L41:
; return
    rts
    jmp rectangle_clipping_L43
rectangle_clipping_L42:
rectangle_clipping_L43:
; if T1 >= T3:
    lda T1
    cmp T3
    bcs rectangle_clipping_L49
rectangle_clipping_L50:
    jmp rectangle_clipping_L47
rectangle_clipping_L49:
    jmp rectangle_clipping_L46
rectangle_clipping_L46:
; return
    rts
    jmp rectangle_clipping_L48
rectangle_clipping_L47:
rectangle_clipping_L48:
; OUT_LEFT = T0
    lda T0
    sta OUT_LEFT
; OUT_TOP = T1
    lda T1
    sta OUT_TOP
; OUT_RIGHT = T2
    lda T2
    sta OUT_RIGHT
; OUT_BOTTOM = T3
    lda T3
    sta OUT_BOTTOM
; VISIBLE = 1
    lda #1
    sta VISIBLE
    rts
component_end:
