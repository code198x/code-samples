; SPDX-License-Identifier: MIT
; Test a Point Against a Circle. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
point_circle_init:
    ld a,0
    ld (HIT),a
    ld (DX),a
    ld (DY),a
    ld (POINT_X),a
    ld (POINT_Y),a
    ld (CENTRE_X),a
    ld (CENTRE_Y),a
    ld (RADIUS),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ld (T4),a
    ld (T5),a
    ld (T6),a
    ld (T7),a
    ld (T8),a
    ld (T9),a
    ret
point_circle_step:
; HIT = 0
    ld a,0
    ld (HIT),a
; if POINT_X >= CENTRE_X:
    ld a,(POINT_X)
    ld b,a
    ld a,(CENTRE_X)
    ld c,a
    ld a,b
    cp c
    jp nc,point_circle_L1
    jp point_circle_L2
point_circle_L1:
; DX = POINT_X - CENTRE_X
    ld a,(POINT_X)
    ld b,a
    ld a,(CENTRE_X)
    ld c,a
    ld a,b
    sub c
    ld (DX),a
    jp point_circle_L3
point_circle_L2:
; DX = CENTRE_X - POINT_X
    ld a,(CENTRE_X)
    ld b,a
    ld a,(POINT_X)
    ld c,a
    ld a,b
    sub c
    ld (DX),a
point_circle_L3:
; if POINT_Y >= CENTRE_Y:
    ld a,(POINT_Y)
    ld b,a
    ld a,(CENTRE_Y)
    ld c,a
    ld a,b
    cp c
    jp nc,point_circle_L4
    jp point_circle_L5
point_circle_L4:
; DY = POINT_Y - CENTRE_Y
    ld a,(POINT_Y)
    ld b,a
    ld a,(CENTRE_Y)
    ld c,a
    ld a,b
    sub c
    ld (DY),a
    jp point_circle_L6
point_circle_L5:
; DY = CENTRE_Y - POINT_Y
    ld a,(CENTRE_Y)
    ld b,a
    ld a,(POINT_Y)
    ld c,a
    ld a,b
    sub c
    ld (DY),a
point_circle_L6:
; if DX > RADIUS:
    ld a,(DX)
    ld b,a
    ld a,(RADIUS)
    ld c,a
    ld a,b
    cp c
    jp z,point_circle_L8
    jp nc,point_circle_L7
    jp point_circle_L8
point_circle_L7:
; return
    ret
    jp point_circle_L9
point_circle_L8:
point_circle_L9:
; if DY > RADIUS:
    ld a,(DY)
    ld b,a
    ld a,(RADIUS)
    ld c,a
    ld a,b
    cp c
    jp z,point_circle_L11
    jp nc,point_circle_L10
    jp point_circle_L11
point_circle_L10:
; return
    ret
    jp point_circle_L12
point_circle_L11:
point_circle_L12:
; T4 = RADIUS
    ld a,(RADIUS)
    ld (T4),a
; T5 = 0
    ld a,0
    ld (T5),a
; T1 = RADIUS
    ld a,(RADIUS)
    ld (T1),a
; T6 = 0
    ld a,0
    ld (T6),a
; T7 = 0
    ld a,0
    ld (T7),a
; T0 = 8
    ld a,8
    ld (T0),a
; while T0 != 0:
point_circle_L13:
    ld a,(T0)
    cp 0
    jp nz,point_circle_L14
    jp point_circle_L15
point_circle_L14:
; T9 = T1 & 1
    ld a,(T1)
    and 1
    ld (T9),a
; if T9 != 0:
    ld a,(T9)
    cp 0
    jp nz,point_circle_L16
    jp point_circle_L17
point_circle_L16:
; T8 = T6
    ld a,(T6)
    ld (T8),a
; T6 = T6 + T4
    ld a,(T6)
    ld b,a
    ld a,(T4)
    ld c,a
    ld a,b
    add a,c
    ld (T6),a
; T9 = 0
    ld a,0
    ld (T9),a
; if T6 < T8:
    ld a,(T6)
    ld b,a
    ld a,(T8)
    ld c,a
    ld a,b
    cp c
    jp c,point_circle_L19
    jp point_circle_L20
point_circle_L19:
; T9 = 1
    ld a,1
    ld (T9),a
    jp point_circle_L21
point_circle_L20:
point_circle_L21:
; T7 = T7 + T5
    ld a,(T7)
    ld b,a
    ld a,(T5)
    ld c,a
    ld a,b
    add a,c
    ld (T7),a
; T7 = T7 + T9
    ld a,(T7)
    ld b,a
    ld a,(T9)
    ld c,a
    ld a,b
    add a,c
    ld (T7),a
    jp point_circle_L18
point_circle_L17:
point_circle_L18:
; T9 = T4 >> 7
    ld a,(T4)
    srl a
    srl a
    srl a
    srl a
    srl a
    srl a
    srl a
    ld (T9),a
; T4 = T4 << 1
    ld a,(T4)
    sla a
    ld (T4),a
; T5 = T5 << 1
    ld a,(T5)
    sla a
    ld (T5),a
; T5 = T5 | T9
    ld a,(T5)
    ld b,a
    ld a,(T9)
    ld c,a
    ld a,b
    or c
    ld (T5),a
; T1 = T1 >> 1
    ld a,(T1)
    srl a
    ld (T1),a
; T0 = T0 - 1
    ld a,(T0)
    sub 1
    ld (T0),a
    jp point_circle_L13
point_circle_L15:
; T2 = T6
    ld a,(T6)
    ld (T2),a
; T3 = T7
    ld a,(T7)
    ld (T3),a
; T4 = DX
    ld a,(DX)
    ld (T4),a
; T5 = 0
    ld a,0
    ld (T5),a
; T1 = DX
    ld a,(DX)
    ld (T1),a
; T6 = 0
    ld a,0
    ld (T6),a
; T7 = 0
    ld a,0
    ld (T7),a
; T0 = 8
    ld a,8
    ld (T0),a
; while T0 != 0:
point_circle_L22:
    ld a,(T0)
    cp 0
    jp nz,point_circle_L23
    jp point_circle_L24
point_circle_L23:
; T9 = T1 & 1
    ld a,(T1)
    and 1
    ld (T9),a
; if T9 != 0:
    ld a,(T9)
    cp 0
    jp nz,point_circle_L25
    jp point_circle_L26
point_circle_L25:
; T8 = T6
    ld a,(T6)
    ld (T8),a
; T6 = T6 + T4
    ld a,(T6)
    ld b,a
    ld a,(T4)
    ld c,a
    ld a,b
    add a,c
    ld (T6),a
; T9 = 0
    ld a,0
    ld (T9),a
; if T6 < T8:
    ld a,(T6)
    ld b,a
    ld a,(T8)
    ld c,a
    ld a,b
    cp c
    jp c,point_circle_L28
    jp point_circle_L29
point_circle_L28:
; T9 = 1
    ld a,1
    ld (T9),a
    jp point_circle_L30
point_circle_L29:
point_circle_L30:
; T7 = T7 + T5
    ld a,(T7)
    ld b,a
    ld a,(T5)
    ld c,a
    ld a,b
    add a,c
    ld (T7),a
; T7 = T7 + T9
    ld a,(T7)
    ld b,a
    ld a,(T9)
    ld c,a
    ld a,b
    add a,c
    ld (T7),a
    jp point_circle_L27
point_circle_L26:
point_circle_L27:
; T9 = T4 >> 7
    ld a,(T4)
    srl a
    srl a
    srl a
    srl a
    srl a
    srl a
    srl a
    ld (T9),a
; T4 = T4 << 1
    ld a,(T4)
    sla a
    ld (T4),a
; T5 = T5 << 1
    ld a,(T5)
    sla a
    ld (T5),a
; T5 = T5 | T9
    ld a,(T5)
    ld b,a
    ld a,(T9)
    ld c,a
    ld a,b
    or c
    ld (T5),a
; T1 = T1 >> 1
    ld a,(T1)
    srl a
    ld (T1),a
; T0 = T0 - 1
    ld a,(T0)
    sub 1
    ld (T0),a
    jp point_circle_L22
point_circle_L24:
; T8 = 0
    ld a,0
    ld (T8),a
; if T2 < T6:
    ld a,(T2)
    ld b,a
    ld a,(T6)
    ld c,a
    ld a,b
    cp c
    jp c,point_circle_L31
    jp point_circle_L32
point_circle_L31:
; T8 = 1
    ld a,1
    ld (T8),a
    jp point_circle_L33
point_circle_L32:
point_circle_L33:
; T2 = T2 - T6
    ld a,(T2)
    ld b,a
    ld a,(T6)
    ld c,a
    ld a,b
    sub c
    ld (T2),a
; T3 = T3 - T7
    ld a,(T3)
    ld b,a
    ld a,(T7)
    ld c,a
    ld a,b
    sub c
    ld (T3),a
; T3 = T3 - T8
    ld a,(T3)
    ld b,a
    ld a,(T8)
    ld c,a
    ld a,b
    sub c
    ld (T3),a
; T4 = DY
    ld a,(DY)
    ld (T4),a
; T5 = 0
    ld a,0
    ld (T5),a
; T1 = DY
    ld a,(DY)
    ld (T1),a
; T6 = 0
    ld a,0
    ld (T6),a
; T7 = 0
    ld a,0
    ld (T7),a
; T0 = 8
    ld a,8
    ld (T0),a
; while T0 != 0:
point_circle_L34:
    ld a,(T0)
    cp 0
    jp nz,point_circle_L35
    jp point_circle_L36
point_circle_L35:
; T9 = T1 & 1
    ld a,(T1)
    and 1
    ld (T9),a
; if T9 != 0:
    ld a,(T9)
    cp 0
    jp nz,point_circle_L37
    jp point_circle_L38
point_circle_L37:
; T8 = T6
    ld a,(T6)
    ld (T8),a
; T6 = T6 + T4
    ld a,(T6)
    ld b,a
    ld a,(T4)
    ld c,a
    ld a,b
    add a,c
    ld (T6),a
; T9 = 0
    ld a,0
    ld (T9),a
; if T6 < T8:
    ld a,(T6)
    ld b,a
    ld a,(T8)
    ld c,a
    ld a,b
    cp c
    jp c,point_circle_L40
    jp point_circle_L41
point_circle_L40:
; T9 = 1
    ld a,1
    ld (T9),a
    jp point_circle_L42
point_circle_L41:
point_circle_L42:
; T7 = T7 + T5
    ld a,(T7)
    ld b,a
    ld a,(T5)
    ld c,a
    ld a,b
    add a,c
    ld (T7),a
; T7 = T7 + T9
    ld a,(T7)
    ld b,a
    ld a,(T9)
    ld c,a
    ld a,b
    add a,c
    ld (T7),a
    jp point_circle_L39
point_circle_L38:
point_circle_L39:
; T9 = T4 >> 7
    ld a,(T4)
    srl a
    srl a
    srl a
    srl a
    srl a
    srl a
    srl a
    ld (T9),a
; T4 = T4 << 1
    ld a,(T4)
    sla a
    ld (T4),a
; T5 = T5 << 1
    ld a,(T5)
    sla a
    ld (T5),a
; T5 = T5 | T9
    ld a,(T5)
    ld b,a
    ld a,(T9)
    ld c,a
    ld a,b
    or c
    ld (T5),a
; T1 = T1 >> 1
    ld a,(T1)
    srl a
    ld (T1),a
; T0 = T0 - 1
    ld a,(T0)
    sub 1
    ld (T0),a
    jp point_circle_L34
point_circle_L36:
; if T7 > T3:
    ld a,(T7)
    ld b,a
    ld a,(T3)
    ld c,a
    ld a,b
    cp c
    jp z,point_circle_L44
    jp nc,point_circle_L43
    jp point_circle_L44
point_circle_L43:
; return
    ret
    jp point_circle_L45
point_circle_L44:
point_circle_L45:
; if T7 == T3:
    ld a,(T7)
    ld b,a
    ld a,(T3)
    ld c,a
    ld a,b
    cp c
    jp z,point_circle_L46
    jp point_circle_L47
point_circle_L46:
; if T6 > T2:
    ld a,(T6)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    cp c
    jp z,point_circle_L50
    jp nc,point_circle_L49
    jp point_circle_L50
point_circle_L49:
; return
    ret
    jp point_circle_L51
point_circle_L50:
point_circle_L51:
    jp point_circle_L48
point_circle_L47:
point_circle_L48:
; HIT = 1
    ld a,1
    ld (HIT),a
    ret
component_end:
