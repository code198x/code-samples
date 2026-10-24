; SPDX-License-Identifier: MIT
; Parse Two Hexadecimal Digits. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
hexadecimal_parser_init:
    ld a,0
    ld (VALUE),a
    ld (VALID),a
    ld (FIRST),a
    ld (SECOND),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ret
hexadecimal_parser_step:
; VALUE = 0
    ld a,0
    ld (VALUE),a
; VALID = 0
    ld a,0
    ld (VALID),a
; T0 = 0
    ld a,0
    ld (T0),a
; while T0 < 2:
hexadecimal_parser_L1:
    ld a,(T0)
    cp 2
    jp c,hexadecimal_parser_L2
    jp hexadecimal_parser_L3
hexadecimal_parser_L2:
; T1 = FIRST
    ld a,(FIRST)
    ld (T1),a
; if T0 != 0:
    ld a,(T0)
    cp 0
    jp nz,hexadecimal_parser_L4
    jp hexadecimal_parser_L5
hexadecimal_parser_L4:
; T1 = SECOND
    ld a,(SECOND)
    ld (T1),a
    jp hexadecimal_parser_L6
hexadecimal_parser_L5:
hexadecimal_parser_L6:
; T2 = 255
    ld a,255
    ld (T2),a
; if T1 >= 48:
    ld a,(T1)
    cp 48
    jp nc,hexadecimal_parser_L7
    jp hexadecimal_parser_L8
hexadecimal_parser_L7:
; if T1 <= 57:
    ld a,(T1)
    cp 57
    jp c,hexadecimal_parser_L10
    jp z,hexadecimal_parser_L10
    jp hexadecimal_parser_L11
hexadecimal_parser_L10:
; T2 = T1 - 48
    ld a,(T1)
    sub 48
    ld (T2),a
    jp hexadecimal_parser_L12
hexadecimal_parser_L11:
hexadecimal_parser_L12:
    jp hexadecimal_parser_L9
hexadecimal_parser_L8:
hexadecimal_parser_L9:
; if T1 >= 65:
    ld a,(T1)
    cp 65
    jp nc,hexadecimal_parser_L13
    jp hexadecimal_parser_L14
hexadecimal_parser_L13:
; if T1 <= 70:
    ld a,(T1)
    cp 70
    jp c,hexadecimal_parser_L16
    jp z,hexadecimal_parser_L16
    jp hexadecimal_parser_L17
hexadecimal_parser_L16:
; T2 = T1 - 55
    ld a,(T1)
    sub 55
    ld (T2),a
    jp hexadecimal_parser_L18
hexadecimal_parser_L17:
hexadecimal_parser_L18:
    jp hexadecimal_parser_L15
hexadecimal_parser_L14:
hexadecimal_parser_L15:
; if T1 >= 97:
    ld a,(T1)
    cp 97
    jp nc,hexadecimal_parser_L19
    jp hexadecimal_parser_L20
hexadecimal_parser_L19:
; if T1 <= 102:
    ld a,(T1)
    cp 102
    jp c,hexadecimal_parser_L22
    jp z,hexadecimal_parser_L22
    jp hexadecimal_parser_L23
hexadecimal_parser_L22:
; T2 = T1 - 87
    ld a,(T1)
    sub 87
    ld (T2),a
    jp hexadecimal_parser_L24
hexadecimal_parser_L23:
hexadecimal_parser_L24:
    jp hexadecimal_parser_L21
hexadecimal_parser_L20:
hexadecimal_parser_L21:
; if T2 == 255:
    ld a,(T2)
    cp 255
    jp z,hexadecimal_parser_L25
    jp hexadecimal_parser_L26
hexadecimal_parser_L25:
; VALUE = 0
    ld a,0
    ld (VALUE),a
; return
    ret
    jp hexadecimal_parser_L27
hexadecimal_parser_L26:
hexadecimal_parser_L27:
; VALUE = VALUE << 4
    ld a,(VALUE)
    sla a
    sla a
    sla a
    sla a
    ld (VALUE),a
; VALUE = VALUE | T2
    ld a,(VALUE)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    or c
    ld (VALUE),a
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp hexadecimal_parser_L1
hexadecimal_parser_L3:
; VALID = 1
    ld a,1
    ld (VALID),a
    ret
component_end:
