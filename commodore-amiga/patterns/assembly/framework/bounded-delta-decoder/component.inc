; SPDX-License-Identifier: MIT
; Decode Bounded Byte Deltas. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_delta_decoder_init:
    move.b #0,d0
    move.b d0,WRITTEN
    move.b d0,VALID
    move.b d0,COUNT
    move.b d0,BASE
    move.b d0,Q0
    move.b d0,Q1
    move.b d0,Q2
    move.b d0,Q3
    move.b d0,Q4
    move.b d0,Q5
    move.b d0,Q6
    move.b d0,Q7
    move.b d0,R0
    move.b d0,R1
    move.b d0,R2
    move.b d0,R3
    move.b d0,R4
    move.b d0,R5
    move.b d0,R6
    move.b d0,R7
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,EXPR_SAVE
    rts
bounded_delta_decoder_step:
; WRITTEN = 0
    move.b #0,d0
    move.b d0,WRITTEN
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if COUNT > 8:
    move.b COUNT,d0
    cmp.b #8,d0
    bhi bounded_delta_decoder_L1
    jmp bounded_delta_decoder_L2
bounded_delta_decoder_L1:
; return
    rts
    jmp bounded_delta_decoder_L3
bounded_delta_decoder_L2:
bounded_delta_decoder_L3:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = BASE
    move.b BASE,d0
    move.b d0,T0
; T1 = 0
    move.b #0,d0
    move.b d0,T1
; while T1 < COUNT:
bounded_delta_decoder_L4:
    move.b T1,d0
    move.b COUNT,d1
    cmp.b d1,d0
    bcs bounded_delta_decoder_L5
    jmp bounded_delta_decoder_L6
bounded_delta_decoder_L5:
; T2 = Q[T1]
    moveq #0,d1
    move.b T1,d1
    lea Q0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T2
; T0 = T0 + T2
    move.b T0,d0
    move.b T2,d1
    add.b d1,d0
    move.b d0,T0
; R[T1] = T0
    move.b T0,d0
    move.b d0,d2
    moveq #0,d1
    move.b T1,d1
    lea R0,a0
    move.b d2,0(a0,d1.w)
; T1 = T1 + 1
    move.b T1,d0
    add.b #1,d0
    move.b d0,T1
    jmp bounded_delta_decoder_L4
bounded_delta_decoder_L6:
; WRITTEN = COUNT
    move.b COUNT,d0
    move.b d0,WRITTEN
    rts
component_end:
