; SPDX-License-Identifier: MIT
; Choose from Weighted Outcomes. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
weighted_choice_init:
    ld a,0
    ld (WEIGHT0),a
    ld (WEIGHT1),a
    ld (WEIGHT2),a
    ld (ROLL),a
    ld (CHOICE),a
    ld (TOTAL),a
    ld (VALID),a
    ld (T0),a
    ld (T1),a
    ret
weighted_choice_step:
; CHOICE = 255
    ld a,255
    ld (CHOICE),a
; TOTAL = 0
    ld a,0
    ld (TOTAL),a
; VALID = 0
    ld a,0
    ld (VALID),a
; T0 = WEIGHT0 + WEIGHT1
    ld a,(WEIGHT0)
    ld b,a
    ld a,(WEIGHT1)
    ld c,a
    ld a,b
    add a,c
    ld (T0),a
; if T0 < WEIGHT0:
    ld a,(T0)
    ld b,a
    ld a,(WEIGHT0)
    ld c,a
    ld a,b
    cp c
    jp c,weighted_choice_L1
    jp weighted_choice_L2
weighted_choice_L1:
; return
    ret
    jp weighted_choice_L3
weighted_choice_L2:
weighted_choice_L3:
; T1 = T0 + WEIGHT2
    ld a,(T0)
    ld b,a
    ld a,(WEIGHT2)
    ld c,a
    ld a,b
    add a,c
    ld (T1),a
; if T1 < T0:
    ld a,(T1)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp c,weighted_choice_L4
    jp weighted_choice_L5
weighted_choice_L4:
; return
    ret
    jp weighted_choice_L6
weighted_choice_L5:
weighted_choice_L6:
; TOTAL = T1
    ld a,(T1)
    ld (TOTAL),a
; if TOTAL == 0:
    ld a,(TOTAL)
    cp 0
    jp z,weighted_choice_L7
    jp weighted_choice_L8
weighted_choice_L7:
; return
    ret
    jp weighted_choice_L9
weighted_choice_L8:
weighted_choice_L9:
; if ROLL >= TOTAL:
    ld a,(ROLL)
    ld b,a
    ld a,(TOTAL)
    ld c,a
    ld a,b
    cp c
    jp nc,weighted_choice_L10
    jp weighted_choice_L11
weighted_choice_L10:
; return
    ret
    jp weighted_choice_L12
weighted_choice_L11:
weighted_choice_L12:
; VALID = 1
    ld a,1
    ld (VALID),a
; CHOICE = 0
    ld a,0
    ld (CHOICE),a
; if ROLL < WEIGHT0:
    ld a,(ROLL)
    ld b,a
    ld a,(WEIGHT0)
    ld c,a
    ld a,b
    cp c
    jp c,weighted_choice_L13
    jp weighted_choice_L14
weighted_choice_L13:
; return
    ret
    jp weighted_choice_L15
weighted_choice_L14:
weighted_choice_L15:
; CHOICE = 1
    ld a,1
    ld (CHOICE),a
; if ROLL < T0:
    ld a,(ROLL)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp c,weighted_choice_L16
    jp weighted_choice_L17
weighted_choice_L16:
; return
    ret
    jp weighted_choice_L18
weighted_choice_L17:
weighted_choice_L18:
; CHOICE = 2
    ld a,2
    ld (CHOICE),a
    ret
component_end:
