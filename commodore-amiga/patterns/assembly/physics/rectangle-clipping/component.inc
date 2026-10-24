; SPDX-License-Identifier: MIT
; Clip a Rectangle to a Viewport. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
rectangle_clipping_init:
    move.b #0,d0
    move.b d0,OUT_LEFT
    move.b d0,OUT_TOP
    move.b d0,OUT_RIGHT
    move.b d0,OUT_BOTTOM
    move.b d0,VISIBLE
    move.b d0,VALID
    move.b d0,LEFT
    move.b d0,TOP
    move.b d0,RIGHT
    move.b d0,BOTTOM
    move.b d0,VIEW_LEFT
    move.b d0,VIEW_TOP
    move.b d0,VIEW_RIGHT
    move.b d0,VIEW_BOTTOM
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    rts
rectangle_clipping_step:
; OUT_LEFT = 0
    move.b #0,d0
    move.b d0,OUT_LEFT
; OUT_TOP = 0
    move.b #0,d0
    move.b d0,OUT_TOP
; OUT_RIGHT = 0
    move.b #0,d0
    move.b d0,OUT_RIGHT
; OUT_BOTTOM = 0
    move.b #0,d0
    move.b d0,OUT_BOTTOM
; VISIBLE = 0
    move.b #0,d0
    move.b d0,VISIBLE
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if LEFT > RIGHT:
    move.b LEFT,d0
    move.b RIGHT,d1
    cmp.b d1,d0
    bhi rectangle_clipping_L1
    jmp rectangle_clipping_L2
rectangle_clipping_L1:
; return
    rts
    jmp rectangle_clipping_L3
rectangle_clipping_L2:
rectangle_clipping_L3:
; if TOP > BOTTOM:
    move.b TOP,d0
    move.b BOTTOM,d1
    cmp.b d1,d0
    bhi rectangle_clipping_L4
    jmp rectangle_clipping_L5
rectangle_clipping_L4:
; return
    rts
    jmp rectangle_clipping_L6
rectangle_clipping_L5:
rectangle_clipping_L6:
; if VIEW_LEFT > VIEW_RIGHT:
    move.b VIEW_LEFT,d0
    move.b VIEW_RIGHT,d1
    cmp.b d1,d0
    bhi rectangle_clipping_L7
    jmp rectangle_clipping_L8
rectangle_clipping_L7:
; return
    rts
    jmp rectangle_clipping_L9
rectangle_clipping_L8:
rectangle_clipping_L9:
; if VIEW_TOP > VIEW_BOTTOM:
    move.b VIEW_TOP,d0
    move.b VIEW_BOTTOM,d1
    cmp.b d1,d0
    bhi rectangle_clipping_L10
    jmp rectangle_clipping_L11
rectangle_clipping_L10:
; return
    rts
    jmp rectangle_clipping_L12
rectangle_clipping_L11:
rectangle_clipping_L12:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = LEFT
    move.b LEFT,d0
    move.b d0,T0
; if VIEW_LEFT > T0:
    move.b VIEW_LEFT,d0
    move.b T0,d1
    cmp.b d1,d0
    bhi rectangle_clipping_L13
    jmp rectangle_clipping_L14
rectangle_clipping_L13:
; T0 = VIEW_LEFT
    move.b VIEW_LEFT,d0
    move.b d0,T0
    jmp rectangle_clipping_L15
rectangle_clipping_L14:
rectangle_clipping_L15:
; T1 = TOP
    move.b TOP,d0
    move.b d0,T1
; if VIEW_TOP > T1:
    move.b VIEW_TOP,d0
    move.b T1,d1
    cmp.b d1,d0
    bhi rectangle_clipping_L16
    jmp rectangle_clipping_L17
rectangle_clipping_L16:
; T1 = VIEW_TOP
    move.b VIEW_TOP,d0
    move.b d0,T1
    jmp rectangle_clipping_L18
rectangle_clipping_L17:
rectangle_clipping_L18:
; T2 = RIGHT
    move.b RIGHT,d0
    move.b d0,T2
; if VIEW_RIGHT < T2:
    move.b VIEW_RIGHT,d0
    move.b T2,d1
    cmp.b d1,d0
    bcs rectangle_clipping_L19
    jmp rectangle_clipping_L20
rectangle_clipping_L19:
; T2 = VIEW_RIGHT
    move.b VIEW_RIGHT,d0
    move.b d0,T2
    jmp rectangle_clipping_L21
rectangle_clipping_L20:
rectangle_clipping_L21:
; T3 = BOTTOM
    move.b BOTTOM,d0
    move.b d0,T3
; if VIEW_BOTTOM < T3:
    move.b VIEW_BOTTOM,d0
    move.b T3,d1
    cmp.b d1,d0
    bcs rectangle_clipping_L22
    jmp rectangle_clipping_L23
rectangle_clipping_L22:
; T3 = VIEW_BOTTOM
    move.b VIEW_BOTTOM,d0
    move.b d0,T3
    jmp rectangle_clipping_L24
rectangle_clipping_L23:
rectangle_clipping_L24:
; if T0 >= T2:
    move.b T0,d0
    move.b T2,d1
    cmp.b d1,d0
    bcc rectangle_clipping_L25
    jmp rectangle_clipping_L26
rectangle_clipping_L25:
; return
    rts
    jmp rectangle_clipping_L27
rectangle_clipping_L26:
rectangle_clipping_L27:
; if T1 >= T3:
    move.b T1,d0
    move.b T3,d1
    cmp.b d1,d0
    bcc rectangle_clipping_L28
    jmp rectangle_clipping_L29
rectangle_clipping_L28:
; return
    rts
    jmp rectangle_clipping_L30
rectangle_clipping_L29:
rectangle_clipping_L30:
; OUT_LEFT = T0
    move.b T0,d0
    move.b d0,OUT_LEFT
; OUT_TOP = T1
    move.b T1,d0
    move.b d0,OUT_TOP
; OUT_RIGHT = T2
    move.b T2,d0
    move.b d0,OUT_RIGHT
; OUT_BOTTOM = T3
    move.b T3,d0
    move.b d0,OUT_BOTTOM
; VISIBLE = 1
    move.b #1,d0
    move.b d0,VISIBLE
    rts
component_end:
