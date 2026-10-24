; SPDX-License-Identifier: MIT
; Commit a Crafting Recipe Atomically. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
recipe_transaction_init:
    move.b #0,d0
    move.b d0,HAVE0
    move.b d0,HAVE1
    move.b d0,RESULT
    move.b d0,NEED0
    move.b d0,NEED1
    move.b d0,PRODUCE
    move.b d0,CAP
    move.b d0,CRAFTED
    move.b d0,VALID
    move.b d0,T0
    rts
recipe_transaction_step:
; CRAFTED = 0
    move.b #0,d0
    move.b d0,CRAFTED
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if CAP == 0:
    move.b CAP,d0
    cmp.b #0,d0
    beq recipe_transaction_L1
    jmp recipe_transaction_L2
recipe_transaction_L1:
; return
    rts
    jmp recipe_transaction_L3
recipe_transaction_L2:
recipe_transaction_L3:
; if RESULT > CAP:
    move.b RESULT,d0
    move.b CAP,d1
    cmp.b d1,d0
    bhi recipe_transaction_L4
    jmp recipe_transaction_L5
recipe_transaction_L4:
; return
    rts
    jmp recipe_transaction_L6
recipe_transaction_L5:
recipe_transaction_L6:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if HAVE0 < NEED0:
    move.b HAVE0,d0
    move.b NEED0,d1
    cmp.b d1,d0
    bcs recipe_transaction_L7
    jmp recipe_transaction_L8
recipe_transaction_L7:
; return
    rts
    jmp recipe_transaction_L9
recipe_transaction_L8:
recipe_transaction_L9:
; if HAVE1 < NEED1:
    move.b HAVE1,d0
    move.b NEED1,d1
    cmp.b d1,d0
    bcs recipe_transaction_L10
    jmp recipe_transaction_L11
recipe_transaction_L10:
; return
    rts
    jmp recipe_transaction_L12
recipe_transaction_L11:
recipe_transaction_L12:
; T0 = CAP - RESULT
    move.b CAP,d0
    move.b RESULT,d1
    sub.b d1,d0
    move.b d0,T0
; if PRODUCE > T0:
    move.b PRODUCE,d0
    move.b T0,d1
    cmp.b d1,d0
    bhi recipe_transaction_L13
    jmp recipe_transaction_L14
recipe_transaction_L13:
; return
    rts
    jmp recipe_transaction_L15
recipe_transaction_L14:
recipe_transaction_L15:
; HAVE0 = HAVE0 - NEED0
    move.b HAVE0,d0
    move.b NEED0,d1
    sub.b d1,d0
    move.b d0,HAVE0
; HAVE1 = HAVE1 - NEED1
    move.b HAVE1,d0
    move.b NEED1,d1
    sub.b d1,d0
    move.b d0,HAVE1
; RESULT = RESULT + PRODUCE
    move.b RESULT,d0
    move.b PRODUCE,d1
    add.b d1,d0
    move.b d0,RESULT
; CRAFTED = 1
    move.b #1,d0
    move.b d0,CRAFTED
    rts
component_end:
