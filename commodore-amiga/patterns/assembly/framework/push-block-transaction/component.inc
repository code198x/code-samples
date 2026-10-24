; SPDX-License-Identifier: MIT
; Push a Block Atomically. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
push_block_transaction_init:
    move.b #0,d0
    move.b d0,CELL
    move.b d0,RESULT
    move.b d0,VALID
    move.b d0,REQUEST
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
    move.b d0,EXPR_SAVE
    rts
push_block_transaction_step:
; RESULT = 0
    move.b #0,d0
    move.b d0,RESULT
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if CELL >= 16:
    move.b CELL,d0
    cmp.b #16,d0
    bcc push_block_transaction_L1
    jmp push_block_transaction_L2
push_block_transaction_L1:
; return
    rts
    jmp push_block_transaction_L3
push_block_transaction_L2:
push_block_transaction_L3:
; if REQUEST == 0:
    move.b REQUEST,d0
    cmp.b #0,d0
    beq push_block_transaction_L4
    jmp push_block_transaction_L5
push_block_transaction_L4:
; return
    rts
    jmp push_block_transaction_L6
push_block_transaction_L5:
push_block_transaction_L6:
; if REQUEST > 4:
    move.b REQUEST,d0
    cmp.b #4,d0
    bhi push_block_transaction_L7
    jmp push_block_transaction_L8
push_block_transaction_L7:
; return
    rts
    jmp push_block_transaction_L9
push_block_transaction_L8:
push_block_transaction_L9:
; T0 = C[CELL]
    moveq #0,d1
    move.b CELL,d1
    lea C0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T0
; if T0 != 0:
    move.b T0,d0
    cmp.b #0,d0
    bne push_block_transaction_L10
    jmp push_block_transaction_L11
push_block_transaction_L10:
; return
    rts
    jmp push_block_transaction_L12
push_block_transaction_L11:
push_block_transaction_L12:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = CELL
    move.b CELL,d0
    move.b d0,T0
; T4 = 0
    move.b #0,d0
    move.b d0,T4
; while T4 < 2:
push_block_transaction_L13:
    move.b T4,d0
    cmp.b #2,d0
    bcs push_block_transaction_L14
    jmp push_block_transaction_L15
push_block_transaction_L14:
; T1 = 255
    move.b #255,d0
    move.b d0,T1
; T2 = T0 & 3
    move.b T0,d0
    and.b #3,d0
    move.b d0,T2
; if REQUEST == 1:
    move.b REQUEST,d0
    cmp.b #1,d0
    beq push_block_transaction_L16
    jmp push_block_transaction_L17
push_block_transaction_L16:
; if T2 != 0:
    move.b T2,d0
    cmp.b #0,d0
    bne push_block_transaction_L19
    jmp push_block_transaction_L20
push_block_transaction_L19:
; T1 = T0 - 1
    move.b T0,d0
    sub.b #1,d0
    move.b d0,T1
    jmp push_block_transaction_L21
push_block_transaction_L20:
push_block_transaction_L21:
    jmp push_block_transaction_L18
push_block_transaction_L17:
push_block_transaction_L18:
; if REQUEST == 2:
    move.b REQUEST,d0
    cmp.b #2,d0
    beq push_block_transaction_L22
    jmp push_block_transaction_L23
push_block_transaction_L22:
; if T2 != 3:
    move.b T2,d0
    cmp.b #3,d0
    bne push_block_transaction_L25
    jmp push_block_transaction_L26
push_block_transaction_L25:
; T1 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T1
    jmp push_block_transaction_L27
push_block_transaction_L26:
push_block_transaction_L27:
    jmp push_block_transaction_L24
push_block_transaction_L23:
push_block_transaction_L24:
; if REQUEST == 3:
    move.b REQUEST,d0
    cmp.b #3,d0
    beq push_block_transaction_L28
    jmp push_block_transaction_L29
push_block_transaction_L28:
; if T0 >= 4:
    move.b T0,d0
    cmp.b #4,d0
    bcc push_block_transaction_L31
    jmp push_block_transaction_L32
push_block_transaction_L31:
; T1 = T0 - 4
    move.b T0,d0
    sub.b #4,d0
    move.b d0,T1
    jmp push_block_transaction_L33
push_block_transaction_L32:
push_block_transaction_L33:
    jmp push_block_transaction_L30
push_block_transaction_L29:
push_block_transaction_L30:
; if REQUEST == 4:
    move.b REQUEST,d0
    cmp.b #4,d0
    beq push_block_transaction_L34
    jmp push_block_transaction_L35
push_block_transaction_L34:
; if T0 < 12:
    move.b T0,d0
    cmp.b #12,d0
    bcs push_block_transaction_L37
    jmp push_block_transaction_L38
push_block_transaction_L37:
; T1 = T0 + 4
    move.b T0,d0
    add.b #4,d0
    move.b d0,T1
    jmp push_block_transaction_L39
push_block_transaction_L38:
push_block_transaction_L39:
    jmp push_block_transaction_L36
push_block_transaction_L35:
push_block_transaction_L36:
; if T1 >= 16:
    move.b T1,d0
    cmp.b #16,d0
    bcc push_block_transaction_L40
    jmp push_block_transaction_L41
push_block_transaction_L40:
; return
    rts
    jmp push_block_transaction_L42
push_block_transaction_L41:
push_block_transaction_L42:
; T3 = C[T1]
    moveq #0,d1
    move.b T1,d1
    lea C0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T3
; if T4 == 0:
    move.b T4,d0
    cmp.b #0,d0
    beq push_block_transaction_L43
    jmp push_block_transaction_L44
push_block_transaction_L43:
; if T3 == 0:
    move.b T3,d0
    cmp.b #0,d0
    beq push_block_transaction_L46
    jmp push_block_transaction_L47
push_block_transaction_L46:
; CELL = T1
    move.b T1,d0
    move.b d0,CELL
; RESULT = 1
    move.b #1,d0
    move.b d0,RESULT
; return
    rts
    jmp push_block_transaction_L48
push_block_transaction_L47:
push_block_transaction_L48:
; if T3 != 2:
    move.b T3,d0
    cmp.b #2,d0
    bne push_block_transaction_L49
    jmp push_block_transaction_L50
push_block_transaction_L49:
; return
    rts
    jmp push_block_transaction_L51
push_block_transaction_L50:
push_block_transaction_L51:
; T5 = T1
    move.b T1,d0
    move.b d0,T5
    jmp push_block_transaction_L45
push_block_transaction_L44:
; if T3 != 0:
    move.b T3,d0
    cmp.b #0,d0
    bne push_block_transaction_L52
    jmp push_block_transaction_L53
push_block_transaction_L52:
; return
    rts
    jmp push_block_transaction_L54
push_block_transaction_L53:
push_block_transaction_L54:
; C[T1] = 2
    move.b #2,d0
    move.b d0,d2
    moveq #0,d1
    move.b T1,d1
    lea C0,a0
    move.b d2,0(a0,d1.w)
; C[T5] = 0
    move.b #0,d0
    move.b d0,d2
    moveq #0,d1
    move.b T5,d1
    lea C0,a0
    move.b d2,0(a0,d1.w)
; CELL = T5
    move.b T5,d0
    move.b d0,CELL
; RESULT = 2
    move.b #2,d0
    move.b d0,RESULT
; return
    rts
push_block_transaction_L45:
; T0 = T1
    move.b T1,d0
    move.b d0,T0
; T4 = T4 + 1
    move.b T4,d0
    add.b #1,d0
    move.b d0,T4
    jmp push_block_transaction_L13
push_block_transaction_L15:
    rts
component_end:
