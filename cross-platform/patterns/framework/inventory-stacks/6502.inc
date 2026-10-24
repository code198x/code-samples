; SPDX-License-Identifier: MIT
; Add and Remove Inventory Stacks. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
inventory_stacks_init:
    lda #0
    sta SLOT
    sta AMOUNT
    sta REMOVE
    sta CAP
    sta SUCCESS
    sta VALID
    sta C0
    sta C1
    sta C2
    sta C3
    sta T0
    sta T1
    sta EXPR_SAVE
    rts
inventory_stacks_step:
; SUCCESS = 0
    lda #0
    sta SUCCESS
; VALID = 0
    lda #0
    sta VALID
; if SLOT >= 4:
    lda SLOT
    cmp #4
    bcs inventory_stacks_L4
inventory_stacks_L5:
    jmp inventory_stacks_L2
inventory_stacks_L4:
    jmp inventory_stacks_L1
inventory_stacks_L1:
; return
    rts
    jmp inventory_stacks_L3
inventory_stacks_L2:
inventory_stacks_L3:
; if CAP == 0:
    lda CAP
    cmp #0
    beq inventory_stacks_L9
inventory_stacks_L10:
    jmp inventory_stacks_L7
inventory_stacks_L9:
    jmp inventory_stacks_L6
inventory_stacks_L6:
; return
    rts
    jmp inventory_stacks_L8
inventory_stacks_L7:
inventory_stacks_L8:
; T0 = C[SLOT]
    ldx SLOT
    lda C0,x
    sta T0
; if T0 > CAP:
    lda T0
    cmp CAP
    beq inventory_stacks_L15
    bcs inventory_stacks_L14
inventory_stacks_L15:
    jmp inventory_stacks_L12
inventory_stacks_L14:
    jmp inventory_stacks_L11
inventory_stacks_L11:
; return
    rts
    jmp inventory_stacks_L13
inventory_stacks_L12:
inventory_stacks_L13:
; VALID = 1
    lda #1
    sta VALID
; if REMOVE != 0:
    lda REMOVE
    cmp #0
    bne inventory_stacks_L19
inventory_stacks_L20:
    jmp inventory_stacks_L17
inventory_stacks_L19:
    jmp inventory_stacks_L16
inventory_stacks_L16:
; if AMOUNT > T0:
    lda AMOUNT
    cmp T0
    beq inventory_stacks_L25
    bcs inventory_stacks_L24
inventory_stacks_L25:
    jmp inventory_stacks_L22
inventory_stacks_L24:
    jmp inventory_stacks_L21
inventory_stacks_L21:
; return
    rts
    jmp inventory_stacks_L23
inventory_stacks_L22:
inventory_stacks_L23:
; T0 = T0 - AMOUNT
    lda T0
    sec
    sbc AMOUNT
    sta T0
    jmp inventory_stacks_L18
inventory_stacks_L17:
; T1 = CAP - T0
    lda CAP
    sec
    sbc T0
    sta T1
; if AMOUNT > T1:
    lda AMOUNT
    cmp T1
    beq inventory_stacks_L30
    bcs inventory_stacks_L29
inventory_stacks_L30:
    jmp inventory_stacks_L27
inventory_stacks_L29:
    jmp inventory_stacks_L26
inventory_stacks_L26:
; return
    rts
    jmp inventory_stacks_L28
inventory_stacks_L27:
inventory_stacks_L28:
; T0 = T0 + AMOUNT
    lda T0
    clc
    adc AMOUNT
    sta T0
inventory_stacks_L18:
; C[SLOT] = T0
    lda T0
    sta EXPR_SAVE
    ldx SLOT
    lda EXPR_SAVE
    sta C0,x
; SUCCESS = 1
    lda #1
    sta SUCCESS
    rts
component_end:
