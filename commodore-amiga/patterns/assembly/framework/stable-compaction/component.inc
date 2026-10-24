; SPDX-License-Identifier: MIT
; Compact a Live Object Prefix. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
stable_compaction_init:
    move.b #0,d0
    move.b d0,COUNT
    move.b d0,REMOVED
    move.b d0,VALID
    move.b d0,F0
    move.b d0,F1
    move.b d0,F2
    move.b d0,F3
    move.b d0,F4
    move.b d0,F5
    move.b d0,F6
    move.b d0,F7
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
    move.b d0,EXPR_SAVE
    rts
stable_compaction_step:
; REMOVED = 0
    move.b #0,d0
    move.b d0,REMOVED
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if COUNT > 8:
    move.b COUNT,d0
    cmp.b #8,d0
    bhi stable_compaction_L1
    jmp stable_compaction_L2
stable_compaction_L1:
; return
    rts
    jmp stable_compaction_L3
stable_compaction_L2:
stable_compaction_L3:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; T1 = 0
    move.b #0,d0
    move.b d0,T1
; T4 = COUNT
    move.b COUNT,d0
    move.b d0,T4
; while T0 < T4:
stable_compaction_L4:
    move.b T0,d0
    move.b T4,d1
    cmp.b d1,d0
    bcs stable_compaction_L5
    jmp stable_compaction_L6
stable_compaction_L5:
; T2 = F[T0]
    moveq #0,d1
    move.b T0,d1
    lea F0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T2
; if T2 != 0:
    move.b T2,d0
    cmp.b #0,d0
    bne stable_compaction_L7
    jmp stable_compaction_L8
stable_compaction_L7:
; T3 = I[T0]
    moveq #0,d1
    move.b T0,d1
    lea I0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T3
; F[T1] = T2
    move.b T2,d0
    move.b d0,d2
    moveq #0,d1
    move.b T1,d1
    lea F0,a0
    move.b d2,0(a0,d1.w)
; I[T1] = T3
    move.b T3,d0
    move.b d0,d2
    moveq #0,d1
    move.b T1,d1
    lea I0,a0
    move.b d2,0(a0,d1.w)
; T1 = T1 + 1
    move.b T1,d0
    add.b #1,d0
    move.b d0,T1
    jmp stable_compaction_L9
stable_compaction_L8:
stable_compaction_L9:
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp stable_compaction_L4
stable_compaction_L6:
; COUNT = T1
    move.b T1,d0
    move.b d0,COUNT
; REMOVED = T4 - T1
    move.b T4,d0
    move.b T1,d1
    sub.b d1,d0
    move.b d0,REMOVED
; while T1 < T4:
stable_compaction_L10:
    move.b T1,d0
    move.b T4,d1
    cmp.b d1,d0
    bcs stable_compaction_L11
    jmp stable_compaction_L12
stable_compaction_L11:
; F[T1] = 0
    move.b #0,d0
    move.b d0,d2
    moveq #0,d1
    move.b T1,d1
    lea F0,a0
    move.b d2,0(a0,d1.w)
; I[T1] = 0
    move.b #0,d0
    move.b d0,d2
    moveq #0,d1
    move.b T1,d1
    lea I0,a0
    move.b d2,0(a0,d1.w)
; T1 = T1 + 1
    move.b T1,d0
    add.b #1,d0
    move.b d0,T1
    jmp stable_compaction_L10
stable_compaction_L12:
    rts
component_end:
