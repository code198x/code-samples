; SPDX-License-Identifier: MIT
; Add and Remove Inventory Stacks. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
inventory_stacks_init:
    ld a,0
    ld (SLOT),a
    ld (AMOUNT),a
    ld (REMOVE),a
    ld (CAP),a
    ld (SUCCESS),a
    ld (VALID),a
    ld (C0),a
    ld (C1),a
    ld (C2),a
    ld (C3),a
    ld (T0),a
    ld (T1),a
    ld (EXPR_SAVE),a
    ret
inventory_stacks_step:
; SUCCESS = 0
    ld a,0
    ld (SUCCESS),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if SLOT >= 4:
    ld a,(SLOT)
    cp 4
    jp nc,inventory_stacks_L1
    jp inventory_stacks_L2
inventory_stacks_L1:
; return
    ret
    jp inventory_stacks_L3
inventory_stacks_L2:
inventory_stacks_L3:
; if CAP == 0:
    ld a,(CAP)
    cp 0
    jp z,inventory_stacks_L4
    jp inventory_stacks_L5
inventory_stacks_L4:
; return
    ret
    jp inventory_stacks_L6
inventory_stacks_L5:
inventory_stacks_L6:
; T0 = C[SLOT]
    ld a,(SLOT)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld a,(hl)
    ld (T0),a
; if T0 > CAP:
    ld a,(T0)
    ld b,a
    ld a,(CAP)
    ld c,a
    ld a,b
    cp c
    jp z,inventory_stacks_L8
    jp nc,inventory_stacks_L7
    jp inventory_stacks_L8
inventory_stacks_L7:
; return
    ret
    jp inventory_stacks_L9
inventory_stacks_L8:
inventory_stacks_L9:
; VALID = 1
    ld a,1
    ld (VALID),a
; if REMOVE != 0:
    ld a,(REMOVE)
    cp 0
    jp nz,inventory_stacks_L10
    jp inventory_stacks_L11
inventory_stacks_L10:
; if AMOUNT > T0:
    ld a,(AMOUNT)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp z,inventory_stacks_L14
    jp nc,inventory_stacks_L13
    jp inventory_stacks_L14
inventory_stacks_L13:
; return
    ret
    jp inventory_stacks_L15
inventory_stacks_L14:
inventory_stacks_L15:
; T0 = T0 - AMOUNT
    ld a,(T0)
    ld b,a
    ld a,(AMOUNT)
    ld c,a
    ld a,b
    sub c
    ld (T0),a
    jp inventory_stacks_L12
inventory_stacks_L11:
; T1 = CAP - T0
    ld a,(CAP)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    sub c
    ld (T1),a
; if AMOUNT > T1:
    ld a,(AMOUNT)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    cp c
    jp z,inventory_stacks_L17
    jp nc,inventory_stacks_L16
    jp inventory_stacks_L17
inventory_stacks_L16:
; return
    ret
    jp inventory_stacks_L18
inventory_stacks_L17:
inventory_stacks_L18:
; T0 = T0 + AMOUNT
    ld a,(T0)
    ld b,a
    ld a,(AMOUNT)
    ld c,a
    ld a,b
    add a,c
    ld (T0),a
inventory_stacks_L12:
; C[SLOT] = T0
    ld a,(T0)
    ld c,a
    ld a,(SLOT)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld (hl),c
; SUCCESS = 1
    ld a,1
    ld (SUCCESS),a
    ret
component_end:
