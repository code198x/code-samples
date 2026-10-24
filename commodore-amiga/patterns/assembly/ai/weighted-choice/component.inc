; SPDX-License-Identifier: MIT
; Choose from Weighted Outcomes. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
weighted_choice_init:
    move.b #0,d0
    move.b d0,WEIGHT0
    move.b d0,WEIGHT1
    move.b d0,WEIGHT2
    move.b d0,ROLL
    move.b d0,CHOICE
    move.b d0,TOTAL
    move.b d0,VALID
    move.b d0,T0
    move.b d0,T1
    rts
weighted_choice_step:
; CHOICE = 255
    move.b #255,d0
    move.b d0,CHOICE
; TOTAL = 0
    move.b #0,d0
    move.b d0,TOTAL
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; T0 = WEIGHT0 + WEIGHT1
    move.b WEIGHT0,d0
    move.b WEIGHT1,d1
    add.b d1,d0
    move.b d0,T0
; if T0 < WEIGHT0:
    move.b T0,d0
    move.b WEIGHT0,d1
    cmp.b d1,d0
    bcs weighted_choice_L1
    jmp weighted_choice_L2
weighted_choice_L1:
; return
    rts
    jmp weighted_choice_L3
weighted_choice_L2:
weighted_choice_L3:
; T1 = T0 + WEIGHT2
    move.b T0,d0
    move.b WEIGHT2,d1
    add.b d1,d0
    move.b d0,T1
; if T1 < T0:
    move.b T1,d0
    move.b T0,d1
    cmp.b d1,d0
    bcs weighted_choice_L4
    jmp weighted_choice_L5
weighted_choice_L4:
; return
    rts
    jmp weighted_choice_L6
weighted_choice_L5:
weighted_choice_L6:
; TOTAL = T1
    move.b T1,d0
    move.b d0,TOTAL
; if TOTAL == 0:
    move.b TOTAL,d0
    cmp.b #0,d0
    beq weighted_choice_L7
    jmp weighted_choice_L8
weighted_choice_L7:
; return
    rts
    jmp weighted_choice_L9
weighted_choice_L8:
weighted_choice_L9:
; if ROLL >= TOTAL:
    move.b ROLL,d0
    move.b TOTAL,d1
    cmp.b d1,d0
    bcc weighted_choice_L10
    jmp weighted_choice_L11
weighted_choice_L10:
; return
    rts
    jmp weighted_choice_L12
weighted_choice_L11:
weighted_choice_L12:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; CHOICE = 0
    move.b #0,d0
    move.b d0,CHOICE
; if ROLL < WEIGHT0:
    move.b ROLL,d0
    move.b WEIGHT0,d1
    cmp.b d1,d0
    bcs weighted_choice_L13
    jmp weighted_choice_L14
weighted_choice_L13:
; return
    rts
    jmp weighted_choice_L15
weighted_choice_L14:
weighted_choice_L15:
; CHOICE = 1
    move.b #1,d0
    move.b d0,CHOICE
; if ROLL < T0:
    move.b ROLL,d0
    move.b T0,d1
    cmp.b d1,d0
    bcs weighted_choice_L16
    jmp weighted_choice_L17
weighted_choice_L16:
; return
    rts
    jmp weighted_choice_L18
weighted_choice_L17:
weighted_choice_L18:
; CHOICE = 2
    move.b #2,d0
    move.b d0,CHOICE
    rts
component_end:
