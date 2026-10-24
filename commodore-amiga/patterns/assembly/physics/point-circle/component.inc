; SPDX-License-Identifier: MIT
; Test a Point Against a Circle. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
point_circle_init:
    move.b #0,d0
    move.b d0,HIT
    move.b d0,DX
    move.b d0,DY
    move.b d0,POINT_X
    move.b d0,POINT_Y
    move.b d0,CENTRE_X
    move.b d0,CENTRE_Y
    move.b d0,RADIUS
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    move.b d0,T4
    move.b d0,T5
    move.b d0,T6
    move.b d0,T7
    move.b d0,T8
    move.b d0,T9
    rts
point_circle_step:
; HIT = 0
    move.b #0,d0
    move.b d0,HIT
; if POINT_X >= CENTRE_X:
    move.b POINT_X,d0
    move.b CENTRE_X,d1
    cmp.b d1,d0
    bcc point_circle_L1
    jmp point_circle_L2
point_circle_L1:
; DX = POINT_X - CENTRE_X
    move.b POINT_X,d0
    move.b CENTRE_X,d1
    sub.b d1,d0
    move.b d0,DX
    jmp point_circle_L3
point_circle_L2:
; DX = CENTRE_X - POINT_X
    move.b CENTRE_X,d0
    move.b POINT_X,d1
    sub.b d1,d0
    move.b d0,DX
point_circle_L3:
; if POINT_Y >= CENTRE_Y:
    move.b POINT_Y,d0
    move.b CENTRE_Y,d1
    cmp.b d1,d0
    bcc point_circle_L4
    jmp point_circle_L5
point_circle_L4:
; DY = POINT_Y - CENTRE_Y
    move.b POINT_Y,d0
    move.b CENTRE_Y,d1
    sub.b d1,d0
    move.b d0,DY
    jmp point_circle_L6
point_circle_L5:
; DY = CENTRE_Y - POINT_Y
    move.b CENTRE_Y,d0
    move.b POINT_Y,d1
    sub.b d1,d0
    move.b d0,DY
point_circle_L6:
; if DX > RADIUS:
    move.b DX,d0
    move.b RADIUS,d1
    cmp.b d1,d0
    bhi point_circle_L7
    jmp point_circle_L8
point_circle_L7:
; return
    rts
    jmp point_circle_L9
point_circle_L8:
point_circle_L9:
; if DY > RADIUS:
    move.b DY,d0
    move.b RADIUS,d1
    cmp.b d1,d0
    bhi point_circle_L10
    jmp point_circle_L11
point_circle_L10:
; return
    rts
    jmp point_circle_L12
point_circle_L11:
point_circle_L12:
; T4 = RADIUS
    move.b RADIUS,d0
    move.b d0,T4
; T5 = 0
    move.b #0,d0
    move.b d0,T5
; T1 = RADIUS
    move.b RADIUS,d0
    move.b d0,T1
; T6 = 0
    move.b #0,d0
    move.b d0,T6
; T7 = 0
    move.b #0,d0
    move.b d0,T7
; T0 = 8
    move.b #8,d0
    move.b d0,T0
; while T0 != 0:
point_circle_L13:
    move.b T0,d0
    cmp.b #0,d0
    bne point_circle_L14
    jmp point_circle_L15
point_circle_L14:
; T9 = T1 & 1
    move.b T1,d0
    and.b #1,d0
    move.b d0,T9
; if T9 != 0:
    move.b T9,d0
    cmp.b #0,d0
    bne point_circle_L16
    jmp point_circle_L17
point_circle_L16:
; T8 = T6
    move.b T6,d0
    move.b d0,T8
; T6 = T6 + T4
    move.b T6,d0
    move.b T4,d1
    add.b d1,d0
    move.b d0,T6
; T9 = 0
    move.b #0,d0
    move.b d0,T9
; if T6 < T8:
    move.b T6,d0
    move.b T8,d1
    cmp.b d1,d0
    bcs point_circle_L19
    jmp point_circle_L20
point_circle_L19:
; T9 = 1
    move.b #1,d0
    move.b d0,T9
    jmp point_circle_L21
point_circle_L20:
point_circle_L21:
; T7 = T7 + T5
    move.b T7,d0
    move.b T5,d1
    add.b d1,d0
    move.b d0,T7
; T7 = T7 + T9
    move.b T7,d0
    move.b T9,d1
    add.b d1,d0
    move.b d0,T7
    jmp point_circle_L18
point_circle_L17:
point_circle_L18:
; T9 = T4 >> 7
    move.b T4,d0
    lsr.b #7,d0
    move.b d0,T9
; T4 = T4 << 1
    move.b T4,d0
    lsl.b #1,d0
    move.b d0,T4
; T5 = T5 << 1
    move.b T5,d0
    lsl.b #1,d0
    move.b d0,T5
; T5 = T5 | T9
    move.b T5,d0
    move.b T9,d1
    or.b d1,d0
    move.b d0,T5
; T1 = T1 >> 1
    move.b T1,d0
    lsr.b #1,d0
    move.b d0,T1
; T0 = T0 - 1
    move.b T0,d0
    sub.b #1,d0
    move.b d0,T0
    jmp point_circle_L13
point_circle_L15:
; T2 = T6
    move.b T6,d0
    move.b d0,T2
; T3 = T7
    move.b T7,d0
    move.b d0,T3
; T4 = DX
    move.b DX,d0
    move.b d0,T4
; T5 = 0
    move.b #0,d0
    move.b d0,T5
; T1 = DX
    move.b DX,d0
    move.b d0,T1
; T6 = 0
    move.b #0,d0
    move.b d0,T6
; T7 = 0
    move.b #0,d0
    move.b d0,T7
; T0 = 8
    move.b #8,d0
    move.b d0,T0
; while T0 != 0:
point_circle_L22:
    move.b T0,d0
    cmp.b #0,d0
    bne point_circle_L23
    jmp point_circle_L24
point_circle_L23:
; T9 = T1 & 1
    move.b T1,d0
    and.b #1,d0
    move.b d0,T9
; if T9 != 0:
    move.b T9,d0
    cmp.b #0,d0
    bne point_circle_L25
    jmp point_circle_L26
point_circle_L25:
; T8 = T6
    move.b T6,d0
    move.b d0,T8
; T6 = T6 + T4
    move.b T6,d0
    move.b T4,d1
    add.b d1,d0
    move.b d0,T6
; T9 = 0
    move.b #0,d0
    move.b d0,T9
; if T6 < T8:
    move.b T6,d0
    move.b T8,d1
    cmp.b d1,d0
    bcs point_circle_L28
    jmp point_circle_L29
point_circle_L28:
; T9 = 1
    move.b #1,d0
    move.b d0,T9
    jmp point_circle_L30
point_circle_L29:
point_circle_L30:
; T7 = T7 + T5
    move.b T7,d0
    move.b T5,d1
    add.b d1,d0
    move.b d0,T7
; T7 = T7 + T9
    move.b T7,d0
    move.b T9,d1
    add.b d1,d0
    move.b d0,T7
    jmp point_circle_L27
point_circle_L26:
point_circle_L27:
; T9 = T4 >> 7
    move.b T4,d0
    lsr.b #7,d0
    move.b d0,T9
; T4 = T4 << 1
    move.b T4,d0
    lsl.b #1,d0
    move.b d0,T4
; T5 = T5 << 1
    move.b T5,d0
    lsl.b #1,d0
    move.b d0,T5
; T5 = T5 | T9
    move.b T5,d0
    move.b T9,d1
    or.b d1,d0
    move.b d0,T5
; T1 = T1 >> 1
    move.b T1,d0
    lsr.b #1,d0
    move.b d0,T1
; T0 = T0 - 1
    move.b T0,d0
    sub.b #1,d0
    move.b d0,T0
    jmp point_circle_L22
point_circle_L24:
; T8 = 0
    move.b #0,d0
    move.b d0,T8
; if T2 < T6:
    move.b T2,d0
    move.b T6,d1
    cmp.b d1,d0
    bcs point_circle_L31
    jmp point_circle_L32
point_circle_L31:
; T8 = 1
    move.b #1,d0
    move.b d0,T8
    jmp point_circle_L33
point_circle_L32:
point_circle_L33:
; T2 = T2 - T6
    move.b T2,d0
    move.b T6,d1
    sub.b d1,d0
    move.b d0,T2
; T3 = T3 - T7
    move.b T3,d0
    move.b T7,d1
    sub.b d1,d0
    move.b d0,T3
; T3 = T3 - T8
    move.b T3,d0
    move.b T8,d1
    sub.b d1,d0
    move.b d0,T3
; T4 = DY
    move.b DY,d0
    move.b d0,T4
; T5 = 0
    move.b #0,d0
    move.b d0,T5
; T1 = DY
    move.b DY,d0
    move.b d0,T1
; T6 = 0
    move.b #0,d0
    move.b d0,T6
; T7 = 0
    move.b #0,d0
    move.b d0,T7
; T0 = 8
    move.b #8,d0
    move.b d0,T0
; while T0 != 0:
point_circle_L34:
    move.b T0,d0
    cmp.b #0,d0
    bne point_circle_L35
    jmp point_circle_L36
point_circle_L35:
; T9 = T1 & 1
    move.b T1,d0
    and.b #1,d0
    move.b d0,T9
; if T9 != 0:
    move.b T9,d0
    cmp.b #0,d0
    bne point_circle_L37
    jmp point_circle_L38
point_circle_L37:
; T8 = T6
    move.b T6,d0
    move.b d0,T8
; T6 = T6 + T4
    move.b T6,d0
    move.b T4,d1
    add.b d1,d0
    move.b d0,T6
; T9 = 0
    move.b #0,d0
    move.b d0,T9
; if T6 < T8:
    move.b T6,d0
    move.b T8,d1
    cmp.b d1,d0
    bcs point_circle_L40
    jmp point_circle_L41
point_circle_L40:
; T9 = 1
    move.b #1,d0
    move.b d0,T9
    jmp point_circle_L42
point_circle_L41:
point_circle_L42:
; T7 = T7 + T5
    move.b T7,d0
    move.b T5,d1
    add.b d1,d0
    move.b d0,T7
; T7 = T7 + T9
    move.b T7,d0
    move.b T9,d1
    add.b d1,d0
    move.b d0,T7
    jmp point_circle_L39
point_circle_L38:
point_circle_L39:
; T9 = T4 >> 7
    move.b T4,d0
    lsr.b #7,d0
    move.b d0,T9
; T4 = T4 << 1
    move.b T4,d0
    lsl.b #1,d0
    move.b d0,T4
; T5 = T5 << 1
    move.b T5,d0
    lsl.b #1,d0
    move.b d0,T5
; T5 = T5 | T9
    move.b T5,d0
    move.b T9,d1
    or.b d1,d0
    move.b d0,T5
; T1 = T1 >> 1
    move.b T1,d0
    lsr.b #1,d0
    move.b d0,T1
; T0 = T0 - 1
    move.b T0,d0
    sub.b #1,d0
    move.b d0,T0
    jmp point_circle_L34
point_circle_L36:
; if T7 > T3:
    move.b T7,d0
    move.b T3,d1
    cmp.b d1,d0
    bhi point_circle_L43
    jmp point_circle_L44
point_circle_L43:
; return
    rts
    jmp point_circle_L45
point_circle_L44:
point_circle_L45:
; if T7 == T3:
    move.b T7,d0
    move.b T3,d1
    cmp.b d1,d0
    beq point_circle_L46
    jmp point_circle_L47
point_circle_L46:
; if T6 > T2:
    move.b T6,d0
    move.b T2,d1
    cmp.b d1,d0
    bhi point_circle_L49
    jmp point_circle_L50
point_circle_L49:
; return
    rts
    jmp point_circle_L51
point_circle_L50:
point_circle_L51:
    jmp point_circle_L48
point_circle_L47:
point_circle_L48:
; HIT = 1
    move.b #1,d0
    move.b d0,HIT
    rts
component_end:
