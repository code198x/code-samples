; SPDX-License-Identifier: MIT
; Commit a Crafting Recipe Atomically. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
recipe_transaction_init:
    lda #0
    sta HAVE0
    sta HAVE1
    sta RESULT
    sta NEED0
    sta NEED1
    sta PRODUCE
    sta CAP
    sta CRAFTED
    sta VALID
    sta T0
    rts
recipe_transaction_step:
; CRAFTED = 0
    lda #0
    sta CRAFTED
; VALID = 0
    lda #0
    sta VALID
; if CAP == 0:
    lda CAP
    cmp #0
    beq recipe_transaction_L4
recipe_transaction_L5:
    jmp recipe_transaction_L2
recipe_transaction_L4:
    jmp recipe_transaction_L1
recipe_transaction_L1:
; return
    rts
    jmp recipe_transaction_L3
recipe_transaction_L2:
recipe_transaction_L3:
; if RESULT > CAP:
    lda RESULT
    cmp CAP
    beq recipe_transaction_L10
    bcs recipe_transaction_L9
recipe_transaction_L10:
    jmp recipe_transaction_L7
recipe_transaction_L9:
    jmp recipe_transaction_L6
recipe_transaction_L6:
; return
    rts
    jmp recipe_transaction_L8
recipe_transaction_L7:
recipe_transaction_L8:
; VALID = 1
    lda #1
    sta VALID
; if HAVE0 < NEED0:
    lda HAVE0
    cmp NEED0
    bcc recipe_transaction_L14
recipe_transaction_L15:
    jmp recipe_transaction_L12
recipe_transaction_L14:
    jmp recipe_transaction_L11
recipe_transaction_L11:
; return
    rts
    jmp recipe_transaction_L13
recipe_transaction_L12:
recipe_transaction_L13:
; if HAVE1 < NEED1:
    lda HAVE1
    cmp NEED1
    bcc recipe_transaction_L19
recipe_transaction_L20:
    jmp recipe_transaction_L17
recipe_transaction_L19:
    jmp recipe_transaction_L16
recipe_transaction_L16:
; return
    rts
    jmp recipe_transaction_L18
recipe_transaction_L17:
recipe_transaction_L18:
; T0 = CAP - RESULT
    lda CAP
    sec
    sbc RESULT
    sta T0
; if PRODUCE > T0:
    lda PRODUCE
    cmp T0
    beq recipe_transaction_L25
    bcs recipe_transaction_L24
recipe_transaction_L25:
    jmp recipe_transaction_L22
recipe_transaction_L24:
    jmp recipe_transaction_L21
recipe_transaction_L21:
; return
    rts
    jmp recipe_transaction_L23
recipe_transaction_L22:
recipe_transaction_L23:
; HAVE0 = HAVE0 - NEED0
    lda HAVE0
    sec
    sbc NEED0
    sta HAVE0
; HAVE1 = HAVE1 - NEED1
    lda HAVE1
    sec
    sbc NEED1
    sta HAVE1
; RESULT = RESULT + PRODUCE
    lda RESULT
    clc
    adc PRODUCE
    sta RESULT
; CRAFTED = 1
    lda #1
    sta CRAFTED
    rts
component_end:
