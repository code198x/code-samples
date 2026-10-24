; SPDX-License-Identifier: MIT
; Parse Two Hexadecimal Digits. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
hexadecimal_parser_init:
    move.b #0,d0
    move.b d0,VALUE
    move.b d0,VALID
    move.b d0,FIRST
    move.b d0,SECOND
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    rts
hexadecimal_parser_step:
; VALUE = 0
    move.b #0,d0
    move.b d0,VALUE
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; while T0 < 2:
hexadecimal_parser_L1:
    move.b T0,d0
    cmp.b #2,d0
    bcs hexadecimal_parser_L2
    jmp hexadecimal_parser_L3
hexadecimal_parser_L2:
; T1 = FIRST
    move.b FIRST,d0
    move.b d0,T1
; if T0 != 0:
    move.b T0,d0
    cmp.b #0,d0
    bne hexadecimal_parser_L4
    jmp hexadecimal_parser_L5
hexadecimal_parser_L4:
; T1 = SECOND
    move.b SECOND,d0
    move.b d0,T1
    jmp hexadecimal_parser_L6
hexadecimal_parser_L5:
hexadecimal_parser_L6:
; T2 = 255
    move.b #255,d0
    move.b d0,T2
; if T1 >= 48:
    move.b T1,d0
    cmp.b #48,d0
    bcc hexadecimal_parser_L7
    jmp hexadecimal_parser_L8
hexadecimal_parser_L7:
; if T1 <= 57:
    move.b T1,d0
    cmp.b #57,d0
    bls hexadecimal_parser_L10
    jmp hexadecimal_parser_L11
hexadecimal_parser_L10:
; T2 = T1 - 48
    move.b T1,d0
    sub.b #48,d0
    move.b d0,T2
    jmp hexadecimal_parser_L12
hexadecimal_parser_L11:
hexadecimal_parser_L12:
    jmp hexadecimal_parser_L9
hexadecimal_parser_L8:
hexadecimal_parser_L9:
; if T1 >= 65:
    move.b T1,d0
    cmp.b #65,d0
    bcc hexadecimal_parser_L13
    jmp hexadecimal_parser_L14
hexadecimal_parser_L13:
; if T1 <= 70:
    move.b T1,d0
    cmp.b #70,d0
    bls hexadecimal_parser_L16
    jmp hexadecimal_parser_L17
hexadecimal_parser_L16:
; T2 = T1 - 55
    move.b T1,d0
    sub.b #55,d0
    move.b d0,T2
    jmp hexadecimal_parser_L18
hexadecimal_parser_L17:
hexadecimal_parser_L18:
    jmp hexadecimal_parser_L15
hexadecimal_parser_L14:
hexadecimal_parser_L15:
; if T1 >= 97:
    move.b T1,d0
    cmp.b #97,d0
    bcc hexadecimal_parser_L19
    jmp hexadecimal_parser_L20
hexadecimal_parser_L19:
; if T1 <= 102:
    move.b T1,d0
    cmp.b #102,d0
    bls hexadecimal_parser_L22
    jmp hexadecimal_parser_L23
hexadecimal_parser_L22:
; T2 = T1 - 87
    move.b T1,d0
    sub.b #87,d0
    move.b d0,T2
    jmp hexadecimal_parser_L24
hexadecimal_parser_L23:
hexadecimal_parser_L24:
    jmp hexadecimal_parser_L21
hexadecimal_parser_L20:
hexadecimal_parser_L21:
; if T2 == 255:
    move.b T2,d0
    cmp.b #255,d0
    beq hexadecimal_parser_L25
    jmp hexadecimal_parser_L26
hexadecimal_parser_L25:
; VALUE = 0
    move.b #0,d0
    move.b d0,VALUE
; return
    rts
    jmp hexadecimal_parser_L27
hexadecimal_parser_L26:
hexadecimal_parser_L27:
; VALUE = VALUE << 4
    move.b VALUE,d0
    lsl.b #4,d0
    move.b d0,VALUE
; VALUE = VALUE | T2
    move.b VALUE,d0
    move.b T2,d1
    or.b d1,d0
    move.b d0,VALUE
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp hexadecimal_parser_L1
hexadecimal_parser_L3:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
    rts
component_end:
