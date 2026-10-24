; SPDX-License-Identifier: MIT
; Select the Nearest Active Target. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
nearest_target_init:
    move.b #0,d0
    move.b d0,SLOT
    move.b d0,DISTANCE_LO
    move.b d0,DISTANCE_HI
    move.b d0,FOUND
    move.b d0,ACTIVE
    move.b d0,ORIGIN_X
    move.b d0,ORIGIN_Y
    move.b d0,PX0
    move.b d0,PX1
    move.b d0,PX2
    move.b d0,PX3
    move.b d0,PY0
    move.b d0,PY1
    move.b d0,PY2
    move.b d0,PY3
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    move.b d0,T4
    move.b d0,T5
    move.b d0,T6
    move.b d0,T7
    rts
nearest_target_step:
; SLOT = 255
    move.b #255,d0
    move.b d0,SLOT
; DISTANCE_LO = 0
    move.b #0,d0
    move.b d0,DISTANCE_LO
; DISTANCE_HI = 0
    move.b #0,d0
    move.b d0,DISTANCE_HI
; FOUND = 0
    move.b #0,d0
    move.b d0,FOUND
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; T1 = 1
    move.b #1,d0
    move.b d0,T1
; while T0 < 4:
nearest_target_L1:
    move.b T0,d0
    cmp.b #4,d0
    bcs nearest_target_L2
    jmp nearest_target_L3
nearest_target_L2:
; T2 = ACTIVE & T1
    move.b ACTIVE,d0
    move.b T1,d1
    and.b d1,d0
    move.b d0,T2
; if T2 != 0:
    move.b T2,d0
    cmp.b #0,d0
    bne nearest_target_L4
    jmp nearest_target_L5
nearest_target_L4:
; T2 = PX[T0]
    moveq #0,d1
    move.b T0,d1
    lea PX0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T2
; if T2 >= ORIGIN_X:
    move.b T2,d0
    move.b ORIGIN_X,d1
    cmp.b d1,d0
    bcc nearest_target_L7
    jmp nearest_target_L8
nearest_target_L7:
; T3 = T2 - ORIGIN_X
    move.b T2,d0
    move.b ORIGIN_X,d1
    sub.b d1,d0
    move.b d0,T3
    jmp nearest_target_L9
nearest_target_L8:
; T3 = ORIGIN_X - T2
    move.b ORIGIN_X,d0
    move.b T2,d1
    sub.b d1,d0
    move.b d0,T3
nearest_target_L9:
; T2 = PY[T0]
    moveq #0,d1
    move.b T0,d1
    lea PY0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T2
; if T2 >= ORIGIN_Y:
    move.b T2,d0
    move.b ORIGIN_Y,d1
    cmp.b d1,d0
    bcc nearest_target_L10
    jmp nearest_target_L11
nearest_target_L10:
; T4 = T2 - ORIGIN_Y
    move.b T2,d0
    move.b ORIGIN_Y,d1
    sub.b d1,d0
    move.b d0,T4
    jmp nearest_target_L12
nearest_target_L11:
; T4 = ORIGIN_Y - T2
    move.b ORIGIN_Y,d0
    move.b T2,d1
    sub.b d1,d0
    move.b d0,T4
nearest_target_L12:
; T5 = T3 + T4
    move.b T3,d0
    move.b T4,d1
    add.b d1,d0
    move.b d0,T5
; T6 = 0
    move.b #0,d0
    move.b d0,T6
; if T5 < T3:
    move.b T5,d0
    move.b T3,d1
    cmp.b d1,d0
    bcs nearest_target_L13
    jmp nearest_target_L14
nearest_target_L13:
; T6 = 1
    move.b #1,d0
    move.b d0,T6
    jmp nearest_target_L15
nearest_target_L14:
nearest_target_L15:
; T7 = 0
    move.b #0,d0
    move.b d0,T7
; if FOUND == 0:
    move.b FOUND,d0
    cmp.b #0,d0
    beq nearest_target_L16
    jmp nearest_target_L17
nearest_target_L16:
; T7 = 1
    move.b #1,d0
    move.b d0,T7
    jmp nearest_target_L18
nearest_target_L17:
nearest_target_L18:
; if T6 < DISTANCE_HI:
    move.b T6,d0
    move.b DISTANCE_HI,d1
    cmp.b d1,d0
    bcs nearest_target_L19
    jmp nearest_target_L20
nearest_target_L19:
; T7 = 1
    move.b #1,d0
    move.b d0,T7
    jmp nearest_target_L21
nearest_target_L20:
nearest_target_L21:
; if T6 == DISTANCE_HI:
    move.b T6,d0
    move.b DISTANCE_HI,d1
    cmp.b d1,d0
    beq nearest_target_L22
    jmp nearest_target_L23
nearest_target_L22:
; if T5 < DISTANCE_LO:
    move.b T5,d0
    move.b DISTANCE_LO,d1
    cmp.b d1,d0
    bcs nearest_target_L25
    jmp nearest_target_L26
nearest_target_L25:
; T7 = 1
    move.b #1,d0
    move.b d0,T7
    jmp nearest_target_L27
nearest_target_L26:
nearest_target_L27:
    jmp nearest_target_L24
nearest_target_L23:
nearest_target_L24:
; if T7 != 0:
    move.b T7,d0
    cmp.b #0,d0
    bne nearest_target_L28
    jmp nearest_target_L29
nearest_target_L28:
; SLOT = T0
    move.b T0,d0
    move.b d0,SLOT
; DISTANCE_LO = T5
    move.b T5,d0
    move.b d0,DISTANCE_LO
; DISTANCE_HI = T6
    move.b T6,d0
    move.b d0,DISTANCE_HI
; FOUND = 1
    move.b #1,d0
    move.b d0,FOUND
    jmp nearest_target_L30
nearest_target_L29:
nearest_target_L30:
    jmp nearest_target_L6
nearest_target_L5:
nearest_target_L6:
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
; T1 = T1 << 1
    move.b T1,d0
    lsl.b #1,d0
    move.b d0,T1
    jmp nearest_target_L1
nearest_target_L3:
    rts
component_end:
