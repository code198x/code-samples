; SPDX-License-Identifier: MIT
; Keep a Bounded Cell-edit Undo Log. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_undo_init:
    move.b #0,d0
    move.b d0,RESULT
    move.b d0,VALID
    move.b d0,COUNT
    move.b d0,MODE
    move.b d0,CELL
    move.b d0,VALUE
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
    move.b d0,J0
    move.b d0,J1
    move.b d0,J2
    move.b d0,J3
    move.b d0,K0
    move.b d0,K1
    move.b d0,K2
    move.b d0,K3
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,EXPR_SAVE
    rts
bounded_undo_step:
; RESULT = 0
    move.b #0,d0
    move.b d0,RESULT
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if COUNT > 4:
    move.b COUNT,d0
    cmp.b #4,d0
    bhi bounded_undo_L1
    jmp bounded_undo_L2
bounded_undo_L1:
; return
    rts
    jmp bounded_undo_L3
bounded_undo_L2:
bounded_undo_L3:
; if MODE >= 3:
    move.b MODE,d0
    cmp.b #3,d0
    bcc bounded_undo_L4
    jmp bounded_undo_L5
bounded_undo_L4:
; return
    rts
    jmp bounded_undo_L6
bounded_undo_L5:
bounded_undo_L6:
; if MODE == 2:
    move.b MODE,d0
    cmp.b #2,d0
    beq bounded_undo_L7
    jmp bounded_undo_L8
bounded_undo_L7:
; COUNT = 0
    move.b #0,d0
    move.b d0,COUNT
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; RESULT = 1
    move.b #1,d0
    move.b d0,RESULT
; return
    rts
    jmp bounded_undo_L9
bounded_undo_L8:
bounded_undo_L9:
; if MODE == 0:
    move.b MODE,d0
    cmp.b #0,d0
    beq bounded_undo_L10
    jmp bounded_undo_L11
bounded_undo_L10:
; if CELL >= 16:
    move.b CELL,d0
    cmp.b #16,d0
    bcc bounded_undo_L13
    jmp bounded_undo_L14
bounded_undo_L13:
; return
    rts
    jmp bounded_undo_L15
bounded_undo_L14:
bounded_undo_L15:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if COUNT == 4:
    move.b COUNT,d0
    cmp.b #4,d0
    beq bounded_undo_L16
    jmp bounded_undo_L17
bounded_undo_L16:
; return
    rts
    jmp bounded_undo_L18
bounded_undo_L17:
bounded_undo_L18:
; T0 = C[CELL]
    moveq #0,d1
    move.b CELL,d1
    lea C0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T0
; J[COUNT] = CELL
    move.b CELL,d0
    move.b d0,d2
    moveq #0,d1
    move.b COUNT,d1
    lea J0,a0
    move.b d2,0(a0,d1.w)
; K[COUNT] = T0
    move.b T0,d0
    move.b d0,d2
    moveq #0,d1
    move.b COUNT,d1
    lea K0,a0
    move.b d2,0(a0,d1.w)
; C[CELL] = VALUE
    move.b VALUE,d0
    move.b d0,d2
    moveq #0,d1
    move.b CELL,d1
    lea C0,a0
    move.b d2,0(a0,d1.w)
; COUNT = COUNT + 1
    move.b COUNT,d0
    add.b #1,d0
    move.b d0,COUNT
; RESULT = 1
    move.b #1,d0
    move.b d0,RESULT
; return
    rts
    jmp bounded_undo_L12
bounded_undo_L11:
bounded_undo_L12:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if COUNT == 0:
    move.b COUNT,d0
    cmp.b #0,d0
    beq bounded_undo_L19
    jmp bounded_undo_L20
bounded_undo_L19:
; return
    rts
    jmp bounded_undo_L21
bounded_undo_L20:
bounded_undo_L21:
; T0 = COUNT - 1
    move.b COUNT,d0
    sub.b #1,d0
    move.b d0,T0
; T1 = J[T0]
    moveq #0,d1
    move.b T0,d1
    lea J0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T1
; if T1 >= 16:
    move.b T1,d0
    cmp.b #16,d0
    bcc bounded_undo_L22
    jmp bounded_undo_L23
bounded_undo_L22:
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; return
    rts
    jmp bounded_undo_L24
bounded_undo_L23:
bounded_undo_L24:
; T2 = K[T0]
    moveq #0,d1
    move.b T0,d1
    lea K0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T2
; C[T1] = T2
    move.b T2,d0
    move.b d0,d2
    moveq #0,d1
    move.b T1,d1
    lea C0,a0
    move.b d2,0(a0,d1.w)
; COUNT = T0
    move.b T0,d0
    move.b d0,COUNT
; RESULT = 1
    move.b #1,d0
    move.b d0,RESULT
    rts
component_end:
