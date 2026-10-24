; SPDX-License-Identifier: MIT
; Keep a Small Position History. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
motion_history_init:
    move.b #0,d0
    move.b d0,OUT_X
    move.b d0,OUT_Y
    move.b d0,VALID
    move.b d0,HEAD
    move.b d0,COUNT
    move.b d0,INPUT_X
    move.b d0,INPUT_Y
    move.b d0,LAG
    move.b d0,PUSH
    move.b d0,HX0
    move.b d0,HX1
    move.b d0,HX2
    move.b d0,HX3
    move.b d0,HX4
    move.b d0,HX5
    move.b d0,HX6
    move.b d0,HX7
    move.b d0,HY0
    move.b d0,HY1
    move.b d0,HY2
    move.b d0,HY3
    move.b d0,HY4
    move.b d0,HY5
    move.b d0,HY6
    move.b d0,HY7
    move.b d0,T0
    move.b d0,EXPR_SAVE
    rts
motion_history_step:
; OUT_X = 0
    move.b #0,d0
    move.b d0,OUT_X
; OUT_Y = 0
    move.b #0,d0
    move.b d0,OUT_Y
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if HEAD >= 8:
    move.b HEAD,d0
    cmp.b #8,d0
    bcc motion_history_L1
    jmp motion_history_L2
motion_history_L1:
; return
    rts
    jmp motion_history_L3
motion_history_L2:
motion_history_L3:
; if COUNT > 8:
    move.b COUNT,d0
    cmp.b #8,d0
    bhi motion_history_L4
    jmp motion_history_L5
motion_history_L4:
; return
    rts
    jmp motion_history_L6
motion_history_L5:
motion_history_L6:
; if PUSH != 0:
    move.b PUSH,d0
    cmp.b #0,d0
    bne motion_history_L7
    jmp motion_history_L8
motion_history_L7:
; HX[HEAD] = INPUT_X
    move.b INPUT_X,d0
    move.b d0,d2
    moveq #0,d1
    move.b HEAD,d1
    lea HX0,a0
    move.b d2,0(a0,d1.w)
; HY[HEAD] = INPUT_Y
    move.b INPUT_Y,d0
    move.b d0,d2
    moveq #0,d1
    move.b HEAD,d1
    lea HY0,a0
    move.b d2,0(a0,d1.w)
; HEAD = HEAD + 1
    move.b HEAD,d0
    add.b #1,d0
    move.b d0,HEAD
; HEAD = HEAD & 7
    move.b HEAD,d0
    and.b #7,d0
    move.b d0,HEAD
; if COUNT < 8:
    move.b COUNT,d0
    cmp.b #8,d0
    bcs motion_history_L10
    jmp motion_history_L11
motion_history_L10:
; COUNT = COUNT + 1
    move.b COUNT,d0
    add.b #1,d0
    move.b d0,COUNT
    jmp motion_history_L12
motion_history_L11:
motion_history_L12:
    jmp motion_history_L9
motion_history_L8:
motion_history_L9:
; if LAG >= COUNT:
    move.b LAG,d0
    move.b COUNT,d1
    cmp.b d1,d0
    bcc motion_history_L13
    jmp motion_history_L14
motion_history_L13:
; return
    rts
    jmp motion_history_L15
motion_history_L14:
motion_history_L15:
; T0 = HEAD - 1
    move.b HEAD,d0
    sub.b #1,d0
    move.b d0,T0
; T0 = T0 - LAG
    move.b T0,d0
    move.b LAG,d1
    sub.b d1,d0
    move.b d0,T0
; T0 = T0 & 7
    move.b T0,d0
    and.b #7,d0
    move.b d0,T0
; OUT_X = HX[T0]
    moveq #0,d1
    move.b T0,d1
    lea HX0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,OUT_X
; OUT_Y = HY[T0]
    moveq #0,d1
    move.b T0,d1
    lea HY0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,OUT_Y
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
    rts
component_end:
