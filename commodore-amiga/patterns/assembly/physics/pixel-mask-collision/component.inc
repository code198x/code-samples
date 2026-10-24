; SPDX-License-Identifier: MIT
; Test Two Small Opaque Pixel Masks. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
pixel_mask_collision_init:
    move.b #0,d0
    move.b d0,HIT
    move.b d0,ROW
    move.b d0,SHIFT_X
    move.b d0,SHIFT_Y
    move.b d0,P0
    move.b d0,P1
    move.b d0,P2
    move.b d0,P3
    move.b d0,P4
    move.b d0,P5
    move.b d0,P6
    move.b d0,P7
    move.b d0,Q0
    move.b d0,Q1
    move.b d0,Q2
    move.b d0,Q3
    move.b d0,Q4
    move.b d0,Q5
    move.b d0,Q6
    move.b d0,Q7
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    move.b d0,T4
    move.b d0,T5
    rts
pixel_mask_collision_step:
; HIT = 0
    move.b #0,d0
    move.b d0,HIT
; ROW = 255
    move.b #255,d0
    move.b d0,ROW
; if SHIFT_X >= 8:
    move.b SHIFT_X,d0
    cmp.b #8,d0
    bcc pixel_mask_collision_L1
    jmp pixel_mask_collision_L2
pixel_mask_collision_L1:
; return
    rts
    jmp pixel_mask_collision_L3
pixel_mask_collision_L2:
pixel_mask_collision_L3:
; if SHIFT_Y >= 8:
    move.b SHIFT_Y,d0
    cmp.b #8,d0
    bcc pixel_mask_collision_L4
    jmp pixel_mask_collision_L5
pixel_mask_collision_L4:
; return
    rts
    jmp pixel_mask_collision_L6
pixel_mask_collision_L5:
pixel_mask_collision_L6:
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; T5 = 8 - SHIFT_Y
    move.b #8,d0
    move.b SHIFT_Y,d1
    sub.b d1,d0
    move.b d0,T5
; while T0 < T5:
pixel_mask_collision_L7:
    move.b T0,d0
    move.b T5,d1
    cmp.b d1,d0
    bcs pixel_mask_collision_L8
    jmp pixel_mask_collision_L9
pixel_mask_collision_L8:
; T1 = Q[T0]
    moveq #0,d1
    move.b T0,d1
    lea Q0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T1
; T2 = SHIFT_X
    move.b SHIFT_X,d0
    move.b d0,T2
; while T2 != 0:
pixel_mask_collision_L10:
    move.b T2,d0
    cmp.b #0,d0
    bne pixel_mask_collision_L11
    jmp pixel_mask_collision_L12
pixel_mask_collision_L11:
; T1 = T1 >> 1
    move.b T1,d0
    lsr.b #1,d0
    move.b d0,T1
; T2 = T2 - 1
    move.b T2,d0
    sub.b #1,d0
    move.b d0,T2
    jmp pixel_mask_collision_L10
pixel_mask_collision_L12:
; T3 = T0 + SHIFT_Y
    move.b T0,d0
    move.b SHIFT_Y,d1
    add.b d1,d0
    move.b d0,T3
; T4 = P[T3]
    moveq #0,d1
    move.b T3,d1
    lea P0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T4
; T4 = T4 & T1
    move.b T4,d0
    move.b T1,d1
    and.b d1,d0
    move.b d0,T4
; if T4 != 0:
    move.b T4,d0
    cmp.b #0,d0
    bne pixel_mask_collision_L13
    jmp pixel_mask_collision_L14
pixel_mask_collision_L13:
; HIT = 1
    move.b #1,d0
    move.b d0,HIT
; ROW = T3
    move.b T3,d0
    move.b d0,ROW
; return
    rts
    jmp pixel_mask_collision_L15
pixel_mask_collision_L14:
pixel_mask_collision_L15:
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp pixel_mask_collision_L7
pixel_mask_collision_L9:
    rts
component_end:
