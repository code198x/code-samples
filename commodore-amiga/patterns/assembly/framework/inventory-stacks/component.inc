; SPDX-License-Identifier: MIT
; Add and Remove Inventory Stacks. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
inventory_stacks_init:
    move.b #0,d0
    move.b d0,SLOT
    move.b d0,AMOUNT
    move.b d0,REMOVE
    move.b d0,CAP
    move.b d0,SUCCESS
    move.b d0,VALID
    move.b d0,C0
    move.b d0,C1
    move.b d0,C2
    move.b d0,C3
    move.b d0,T0
    move.b d0,T1
    move.b d0,EXPR_SAVE
    rts
inventory_stacks_step:
; SUCCESS = 0
    move.b #0,d0
    move.b d0,SUCCESS
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if SLOT >= 4:
    move.b SLOT,d0
    cmp.b #4,d0
    bcc inventory_stacks_L1
    jmp inventory_stacks_L2
inventory_stacks_L1:
; return
    rts
    jmp inventory_stacks_L3
inventory_stacks_L2:
inventory_stacks_L3:
; if CAP == 0:
    move.b CAP,d0
    cmp.b #0,d0
    beq inventory_stacks_L4
    jmp inventory_stacks_L5
inventory_stacks_L4:
; return
    rts
    jmp inventory_stacks_L6
inventory_stacks_L5:
inventory_stacks_L6:
; T0 = C[SLOT]
    moveq #0,d1
    move.b SLOT,d1
    lea C0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T0
; if T0 > CAP:
    move.b T0,d0
    move.b CAP,d1
    cmp.b d1,d0
    bhi inventory_stacks_L7
    jmp inventory_stacks_L8
inventory_stacks_L7:
; return
    rts
    jmp inventory_stacks_L9
inventory_stacks_L8:
inventory_stacks_L9:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if REMOVE != 0:
    move.b REMOVE,d0
    cmp.b #0,d0
    bne inventory_stacks_L10
    jmp inventory_stacks_L11
inventory_stacks_L10:
; if AMOUNT > T0:
    move.b AMOUNT,d0
    move.b T0,d1
    cmp.b d1,d0
    bhi inventory_stacks_L13
    jmp inventory_stacks_L14
inventory_stacks_L13:
; return
    rts
    jmp inventory_stacks_L15
inventory_stacks_L14:
inventory_stacks_L15:
; T0 = T0 - AMOUNT
    move.b T0,d0
    move.b AMOUNT,d1
    sub.b d1,d0
    move.b d0,T0
    jmp inventory_stacks_L12
inventory_stacks_L11:
; T1 = CAP - T0
    move.b CAP,d0
    move.b T0,d1
    sub.b d1,d0
    move.b d0,T1
; if AMOUNT > T1:
    move.b AMOUNT,d0
    move.b T1,d1
    cmp.b d1,d0
    bhi inventory_stacks_L16
    jmp inventory_stacks_L17
inventory_stacks_L16:
; return
    rts
    jmp inventory_stacks_L18
inventory_stacks_L17:
inventory_stacks_L18:
; T0 = T0 + AMOUNT
    move.b T0,d0
    move.b AMOUNT,d1
    add.b d1,d0
    move.b d0,T0
inventory_stacks_L12:
; C[SLOT] = T0
    move.b T0,d0
    move.b d0,d2
    moveq #0,d1
    move.b SLOT,d1
    lea C0,a0
    move.b d2,0(a0,d1.w)
; SUCCESS = 1
    move.b #1,d0
    move.b d0,SUCCESS
    rts
component_end:
