; SPDX-License-Identifier: MIT
; Commit a Crafting Recipe Atomically. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
recipe_transaction_init:
    ld a,0
    ld (HAVE0),a
    ld (HAVE1),a
    ld (RESULT),a
    ld (NEED0),a
    ld (NEED1),a
    ld (PRODUCE),a
    ld (CAP),a
    ld (CRAFTED),a
    ld (VALID),a
    ld (T0),a
    ret
recipe_transaction_step:
; CRAFTED = 0
    ld a,0
    ld (CRAFTED),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if CAP == 0:
    ld a,(CAP)
    cp 0
    jp z,recipe_transaction_L1
    jp recipe_transaction_L2
recipe_transaction_L1:
; return
    ret
    jp recipe_transaction_L3
recipe_transaction_L2:
recipe_transaction_L3:
; if RESULT > CAP:
    ld a,(RESULT)
    ld b,a
    ld a,(CAP)
    ld c,a
    ld a,b
    cp c
    jp z,recipe_transaction_L5
    jp nc,recipe_transaction_L4
    jp recipe_transaction_L5
recipe_transaction_L4:
; return
    ret
    jp recipe_transaction_L6
recipe_transaction_L5:
recipe_transaction_L6:
; VALID = 1
    ld a,1
    ld (VALID),a
; if HAVE0 < NEED0:
    ld a,(HAVE0)
    ld b,a
    ld a,(NEED0)
    ld c,a
    ld a,b
    cp c
    jp c,recipe_transaction_L7
    jp recipe_transaction_L8
recipe_transaction_L7:
; return
    ret
    jp recipe_transaction_L9
recipe_transaction_L8:
recipe_transaction_L9:
; if HAVE1 < NEED1:
    ld a,(HAVE1)
    ld b,a
    ld a,(NEED1)
    ld c,a
    ld a,b
    cp c
    jp c,recipe_transaction_L10
    jp recipe_transaction_L11
recipe_transaction_L10:
; return
    ret
    jp recipe_transaction_L12
recipe_transaction_L11:
recipe_transaction_L12:
; T0 = CAP - RESULT
    ld a,(CAP)
    ld b,a
    ld a,(RESULT)
    ld c,a
    ld a,b
    sub c
    ld (T0),a
; if PRODUCE > T0:
    ld a,(PRODUCE)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp z,recipe_transaction_L14
    jp nc,recipe_transaction_L13
    jp recipe_transaction_L14
recipe_transaction_L13:
; return
    ret
    jp recipe_transaction_L15
recipe_transaction_L14:
recipe_transaction_L15:
; HAVE0 = HAVE0 - NEED0
    ld a,(HAVE0)
    ld b,a
    ld a,(NEED0)
    ld c,a
    ld a,b
    sub c
    ld (HAVE0),a
; HAVE1 = HAVE1 - NEED1
    ld a,(HAVE1)
    ld b,a
    ld a,(NEED1)
    ld c,a
    ld a,b
    sub c
    ld (HAVE1),a
; RESULT = RESULT + PRODUCE
    ld a,(RESULT)
    ld b,a
    ld a,(PRODUCE)
    ld c,a
    ld a,b
    add a,c
    ld (RESULT),a
; CRAFTED = 1
    ld a,1
    ld (CRAFTED),a
    ret
component_end:
