; SPDX-License-Identifier: MIT
; Fill a Connected Grid Region. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_flood_fill_init:
    move.b #0,d0
    move.b d0,SEED
    move.b d0,REPLACEMENT
    move.b d0,CHANGED
    move.b d0,VALID
    move.b d0,C0
    move.b d0,C1
    move.b d0,C2
    move.b d0,C3
    move.b d0,C4
    move.b d0,C5
    move.b d0,C6
    move.b d0,C7
    move.b d0,C8
    move.b d0,C9
    move.b d0,C10
    move.b d0,C11
    move.b d0,C12
    move.b d0,C13
    move.b d0,C14
    move.b d0,C15
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    move.b d0,T4
    move.b d0,T5
    move.b d0,T6
    move.b d0,T7
    move.b d0,EXPR_SAVE
    move.b d0,V0
    move.b d0,V1
    move.b d0,V2
    move.b d0,V3
    move.b d0,V4
    move.b d0,V5
    move.b d0,V6
    move.b d0,V7
    move.b d0,V8
    move.b d0,V9
    move.b d0,V10
    move.b d0,V11
    move.b d0,V12
    move.b d0,V13
    move.b d0,V14
    move.b d0,V15
    rts
bounded_flood_fill_step:
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; CHANGED = 0
    move.b #0,d0
    move.b d0,CHANGED
; if SEED >= 16:
    move.b SEED,d0
    cmp.b #16,d0
    bcc bounded_flood_fill_L1
    jmp bounded_flood_fill_L2
bounded_flood_fill_L1:
; return
    rts
    jmp bounded_flood_fill_L3
bounded_flood_fill_L2:
bounded_flood_fill_L3:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = C[SEED]
    moveq #0,d1
    move.b SEED,d1
    lea C0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T0
; if T0 == REPLACEMENT:
    move.b T0,d0
    move.b REPLACEMENT,d1
    cmp.b d1,d0
    beq bounded_flood_fill_L4
    jmp bounded_flood_fill_L5
bounded_flood_fill_L4:
; return
    rts
    jmp bounded_flood_fill_L6
bounded_flood_fill_L5:
bounded_flood_fill_L6:
; T1 = 0
    move.b #0,d0
    move.b d0,T1
; while T1 < 16:
bounded_flood_fill_L7:
    move.b T1,d0
    cmp.b #16,d0
    bcs bounded_flood_fill_L8
    jmp bounded_flood_fill_L9
bounded_flood_fill_L8:
; V[T1] = 0
    move.b #0,d0
    move.b d0,d2
    moveq #0,d1
    move.b T1,d1
    lea V0,a0
    move.b d2,0(a0,d1.w)
; T1 = T1 + 1
    move.b T1,d0
    add.b #1,d0
    move.b d0,T1
    jmp bounded_flood_fill_L7
bounded_flood_fill_L9:
; V[SEED] = 1
    move.b #1,d0
    move.b d0,d2
    moveq #0,d1
    move.b SEED,d1
    lea V0,a0
    move.b d2,0(a0,d1.w)
; T2 = 1
    move.b #1,d0
    move.b d0,T2
; while T2 != 0:
bounded_flood_fill_L10:
    move.b T2,d0
    cmp.b #0,d0
    bne bounded_flood_fill_L11
    jmp bounded_flood_fill_L12
bounded_flood_fill_L11:
; T2 = 0
    move.b #0,d0
    move.b d0,T2
; T1 = 0
    move.b #0,d0
    move.b d0,T1
; while T1 < 16:
bounded_flood_fill_L13:
    move.b T1,d0
    cmp.b #16,d0
    bcs bounded_flood_fill_L14
    jmp bounded_flood_fill_L15
bounded_flood_fill_L14:
; T3 = V[T1]
    moveq #0,d1
    move.b T1,d1
    lea V0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T3
; if T3 == 0:
    move.b T3,d0
    cmp.b #0,d0
    beq bounded_flood_fill_L16
    jmp bounded_flood_fill_L17
bounded_flood_fill_L16:
; T3 = C[T1]
    moveq #0,d1
    move.b T1,d1
    lea C0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T3
; if T3 == T0:
    move.b T3,d0
    move.b T0,d1
    cmp.b d1,d0
    beq bounded_flood_fill_L19
    jmp bounded_flood_fill_L20
bounded_flood_fill_L19:
; T4 = 0
    move.b #0,d0
    move.b d0,T4
; T5 = T1 & 3
    move.b T1,d0
    and.b #3,d0
    move.b d0,T5
; if T5 != 0:
    move.b T5,d0
    cmp.b #0,d0
    bne bounded_flood_fill_L22
    jmp bounded_flood_fill_L23
bounded_flood_fill_L22:
; T6 = T1 - 1
    move.b T1,d0
    sub.b #1,d0
    move.b d0,T6
; T4 = V[T6]
    moveq #0,d1
    move.b T6,d1
    lea V0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T4
    jmp bounded_flood_fill_L24
bounded_flood_fill_L23:
bounded_flood_fill_L24:
; if T5 != 3:
    move.b T5,d0
    cmp.b #3,d0
    bne bounded_flood_fill_L25
    jmp bounded_flood_fill_L26
bounded_flood_fill_L25:
; T6 = T1 + 1
    move.b T1,d0
    add.b #1,d0
    move.b d0,T6
; T7 = V[T6]
    moveq #0,d1
    move.b T6,d1
    lea V0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T7
; T4 = T4 | T7
    move.b T4,d0
    move.b T7,d1
    or.b d1,d0
    move.b d0,T4
    jmp bounded_flood_fill_L27
bounded_flood_fill_L26:
bounded_flood_fill_L27:
; if T1 >= 4:
    move.b T1,d0
    cmp.b #4,d0
    bcc bounded_flood_fill_L28
    jmp bounded_flood_fill_L29
bounded_flood_fill_L28:
; T6 = T1 - 4
    move.b T1,d0
    sub.b #4,d0
    move.b d0,T6
; T7 = V[T6]
    moveq #0,d1
    move.b T6,d1
    lea V0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T7
; T4 = T4 | T7
    move.b T4,d0
    move.b T7,d1
    or.b d1,d0
    move.b d0,T4
    jmp bounded_flood_fill_L30
bounded_flood_fill_L29:
bounded_flood_fill_L30:
; if T1 < 12:
    move.b T1,d0
    cmp.b #12,d0
    bcs bounded_flood_fill_L31
    jmp bounded_flood_fill_L32
bounded_flood_fill_L31:
; T6 = T1 + 4
    move.b T1,d0
    add.b #4,d0
    move.b d0,T6
; T7 = V[T6]
    moveq #0,d1
    move.b T6,d1
    lea V0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T7
; T4 = T4 | T7
    move.b T4,d0
    move.b T7,d1
    or.b d1,d0
    move.b d0,T4
    jmp bounded_flood_fill_L33
bounded_flood_fill_L32:
bounded_flood_fill_L33:
; if T4 != 0:
    move.b T4,d0
    cmp.b #0,d0
    bne bounded_flood_fill_L34
    jmp bounded_flood_fill_L35
bounded_flood_fill_L34:
; V[T1] = 1
    move.b #1,d0
    move.b d0,d2
    moveq #0,d1
    move.b T1,d1
    lea V0,a0
    move.b d2,0(a0,d1.w)
; T2 = 1
    move.b #1,d0
    move.b d0,T2
    jmp bounded_flood_fill_L36
bounded_flood_fill_L35:
bounded_flood_fill_L36:
    jmp bounded_flood_fill_L21
bounded_flood_fill_L20:
bounded_flood_fill_L21:
    jmp bounded_flood_fill_L18
bounded_flood_fill_L17:
bounded_flood_fill_L18:
; T1 = T1 + 1
    move.b T1,d0
    add.b #1,d0
    move.b d0,T1
    jmp bounded_flood_fill_L13
bounded_flood_fill_L15:
    jmp bounded_flood_fill_L10
bounded_flood_fill_L12:
; T1 = 0
    move.b #0,d0
    move.b d0,T1
; while T1 < 16:
bounded_flood_fill_L37:
    move.b T1,d0
    cmp.b #16,d0
    bcs bounded_flood_fill_L38
    jmp bounded_flood_fill_L39
bounded_flood_fill_L38:
; T3 = V[T1]
    moveq #0,d1
    move.b T1,d1
    lea V0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T3
; if T3 != 0:
    move.b T3,d0
    cmp.b #0,d0
    bne bounded_flood_fill_L40
    jmp bounded_flood_fill_L41
bounded_flood_fill_L40:
; C[T1] = REPLACEMENT
    move.b REPLACEMENT,d0
    move.b d0,d2
    moveq #0,d1
    move.b T1,d1
    lea C0,a0
    move.b d2,0(a0,d1.w)
; CHANGED = CHANGED + 1
    move.b CHANGED,d0
    add.b #1,d0
    move.b d0,CHANGED
    jmp bounded_flood_fill_L42
bounded_flood_fill_L41:
bounded_flood_fill_L42:
; T1 = T1 + 1
    move.b T1,d0
    add.b #1,d0
    move.b d0,T1
    jmp bounded_flood_fill_L37
bounded_flood_fill_L39:
    rts
component_end:
