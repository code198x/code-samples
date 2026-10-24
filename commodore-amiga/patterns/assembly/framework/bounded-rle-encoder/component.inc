; SPDX-License-Identifier: MIT
; Encode a Small Run-length Block. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_rle_encoder_init:
    move.b #0,d0
    move.b d0,WRITTEN
    move.b d0,ERROR
    move.b d0,VALID
    move.b d0,INPUT_COUNT
    move.b d0,CAPACITY
    move.b d0,B0
    move.b d0,B1
    move.b d0,B2
    move.b d0,B3
    move.b d0,B4
    move.b d0,B5
    move.b d0,B6
    move.b d0,B7
    move.b d0,R0
    move.b d0,R1
    move.b d0,R2
    move.b d0,R3
    move.b d0,R4
    move.b d0,R5
    move.b d0,R6
    move.b d0,R7
    move.b d0,R8
    move.b d0,R9
    move.b d0,R10
    move.b d0,R11
    move.b d0,R12
    move.b d0,R13
    move.b d0,R14
    move.b d0,R15
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    move.b d0,T4
    move.b d0,EXPR_SAVE
    rts
bounded_rle_encoder_step:
; WRITTEN = 0
    move.b #0,d0
    move.b d0,WRITTEN
; ERROR = 1
    move.b #1,d0
    move.b d0,ERROR
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if INPUT_COUNT > 8:
    move.b INPUT_COUNT,d0
    cmp.b #8,d0
    bhi bounded_rle_encoder_L1
    jmp bounded_rle_encoder_L2
bounded_rle_encoder_L1:
; return
    rts
    jmp bounded_rle_encoder_L3
bounded_rle_encoder_L2:
bounded_rle_encoder_L3:
; if CAPACITY > 16:
    move.b CAPACITY,d0
    cmp.b #16,d0
    bhi bounded_rle_encoder_L4
    jmp bounded_rle_encoder_L5
bounded_rle_encoder_L4:
; return
    rts
    jmp bounded_rle_encoder_L6
bounded_rle_encoder_L5:
bounded_rle_encoder_L6:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; ERROR = 0
    move.b #0,d0
    move.b d0,ERROR
; if INPUT_COUNT == 0:
    move.b INPUT_COUNT,d0
    cmp.b #0,d0
    beq bounded_rle_encoder_L7
    jmp bounded_rle_encoder_L8
bounded_rle_encoder_L7:
; return
    rts
    jmp bounded_rle_encoder_L9
bounded_rle_encoder_L8:
bounded_rle_encoder_L9:
; T0 = 1
    move.b #1,d0
    move.b d0,T0
; T1 = B[0]
    moveq #0,d1
    move.b #0,d1
    lea B0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T1
; T2 = 1
    move.b #1,d0
    move.b d0,T2
; while T0 < INPUT_COUNT:
bounded_rle_encoder_L10:
    move.b T0,d0
    move.b INPUT_COUNT,d1
    cmp.b d1,d0
    bcs bounded_rle_encoder_L11
    jmp bounded_rle_encoder_L12
bounded_rle_encoder_L11:
; T3 = B[T0]
    moveq #0,d1
    move.b T0,d1
    lea B0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T3
; if T3 != T1:
    move.b T3,d0
    move.b T1,d1
    cmp.b d1,d0
    bne bounded_rle_encoder_L13
    jmp bounded_rle_encoder_L14
bounded_rle_encoder_L13:
; T2 = T2 + 1
    move.b T2,d0
    add.b #1,d0
    move.b d0,T2
; T1 = T3
    move.b T3,d0
    move.b d0,T1
    jmp bounded_rle_encoder_L15
bounded_rle_encoder_L14:
bounded_rle_encoder_L15:
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp bounded_rle_encoder_L10
bounded_rle_encoder_L12:
; T2 = T2 << 1
    move.b T2,d0
    lsl.b #1,d0
    move.b d0,T2
; if T2 > CAPACITY:
    move.b T2,d0
    move.b CAPACITY,d1
    cmp.b d1,d0
    bhi bounded_rle_encoder_L16
    jmp bounded_rle_encoder_L17
bounded_rle_encoder_L16:
; ERROR = 2
    move.b #2,d0
    move.b d0,ERROR
; return
    rts
    jmp bounded_rle_encoder_L18
bounded_rle_encoder_L17:
bounded_rle_encoder_L18:
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; T1 = 0
    move.b #0,d0
    move.b d0,T1
; while T0 < INPUT_COUNT:
bounded_rle_encoder_L19:
    move.b T0,d0
    move.b INPUT_COUNT,d1
    cmp.b d1,d0
    bcs bounded_rle_encoder_L20
    jmp bounded_rle_encoder_L21
bounded_rle_encoder_L20:
; T2 = B[T0]
    moveq #0,d1
    move.b T0,d1
    lea B0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T2
; T3 = 1
    move.b #1,d0
    move.b d0,T3
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
; while T0 < INPUT_COUNT:
bounded_rle_encoder_L22:
    move.b T0,d0
    move.b INPUT_COUNT,d1
    cmp.b d1,d0
    bcs bounded_rle_encoder_L23
    jmp bounded_rle_encoder_L24
bounded_rle_encoder_L23:
; T4 = B[T0]
    moveq #0,d1
    move.b T0,d1
    lea B0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T4
; if T4 != T2:
    move.b T4,d0
    move.b T2,d1
    cmp.b d1,d0
    bne bounded_rle_encoder_L25
    jmp bounded_rle_encoder_L26
bounded_rle_encoder_L25:
; break
    jmp bounded_rle_encoder_L24
    jmp bounded_rle_encoder_L27
bounded_rle_encoder_L26:
bounded_rle_encoder_L27:
; T3 = T3 + 1
    move.b T3,d0
    add.b #1,d0
    move.b d0,T3
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp bounded_rle_encoder_L22
bounded_rle_encoder_L24:
; R[T1] = T3
    move.b T3,d0
    move.b d0,d2
    moveq #0,d1
    move.b T1,d1
    lea R0,a0
    move.b d2,0(a0,d1.w)
; T1 = T1 + 1
    move.b T1,d0
    add.b #1,d0
    move.b d0,T1
; R[T1] = T2
    move.b T2,d0
    move.b d0,d2
    moveq #0,d1
    move.b T1,d1
    lea R0,a0
    move.b d2,0(a0,d1.w)
; T1 = T1 + 1
    move.b T1,d0
    add.b #1,d0
    move.b d0,T1
    jmp bounded_rle_encoder_L19
bounded_rle_encoder_L21:
; WRITTEN = T1
    move.b T1,d0
    move.b d0,WRITTEN
    rts
component_end:
