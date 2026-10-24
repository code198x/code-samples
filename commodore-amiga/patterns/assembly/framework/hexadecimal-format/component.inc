; SPDX-License-Identifier: MIT
; Format a Byte as Hexadecimal. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
hexadecimal_format_init:
    move.b #0,d0
    move.b d0,HIGH_CHAR
    move.b d0,LOW_CHAR
    move.b d0,VALUE
    move.b d0,LOWERCASE
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    rts
hexadecimal_format_step:
; T0 = VALUE >> 4
    move.b VALUE,d0
    lsr.b #4,d0
    move.b d0,T0
; T1 = VALUE & 15
    move.b VALUE,d0
    and.b #15,d0
    move.b d0,T1
; HIGH_CHAR = T0 + 48
    move.b T0,d0
    add.b #48,d0
    move.b d0,HIGH_CHAR
; LOW_CHAR = T1 + 48
    move.b T1,d0
    add.b #48,d0
    move.b d0,LOW_CHAR
; T2 = 55
    move.b #55,d0
    move.b d0,T2
; if LOWERCASE != 0:
    move.b LOWERCASE,d0
    cmp.b #0,d0
    bne hexadecimal_format_L1
    jmp hexadecimal_format_L2
hexadecimal_format_L1:
; T2 = 87
    move.b #87,d0
    move.b d0,T2
    jmp hexadecimal_format_L3
hexadecimal_format_L2:
hexadecimal_format_L3:
; if T0 >= 10:
    move.b T0,d0
    cmp.b #10,d0
    bcc hexadecimal_format_L4
    jmp hexadecimal_format_L5
hexadecimal_format_L4:
; HIGH_CHAR = T0 + T2
    move.b T0,d0
    move.b T2,d1
    add.b d1,d0
    move.b d0,HIGH_CHAR
    jmp hexadecimal_format_L6
hexadecimal_format_L5:
hexadecimal_format_L6:
; if T1 >= 10:
    move.b T1,d0
    cmp.b #10,d0
    bcc hexadecimal_format_L7
    jmp hexadecimal_format_L8
hexadecimal_format_L7:
; LOW_CHAR = T1 + T2
    move.b T1,d0
    move.b T2,d1
    add.b d1,d0
    move.b d0,LOW_CHAR
    jmp hexadecimal_format_L9
hexadecimal_format_L8:
hexadecimal_format_L9:
    rts
component_end:
