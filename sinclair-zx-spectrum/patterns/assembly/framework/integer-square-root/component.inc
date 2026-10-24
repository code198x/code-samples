; SPDX-License-Identifier: MIT
; Find an Integer Square Root. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
integer_square_root_init:
    ld a,0
    ld (ROOT),a
    ld (REMAINDER_LO),a
    ld (REMAINDER_HI),a
    ld (NUMBER_LO),a
    ld (NUMBER_HI),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ret
integer_square_root_step:
; ROOT = 0
    ld a,0
    ld (ROOT),a
; REMAINDER_LO = NUMBER_LO
    ld a,(NUMBER_LO)
    ld (REMAINDER_LO),a
; REMAINDER_HI = NUMBER_HI
    ld a,(NUMBER_HI)
    ld (REMAINDER_HI),a
; T0 = 1
    ld a,1
    ld (T0),a
; T1 = 0
    ld a,0
    ld (T1),a
; T2 = 1
    ld a,1
    ld (T2),a
; while T2 == 1:
integer_square_root_L1:
    ld a,(T2)
    cp 1
    jp z,integer_square_root_L2
    jp integer_square_root_L3
integer_square_root_L2:
; if REMAINDER_HI < T1:
    ld a,(REMAINDER_HI)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    cp c
    jp c,integer_square_root_L4
    jp integer_square_root_L5
integer_square_root_L4:
; return
    ret
    jp integer_square_root_L6
integer_square_root_L5:
integer_square_root_L6:
; if REMAINDER_HI == T1:
    ld a,(REMAINDER_HI)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    cp c
    jp z,integer_square_root_L7
    jp integer_square_root_L8
integer_square_root_L7:
; if REMAINDER_LO < T0:
    ld a,(REMAINDER_LO)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp c,integer_square_root_L10
    jp integer_square_root_L11
integer_square_root_L10:
; return
    ret
    jp integer_square_root_L12
integer_square_root_L11:
integer_square_root_L12:
    jp integer_square_root_L9
integer_square_root_L8:
integer_square_root_L9:
; T3 = 0
    ld a,0
    ld (T3),a
; if REMAINDER_LO < T0:
    ld a,(REMAINDER_LO)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp c,integer_square_root_L13
    jp integer_square_root_L14
integer_square_root_L13:
; T3 = 1
    ld a,1
    ld (T3),a
    jp integer_square_root_L15
integer_square_root_L14:
integer_square_root_L15:
; REMAINDER_LO = REMAINDER_LO - T0
    ld a,(REMAINDER_LO)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    sub c
    ld (REMAINDER_LO),a
; REMAINDER_HI = REMAINDER_HI - T1
    ld a,(REMAINDER_HI)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    sub c
    ld (REMAINDER_HI),a
; REMAINDER_HI = REMAINDER_HI - T3
    ld a,(REMAINDER_HI)
    ld b,a
    ld a,(T3)
    ld c,a
    ld a,b
    sub c
    ld (REMAINDER_HI),a
; ROOT = ROOT + 1
    ld a,(ROOT)
    add a,1
    ld (ROOT),a
; T3 = T0
    ld a,(T0)
    ld (T3),a
; T0 = T0 + 2
    ld a,(T0)
    add a,2
    ld (T0),a
; if T0 < T3:
    ld a,(T0)
    ld b,a
    ld a,(T3)
    ld c,a
    ld a,b
    cp c
    jp c,integer_square_root_L16
    jp integer_square_root_L17
integer_square_root_L16:
; T1 = T1 + 1
    ld a,(T1)
    add a,1
    ld (T1),a
    jp integer_square_root_L18
integer_square_root_L17:
integer_square_root_L18:
    jp integer_square_root_L1
integer_square_root_L3:
    ret
component_end:
