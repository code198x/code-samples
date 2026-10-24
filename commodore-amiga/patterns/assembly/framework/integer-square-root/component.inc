; SPDX-License-Identifier: MIT
; Find an Integer Square Root. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
integer_square_root_init:
    move.b #0,d0
    move.b d0,ROOT
    move.b d0,REMAINDER_LO
    move.b d0,REMAINDER_HI
    move.b d0,NUMBER_LO
    move.b d0,NUMBER_HI
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    rts
integer_square_root_step:
; ROOT = 0
    move.b #0,d0
    move.b d0,ROOT
; REMAINDER_LO = NUMBER_LO
    move.b NUMBER_LO,d0
    move.b d0,REMAINDER_LO
; REMAINDER_HI = NUMBER_HI
    move.b NUMBER_HI,d0
    move.b d0,REMAINDER_HI
; T0 = 1
    move.b #1,d0
    move.b d0,T0
; T1 = 0
    move.b #0,d0
    move.b d0,T1
; T2 = 1
    move.b #1,d0
    move.b d0,T2
; while T2 == 1:
integer_square_root_L1:
    move.b T2,d0
    cmp.b #1,d0
    beq integer_square_root_L2
    jmp integer_square_root_L3
integer_square_root_L2:
; if REMAINDER_HI < T1:
    move.b REMAINDER_HI,d0
    move.b T1,d1
    cmp.b d1,d0
    bcs integer_square_root_L4
    jmp integer_square_root_L5
integer_square_root_L4:
; return
    rts
    jmp integer_square_root_L6
integer_square_root_L5:
integer_square_root_L6:
; if REMAINDER_HI == T1:
    move.b REMAINDER_HI,d0
    move.b T1,d1
    cmp.b d1,d0
    beq integer_square_root_L7
    jmp integer_square_root_L8
integer_square_root_L7:
; if REMAINDER_LO < T0:
    move.b REMAINDER_LO,d0
    move.b T0,d1
    cmp.b d1,d0
    bcs integer_square_root_L10
    jmp integer_square_root_L11
integer_square_root_L10:
; return
    rts
    jmp integer_square_root_L12
integer_square_root_L11:
integer_square_root_L12:
    jmp integer_square_root_L9
integer_square_root_L8:
integer_square_root_L9:
; T3 = 0
    move.b #0,d0
    move.b d0,T3
; if REMAINDER_LO < T0:
    move.b REMAINDER_LO,d0
    move.b T0,d1
    cmp.b d1,d0
    bcs integer_square_root_L13
    jmp integer_square_root_L14
integer_square_root_L13:
; T3 = 1
    move.b #1,d0
    move.b d0,T3
    jmp integer_square_root_L15
integer_square_root_L14:
integer_square_root_L15:
; REMAINDER_LO = REMAINDER_LO - T0
    move.b REMAINDER_LO,d0
    move.b T0,d1
    sub.b d1,d0
    move.b d0,REMAINDER_LO
; REMAINDER_HI = REMAINDER_HI - T1
    move.b REMAINDER_HI,d0
    move.b T1,d1
    sub.b d1,d0
    move.b d0,REMAINDER_HI
; REMAINDER_HI = REMAINDER_HI - T3
    move.b REMAINDER_HI,d0
    move.b T3,d1
    sub.b d1,d0
    move.b d0,REMAINDER_HI
; ROOT = ROOT + 1
    move.b ROOT,d0
    add.b #1,d0
    move.b d0,ROOT
; T3 = T0
    move.b T0,d0
    move.b d0,T3
; T0 = T0 + 2
    move.b T0,d0
    add.b #2,d0
    move.b d0,T0
; if T0 < T3:
    move.b T0,d0
    move.b T3,d1
    cmp.b d1,d0
    bcs integer_square_root_L16
    jmp integer_square_root_L17
integer_square_root_L16:
; T1 = T1 + 1
    move.b T1,d0
    add.b #1,d0
    move.b d0,T1
    jmp integer_square_root_L18
integer_square_root_L17:
integer_square_root_L18:
    jmp integer_square_root_L1
integer_square_root_L3:
    rts
component_end:
