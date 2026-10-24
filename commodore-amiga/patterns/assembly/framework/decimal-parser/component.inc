; SPDX-License-Identifier: MIT
; Parse a Bounded Decimal Number. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
decimal_parser_init:
    move.b #0,d0
    move.b d0,VALUE
    move.b d0,CHARACTER
    move.b d0,STATUS
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    rts
decimal_parser_step:
; STATUS = 2
    move.b #2,d0
    move.b d0,STATUS
; if CHARACTER < 48:
    move.b CHARACTER,d0
    cmp.b #48,d0
    bcs decimal_parser_L1
    jmp decimal_parser_L2
decimal_parser_L1:
; return
    rts
    jmp decimal_parser_L3
decimal_parser_L2:
decimal_parser_L3:
; if CHARACTER > 57:
    move.b CHARACTER,d0
    cmp.b #57,d0
    bhi decimal_parser_L4
    jmp decimal_parser_L5
decimal_parser_L4:
; return
    rts
    jmp decimal_parser_L6
decimal_parser_L5:
decimal_parser_L6:
; T0 = CHARACTER - 48
    move.b CHARACTER,d0
    sub.b #48,d0
    move.b d0,T0
; STATUS = 3
    move.b #3,d0
    move.b d0,STATUS
; if VALUE > 25:
    move.b VALUE,d0
    cmp.b #25,d0
    bhi decimal_parser_L7
    jmp decimal_parser_L8
decimal_parser_L7:
; return
    rts
    jmp decimal_parser_L9
decimal_parser_L8:
decimal_parser_L9:
; if VALUE == 25:
    move.b VALUE,d0
    cmp.b #25,d0
    beq decimal_parser_L10
    jmp decimal_parser_L11
decimal_parser_L10:
; if T0 > 5:
    move.b T0,d0
    cmp.b #5,d0
    bhi decimal_parser_L13
    jmp decimal_parser_L14
decimal_parser_L13:
; return
    rts
    jmp decimal_parser_L15
decimal_parser_L14:
decimal_parser_L15:
    jmp decimal_parser_L12
decimal_parser_L11:
decimal_parser_L12:
; T1 = VALUE << 1
    move.b VALUE,d0
    lsl.b #1,d0
    move.b d0,T1
; T2 = VALUE << 3
    move.b VALUE,d0
    lsl.b #3,d0
    move.b d0,T2
; T1 = T1 + T2
    move.b T1,d0
    move.b T2,d1
    add.b d1,d0
    move.b d0,T1
; VALUE = T1 + T0
    move.b T1,d0
    move.b T0,d1
    add.b d1,d0
    move.b d0,VALUE
; STATUS = 1
    move.b #1,d0
    move.b d0,STATUS
    rts
component_end:
