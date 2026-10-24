; SPDX-License-Identifier: MIT
; Insert into a High-score Table. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
high_score_insertion_init:
    move.b #0,d0
    move.b d0,RANK
    move.b d0,INSERTED
    move.b d0,VALID
    move.b d0,SCORE
    move.b d0,TAG
    move.b d0,COUNT
    move.b d0,S0
    move.b d0,S1
    move.b d0,S2
    move.b d0,S3
    move.b d0,I0
    move.b d0,I1
    move.b d0,I2
    move.b d0,I3
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    move.b d0,EXPR_SAVE
    rts
high_score_insertion_step:
; RANK = 255
    move.b #255,d0
    move.b d0,RANK
; INSERTED = 0
    move.b #0,d0
    move.b d0,INSERTED
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if COUNT > 4:
    move.b COUNT,d0
    cmp.b #4,d0
    bhi high_score_insertion_L1
    jmp high_score_insertion_L2
high_score_insertion_L1:
; return
    rts
    jmp high_score_insertion_L3
high_score_insertion_L2:
high_score_insertion_L3:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; while T0 < COUNT:
high_score_insertion_L4:
    move.b T0,d0
    move.b COUNT,d1
    cmp.b d1,d0
    bcs high_score_insertion_L5
    jmp high_score_insertion_L6
high_score_insertion_L5:
; T1 = S[T0]
    moveq #0,d1
    move.b T0,d1
    lea S0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T1
; if SCORE > T1:
    move.b SCORE,d0
    move.b T1,d1
    cmp.b d1,d0
    bhi high_score_insertion_L7
    jmp high_score_insertion_L8
high_score_insertion_L7:
; break
    jmp high_score_insertion_L6
    jmp high_score_insertion_L9
high_score_insertion_L8:
high_score_insertion_L9:
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp high_score_insertion_L4
high_score_insertion_L6:
; if T0 >= 4:
    move.b T0,d0
    cmp.b #4,d0
    bcc high_score_insertion_L10
    jmp high_score_insertion_L11
high_score_insertion_L10:
; return
    rts
    jmp high_score_insertion_L12
high_score_insertion_L11:
high_score_insertion_L12:
; RANK = T0
    move.b T0,d0
    move.b d0,RANK
; if COUNT < 4:
    move.b COUNT,d0
    cmp.b #4,d0
    bcs high_score_insertion_L13
    jmp high_score_insertion_L14
high_score_insertion_L13:
; COUNT = COUNT + 1
    move.b COUNT,d0
    add.b #1,d0
    move.b d0,COUNT
    jmp high_score_insertion_L15
high_score_insertion_L14:
high_score_insertion_L15:
; T1 = COUNT - 1
    move.b COUNT,d0
    sub.b #1,d0
    move.b d0,T1
; while T1 > T0:
high_score_insertion_L16:
    move.b T1,d0
    move.b T0,d1
    cmp.b d1,d0
    bhi high_score_insertion_L17
    jmp high_score_insertion_L18
high_score_insertion_L17:
; T2 = T1 - 1
    move.b T1,d0
    sub.b #1,d0
    move.b d0,T2
; T3 = S[T2]
    moveq #0,d1
    move.b T2,d1
    lea S0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T3
; S[T1] = T3
    move.b T3,d0
    move.b d0,d2
    moveq #0,d1
    move.b T1,d1
    lea S0,a0
    move.b d2,0(a0,d1.w)
; T3 = I[T2]
    moveq #0,d1
    move.b T2,d1
    lea I0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T3
; I[T1] = T3
    move.b T3,d0
    move.b d0,d2
    moveq #0,d1
    move.b T1,d1
    lea I0,a0
    move.b d2,0(a0,d1.w)
; T1 = T1 - 1
    move.b T1,d0
    sub.b #1,d0
    move.b d0,T1
    jmp high_score_insertion_L16
high_score_insertion_L18:
; S[T0] = SCORE
    move.b SCORE,d0
    move.b d0,d2
    moveq #0,d1
    move.b T0,d1
    lea S0,a0
    move.b d2,0(a0,d1.w)
; I[T0] = TAG
    move.b TAG,d0
    move.b d0,d2
    moveq #0,d1
    move.b T0,d1
    lea I0,a0
    move.b d2,0(a0,d1.w)
; INSERTED = 1
    move.b #1,d0
    move.b d0,INSERTED
    rts
component_end:
