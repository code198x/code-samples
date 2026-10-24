; SPDX-License-Identifier: MIT
; Allocate Slots with a Bitset. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bitset_slot_allocation_init:
    lda #0
    sta SLOT
    sta RESULT
    sta VALID
    sta USED
    sta MODE
    sta REQUEST
    sta T0
    sta T1
    sta T2
    rts
bitset_slot_allocation_step:
; SLOT = 255
    lda #255
    sta SLOT
; RESULT = 0
    lda #0
    sta RESULT
; VALID = 0
    lda #0
    sta VALID
; if MODE > 1:
    lda MODE
    cmp #1
    beq bitset_slot_allocation_L5
    bcs bitset_slot_allocation_L4
bitset_slot_allocation_L5:
    jmp bitset_slot_allocation_L2
bitset_slot_allocation_L4:
    jmp bitset_slot_allocation_L1
bitset_slot_allocation_L1:
; return
    rts
    jmp bitset_slot_allocation_L3
bitset_slot_allocation_L2:
bitset_slot_allocation_L3:
; if MODE == 1:
    lda MODE
    cmp #1
    beq bitset_slot_allocation_L9
bitset_slot_allocation_L10:
    jmp bitset_slot_allocation_L7
bitset_slot_allocation_L9:
    jmp bitset_slot_allocation_L6
bitset_slot_allocation_L6:
; if REQUEST >= 8:
    lda REQUEST
    cmp #8
    bcs bitset_slot_allocation_L14
bitset_slot_allocation_L15:
    jmp bitset_slot_allocation_L12
bitset_slot_allocation_L14:
    jmp bitset_slot_allocation_L11
bitset_slot_allocation_L11:
; return
    rts
    jmp bitset_slot_allocation_L13
bitset_slot_allocation_L12:
bitset_slot_allocation_L13:
    jmp bitset_slot_allocation_L8
bitset_slot_allocation_L7:
bitset_slot_allocation_L8:
; VALID = 1
    lda #1
    sta VALID
; T0 = 0
    lda #0
    sta T0
; T1 = 1
    lda #1
    sta T1
; if MODE == 0:
    lda MODE
    cmp #0
    beq bitset_slot_allocation_L19
bitset_slot_allocation_L20:
    jmp bitset_slot_allocation_L17
bitset_slot_allocation_L19:
    jmp bitset_slot_allocation_L16
bitset_slot_allocation_L16:
; while T0 < 8:
bitset_slot_allocation_L21:
    lda T0
    cmp #8
    bcc bitset_slot_allocation_L24
bitset_slot_allocation_L25:
    jmp bitset_slot_allocation_L23
bitset_slot_allocation_L24:
    jmp bitset_slot_allocation_L22
bitset_slot_allocation_L22:
; T2 = USED & T1
    lda USED
    and T1
    sta T2
; if T2 == 0:
    lda T2
    cmp #0
    beq bitset_slot_allocation_L29
bitset_slot_allocation_L30:
    jmp bitset_slot_allocation_L27
bitset_slot_allocation_L29:
    jmp bitset_slot_allocation_L26
bitset_slot_allocation_L26:
; USED = USED | T1
    lda USED
    ora T1
    sta USED
; SLOT = T0
    lda T0
    sta SLOT
; RESULT = 1
    lda #1
    sta RESULT
; return
    rts
    jmp bitset_slot_allocation_L28
bitset_slot_allocation_L27:
bitset_slot_allocation_L28:
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
; T1 = T1 << 1
    lda T1
    asl
    sta T1
    jmp bitset_slot_allocation_L21
bitset_slot_allocation_L23:
    jmp bitset_slot_allocation_L18
bitset_slot_allocation_L17:
; T0 = REQUEST
    lda REQUEST
    sta T0
; while T0 != 0:
bitset_slot_allocation_L31:
    lda T0
    cmp #0
    bne bitset_slot_allocation_L34
bitset_slot_allocation_L35:
    jmp bitset_slot_allocation_L33
bitset_slot_allocation_L34:
    jmp bitset_slot_allocation_L32
bitset_slot_allocation_L32:
; T1 = T1 << 1
    lda T1
    asl
    sta T1
; T0 = T0 - 1
    lda T0
    sec
    sbc #1
    sta T0
    jmp bitset_slot_allocation_L31
bitset_slot_allocation_L33:
; T2 = USED & T1
    lda USED
    and T1
    sta T2
; if T2 != 0:
    lda T2
    cmp #0
    bne bitset_slot_allocation_L39
bitset_slot_allocation_L40:
    jmp bitset_slot_allocation_L37
bitset_slot_allocation_L39:
    jmp bitset_slot_allocation_L36
bitset_slot_allocation_L36:
; T1 = T1 ^ 255
    lda T1
    eor #255
    sta T1
; USED = USED & T1
    lda USED
    and T1
    sta USED
; SLOT = REQUEST
    lda REQUEST
    sta SLOT
; RESULT = 1
    lda #1
    sta RESULT
    jmp bitset_slot_allocation_L38
bitset_slot_allocation_L37:
bitset_slot_allocation_L38:
bitset_slot_allocation_L18:
    rts
component_end:
