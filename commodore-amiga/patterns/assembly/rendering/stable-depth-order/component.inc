; SPDX-License-Identifier: MIT
; Sort a Small Draw Order Stably. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
stable_depth_order_init:
    move.b #0,d0
    move.b d0,COUNT
    move.b d0,VALID
    move.b d0,Z0
    move.b d0,Z1
    move.b d0,Z2
    move.b d0,Z3
    move.b d0,Z4
    move.b d0,Z5
    move.b d0,Z6
    move.b d0,Z7
    move.b d0,I0
    move.b d0,I1
    move.b d0,I2
    move.b d0,I3
    move.b d0,I4
    move.b d0,I5
    move.b d0,I6
    move.b d0,I7
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    move.b d0,T4
    move.b d0,T5
    move.b d0,T6
    move.b d0,EXPR_SAVE
    rts
stable_depth_order_step:
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if COUNT > 8:
    move.b COUNT,d0
    cmp.b #8,d0
    bhi stable_depth_order_L1
    jmp stable_depth_order_L2
stable_depth_order_L1:
; return
    rts
    jmp stable_depth_order_L3
stable_depth_order_L2:
stable_depth_order_L3:
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; while T0 < 8:
stable_depth_order_L4:
    move.b T0,d0
    cmp.b #8,d0
    bcs stable_depth_order_L5
    jmp stable_depth_order_L6
stable_depth_order_L5:
; I[T0] = T0
    move.b T0,d0
    move.b d0,d2
    moveq #0,d1
    move.b T0,d1
    lea I0,a0
    move.b d2,0(a0,d1.w)
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp stable_depth_order_L4
stable_depth_order_L6:
; T0 = 1
    move.b #1,d0
    move.b d0,T0
; while T0 < COUNT:
stable_depth_order_L7:
    move.b T0,d0
    move.b COUNT,d1
    cmp.b d1,d0
    bcs stable_depth_order_L8
    jmp stable_depth_order_L9
stable_depth_order_L8:
; T1 = I[T0]
    moveq #0,d1
    move.b T0,d1
    lea I0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T1
; T2 = Z[T1]
    moveq #0,d1
    move.b T1,d1
    lea Z0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T2
; T3 = T0
    move.b T0,d0
    move.b d0,T3
; while T3 != 0:
stable_depth_order_L10:
    move.b T3,d0
    cmp.b #0,d0
    bne stable_depth_order_L11
    jmp stable_depth_order_L12
stable_depth_order_L11:
; T4 = T3 - 1
    move.b T3,d0
    sub.b #1,d0
    move.b d0,T4
; T5 = I[T4]
    moveq #0,d1
    move.b T4,d1
    lea I0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T5
; T6 = Z[T5]
    moveq #0,d1
    move.b T5,d1
    lea Z0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T6
; if T6 <= T2:
    move.b T6,d0
    move.b T2,d1
    cmp.b d1,d0
    bls stable_depth_order_L13
    jmp stable_depth_order_L14
stable_depth_order_L13:
; break
    jmp stable_depth_order_L12
    jmp stable_depth_order_L15
stable_depth_order_L14:
stable_depth_order_L15:
; I[T3] = T5
    move.b T5,d0
    move.b d0,d2
    moveq #0,d1
    move.b T3,d1
    lea I0,a0
    move.b d2,0(a0,d1.w)
; T3 = T3 - 1
    move.b T3,d0
    sub.b #1,d0
    move.b d0,T3
    jmp stable_depth_order_L10
stable_depth_order_L12:
; I[T3] = T1
    move.b T1,d0
    move.b d0,d2
    moveq #0,d1
    move.b T3,d1
    lea I0,a0
    move.b d2,0(a0,d1.w)
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp stable_depth_order_L7
stable_depth_order_L9:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
    rts
component_end:
