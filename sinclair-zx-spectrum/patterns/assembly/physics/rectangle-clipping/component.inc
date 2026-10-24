; SPDX-License-Identifier: MIT
; Clip a Rectangle to a Viewport. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
rectangle_clipping_init:
    ld a,0
    ld (OUT_LEFT),a
    ld (OUT_TOP),a
    ld (OUT_RIGHT),a
    ld (OUT_BOTTOM),a
    ld (VISIBLE),a
    ld (VALID),a
    ld (LEFT),a
    ld (TOP),a
    ld (RIGHT),a
    ld (BOTTOM),a
    ld (VIEW_LEFT),a
    ld (VIEW_TOP),a
    ld (VIEW_RIGHT),a
    ld (VIEW_BOTTOM),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ret
rectangle_clipping_step:
; OUT_LEFT = 0
    ld a,0
    ld (OUT_LEFT),a
; OUT_TOP = 0
    ld a,0
    ld (OUT_TOP),a
; OUT_RIGHT = 0
    ld a,0
    ld (OUT_RIGHT),a
; OUT_BOTTOM = 0
    ld a,0
    ld (OUT_BOTTOM),a
; VISIBLE = 0
    ld a,0
    ld (VISIBLE),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if LEFT > RIGHT:
    ld a,(LEFT)
    ld b,a
    ld a,(RIGHT)
    ld c,a
    ld a,b
    cp c
    jp z,rectangle_clipping_L2
    jp nc,rectangle_clipping_L1
    jp rectangle_clipping_L2
rectangle_clipping_L1:
; return
    ret
    jp rectangle_clipping_L3
rectangle_clipping_L2:
rectangle_clipping_L3:
; if TOP > BOTTOM:
    ld a,(TOP)
    ld b,a
    ld a,(BOTTOM)
    ld c,a
    ld a,b
    cp c
    jp z,rectangle_clipping_L5
    jp nc,rectangle_clipping_L4
    jp rectangle_clipping_L5
rectangle_clipping_L4:
; return
    ret
    jp rectangle_clipping_L6
rectangle_clipping_L5:
rectangle_clipping_L6:
; if VIEW_LEFT > VIEW_RIGHT:
    ld a,(VIEW_LEFT)
    ld b,a
    ld a,(VIEW_RIGHT)
    ld c,a
    ld a,b
    cp c
    jp z,rectangle_clipping_L8
    jp nc,rectangle_clipping_L7
    jp rectangle_clipping_L8
rectangle_clipping_L7:
; return
    ret
    jp rectangle_clipping_L9
rectangle_clipping_L8:
rectangle_clipping_L9:
; if VIEW_TOP > VIEW_BOTTOM:
    ld a,(VIEW_TOP)
    ld b,a
    ld a,(VIEW_BOTTOM)
    ld c,a
    ld a,b
    cp c
    jp z,rectangle_clipping_L11
    jp nc,rectangle_clipping_L10
    jp rectangle_clipping_L11
rectangle_clipping_L10:
; return
    ret
    jp rectangle_clipping_L12
rectangle_clipping_L11:
rectangle_clipping_L12:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = LEFT
    ld a,(LEFT)
    ld (T0),a
; if VIEW_LEFT > T0:
    ld a,(VIEW_LEFT)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp z,rectangle_clipping_L14
    jp nc,rectangle_clipping_L13
    jp rectangle_clipping_L14
rectangle_clipping_L13:
; T0 = VIEW_LEFT
    ld a,(VIEW_LEFT)
    ld (T0),a
    jp rectangle_clipping_L15
rectangle_clipping_L14:
rectangle_clipping_L15:
; T1 = TOP
    ld a,(TOP)
    ld (T1),a
; if VIEW_TOP > T1:
    ld a,(VIEW_TOP)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    cp c
    jp z,rectangle_clipping_L17
    jp nc,rectangle_clipping_L16
    jp rectangle_clipping_L17
rectangle_clipping_L16:
; T1 = VIEW_TOP
    ld a,(VIEW_TOP)
    ld (T1),a
    jp rectangle_clipping_L18
rectangle_clipping_L17:
rectangle_clipping_L18:
; T2 = RIGHT
    ld a,(RIGHT)
    ld (T2),a
; if VIEW_RIGHT < T2:
    ld a,(VIEW_RIGHT)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    cp c
    jp c,rectangle_clipping_L19
    jp rectangle_clipping_L20
rectangle_clipping_L19:
; T2 = VIEW_RIGHT
    ld a,(VIEW_RIGHT)
    ld (T2),a
    jp rectangle_clipping_L21
rectangle_clipping_L20:
rectangle_clipping_L21:
; T3 = BOTTOM
    ld a,(BOTTOM)
    ld (T3),a
; if VIEW_BOTTOM < T3:
    ld a,(VIEW_BOTTOM)
    ld b,a
    ld a,(T3)
    ld c,a
    ld a,b
    cp c
    jp c,rectangle_clipping_L22
    jp rectangle_clipping_L23
rectangle_clipping_L22:
; T3 = VIEW_BOTTOM
    ld a,(VIEW_BOTTOM)
    ld (T3),a
    jp rectangle_clipping_L24
rectangle_clipping_L23:
rectangle_clipping_L24:
; if T0 >= T2:
    ld a,(T0)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    cp c
    jp nc,rectangle_clipping_L25
    jp rectangle_clipping_L26
rectangle_clipping_L25:
; return
    ret
    jp rectangle_clipping_L27
rectangle_clipping_L26:
rectangle_clipping_L27:
; if T1 >= T3:
    ld a,(T1)
    ld b,a
    ld a,(T3)
    ld c,a
    ld a,b
    cp c
    jp nc,rectangle_clipping_L28
    jp rectangle_clipping_L29
rectangle_clipping_L28:
; return
    ret
    jp rectangle_clipping_L30
rectangle_clipping_L29:
rectangle_clipping_L30:
; OUT_LEFT = T0
    ld a,(T0)
    ld (OUT_LEFT),a
; OUT_TOP = T1
    ld a,(T1)
    ld (OUT_TOP),a
; OUT_RIGHT = T2
    ld a,(T2)
    ld (OUT_RIGHT),a
; OUT_BOTTOM = T3
    ld a,(T3)
    ld (OUT_BOTTOM),a
; VISIBLE = 1
    ld a,1
    ld (VISIBLE),a
    ret
component_end:
