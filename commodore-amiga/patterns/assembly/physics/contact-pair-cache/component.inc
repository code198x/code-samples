; SPDX-License-Identifier: MIT
; Remember Contact Pairs for a Step. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
contact_pair_cache_init:
    move.b #0,d0
    move.b d0,FIRST
    move.b d0,VALID
    move.b d0,MODE
    move.b d0,OBJECT_A
    move.b d0,OBJECT_B
    move.b d0,B0
    move.b d0,B1
    move.b d0,B2
    move.b d0,B3
    move.b d0,B4
    move.b d0,B5
    move.b d0,B6
    move.b d0,B7
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    move.b d0,T4
    move.b d0,EXPR_SAVE
    rts
contact_pair_cache_step:
; FIRST = 0
    move.b #0,d0
    move.b d0,FIRST
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if MODE > 2:
    move.b MODE,d0
    cmp.b #2,d0
    bhi contact_pair_cache_L1
    jmp contact_pair_cache_L2
contact_pair_cache_L1:
; return
    rts
    jmp contact_pair_cache_L3
contact_pair_cache_L2:
contact_pair_cache_L3:
; if MODE == 0:
    move.b MODE,d0
    cmp.b #0,d0
    beq contact_pair_cache_L4
    jmp contact_pair_cache_L5
contact_pair_cache_L4:
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; while T0 < 8:
contact_pair_cache_L7:
    move.b T0,d0
    cmp.b #8,d0
    bcs contact_pair_cache_L8
    jmp contact_pair_cache_L9
contact_pair_cache_L8:
; B[T0] = 0
    move.b #0,d0
    move.b d0,d2
    moveq #0,d1
    move.b T0,d1
    lea B0,a0
    move.b d2,0(a0,d1.w)
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp contact_pair_cache_L7
contact_pair_cache_L9:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; return
    rts
    jmp contact_pair_cache_L6
contact_pair_cache_L5:
contact_pair_cache_L6:
; if OBJECT_A >= 8:
    move.b OBJECT_A,d0
    cmp.b #8,d0
    bcc contact_pair_cache_L10
    jmp contact_pair_cache_L11
contact_pair_cache_L10:
; return
    rts
    jmp contact_pair_cache_L12
contact_pair_cache_L11:
contact_pair_cache_L12:
; if OBJECT_B >= 8:
    move.b OBJECT_B,d0
    cmp.b #8,d0
    bcc contact_pair_cache_L13
    jmp contact_pair_cache_L14
contact_pair_cache_L13:
; return
    rts
    jmp contact_pair_cache_L15
contact_pair_cache_L14:
contact_pair_cache_L15:
; if OBJECT_A == OBJECT_B:
    move.b OBJECT_A,d0
    move.b OBJECT_B,d1
    cmp.b d1,d0
    beq contact_pair_cache_L16
    jmp contact_pair_cache_L17
contact_pair_cache_L16:
; return
    rts
    jmp contact_pair_cache_L18
contact_pair_cache_L17:
contact_pair_cache_L18:
; T0 = OBJECT_A
    move.b OBJECT_A,d0
    move.b d0,T0
; T1 = OBJECT_B
    move.b OBJECT_B,d0
    move.b d0,T1
; if T0 > T1:
    move.b T0,d0
    move.b T1,d1
    cmp.b d1,d0
    bhi contact_pair_cache_L19
    jmp contact_pair_cache_L20
contact_pair_cache_L19:
; T0 = OBJECT_B
    move.b OBJECT_B,d0
    move.b d0,T0
; T1 = OBJECT_A
    move.b OBJECT_A,d0
    move.b d0,T1
    jmp contact_pair_cache_L21
contact_pair_cache_L20:
contact_pair_cache_L21:
; T2 = 1
    move.b #1,d0
    move.b d0,T2
; while T1 != 0:
contact_pair_cache_L22:
    move.b T1,d0
    cmp.b #0,d0
    bne contact_pair_cache_L23
    jmp contact_pair_cache_L24
contact_pair_cache_L23:
; T2 = T2 << 1
    move.b T2,d0
    lsl.b #1,d0
    move.b d0,T2
; T1 = T1 - 1
    move.b T1,d0
    sub.b #1,d0
    move.b d0,T1
    jmp contact_pair_cache_L22
contact_pair_cache_L24:
; T3 = B[T0]
    moveq #0,d1
    move.b T0,d1
    lea B0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T3
; T4 = T3 & T2
    move.b T3,d0
    move.b T2,d1
    and.b d1,d0
    move.b d0,T4
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if T4 == 0:
    move.b T4,d0
    cmp.b #0,d0
    beq contact_pair_cache_L25
    jmp contact_pair_cache_L26
contact_pair_cache_L25:
; FIRST = 1
    move.b #1,d0
    move.b d0,FIRST
; if MODE == 1:
    move.b MODE,d0
    cmp.b #1,d0
    beq contact_pair_cache_L28
    jmp contact_pair_cache_L29
contact_pair_cache_L28:
; T3 = T3 | T2
    move.b T3,d0
    move.b T2,d1
    or.b d1,d0
    move.b d0,T3
; B[T0] = T3
    move.b T3,d0
    move.b d0,d2
    moveq #0,d1
    move.b T0,d1
    lea B0,a0
    move.b d2,0(a0,d1.w)
    jmp contact_pair_cache_L30
contact_pair_cache_L29:
contact_pair_cache_L30:
    jmp contact_pair_cache_L27
contact_pair_cache_L26:
contact_pair_cache_L27:
    rts
component_end:
