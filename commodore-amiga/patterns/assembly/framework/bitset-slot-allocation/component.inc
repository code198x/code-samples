; SPDX-License-Identifier: MIT
; Allocate Slots with a Bitset. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bitset_slot_allocation_init:
    move.b #0,d0
    move.b d0,SLOT
    move.b d0,RESULT
    move.b d0,VALID
    move.b d0,USED
    move.b d0,MODE
    move.b d0,REQUEST
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    rts
bitset_slot_allocation_step:
; SLOT = 255
    move.b #255,d0
    move.b d0,SLOT
; RESULT = 0
    move.b #0,d0
    move.b d0,RESULT
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if MODE > 1:
    move.b MODE,d0
    cmp.b #1,d0
    bhi bitset_slot_allocation_L1
    jmp bitset_slot_allocation_L2
bitset_slot_allocation_L1:
; return
    rts
    jmp bitset_slot_allocation_L3
bitset_slot_allocation_L2:
bitset_slot_allocation_L3:
; if MODE == 1:
    move.b MODE,d0
    cmp.b #1,d0
    beq bitset_slot_allocation_L4
    jmp bitset_slot_allocation_L5
bitset_slot_allocation_L4:
; if REQUEST >= 8:
    move.b REQUEST,d0
    cmp.b #8,d0
    bcc bitset_slot_allocation_L7
    jmp bitset_slot_allocation_L8
bitset_slot_allocation_L7:
; return
    rts
    jmp bitset_slot_allocation_L9
bitset_slot_allocation_L8:
bitset_slot_allocation_L9:
    jmp bitset_slot_allocation_L6
bitset_slot_allocation_L5:
bitset_slot_allocation_L6:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; T1 = 1
    move.b #1,d0
    move.b d0,T1
; if MODE == 0:
    move.b MODE,d0
    cmp.b #0,d0
    beq bitset_slot_allocation_L10
    jmp bitset_slot_allocation_L11
bitset_slot_allocation_L10:
; while T0 < 8:
bitset_slot_allocation_L13:
    move.b T0,d0
    cmp.b #8,d0
    bcs bitset_slot_allocation_L14
    jmp bitset_slot_allocation_L15
bitset_slot_allocation_L14:
; T2 = USED & T1
    move.b USED,d0
    move.b T1,d1
    and.b d1,d0
    move.b d0,T2
; if T2 == 0:
    move.b T2,d0
    cmp.b #0,d0
    beq bitset_slot_allocation_L16
    jmp bitset_slot_allocation_L17
bitset_slot_allocation_L16:
; USED = USED | T1
    move.b USED,d0
    move.b T1,d1
    or.b d1,d0
    move.b d0,USED
; SLOT = T0
    move.b T0,d0
    move.b d0,SLOT
; RESULT = 1
    move.b #1,d0
    move.b d0,RESULT
; return
    rts
    jmp bitset_slot_allocation_L18
bitset_slot_allocation_L17:
bitset_slot_allocation_L18:
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
; T1 = T1 << 1
    move.b T1,d0
    lsl.b #1,d0
    move.b d0,T1
    jmp bitset_slot_allocation_L13
bitset_slot_allocation_L15:
    jmp bitset_slot_allocation_L12
bitset_slot_allocation_L11:
; T0 = REQUEST
    move.b REQUEST,d0
    move.b d0,T0
; while T0 != 0:
bitset_slot_allocation_L19:
    move.b T0,d0
    cmp.b #0,d0
    bne bitset_slot_allocation_L20
    jmp bitset_slot_allocation_L21
bitset_slot_allocation_L20:
; T1 = T1 << 1
    move.b T1,d0
    lsl.b #1,d0
    move.b d0,T1
; T0 = T0 - 1
    move.b T0,d0
    sub.b #1,d0
    move.b d0,T0
    jmp bitset_slot_allocation_L19
bitset_slot_allocation_L21:
; T2 = USED & T1
    move.b USED,d0
    move.b T1,d1
    and.b d1,d0
    move.b d0,T2
; if T2 != 0:
    move.b T2,d0
    cmp.b #0,d0
    bne bitset_slot_allocation_L22
    jmp bitset_slot_allocation_L23
bitset_slot_allocation_L22:
; T1 = T1 ^ 255
    move.b T1,d0
    eor.b #255,d0
    move.b d0,T1
; USED = USED & T1
    move.b USED,d0
    move.b T1,d1
    and.b d1,d0
    move.b d0,USED
; SLOT = REQUEST
    move.b REQUEST,d0
    move.b d0,SLOT
; RESULT = 1
    move.b #1,d0
    move.b d0,RESULT
    jmp bitset_slot_allocation_L24
bitset_slot_allocation_L23:
bitset_slot_allocation_L24:
bitset_slot_allocation_L12:
    rts
component_end:
