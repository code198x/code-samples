; SPDX-License-Identifier: MIT
; Format a Byte as Hexadecimal. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
hexadecimal_format_init:
    ld a,0
    ld (HIGH_CHAR),a
    ld (LOW_CHAR),a
    ld (VALUE),a
    ld (LOWERCASE),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ret
hexadecimal_format_step:
; T0 = VALUE >> 4
    ld a,(VALUE)
    srl a
    srl a
    srl a
    srl a
    ld (T0),a
; T1 = VALUE & 15
    ld a,(VALUE)
    and 15
    ld (T1),a
; HIGH_CHAR = T0 + 48
    ld a,(T0)
    add a,48
    ld (HIGH_CHAR),a
; LOW_CHAR = T1 + 48
    ld a,(T1)
    add a,48
    ld (LOW_CHAR),a
; T2 = 55
    ld a,55
    ld (T2),a
; if LOWERCASE != 0:
    ld a,(LOWERCASE)
    cp 0
    jp nz,hexadecimal_format_L1
    jp hexadecimal_format_L2
hexadecimal_format_L1:
; T2 = 87
    ld a,87
    ld (T2),a
    jp hexadecimal_format_L3
hexadecimal_format_L2:
hexadecimal_format_L3:
; if T0 >= 10:
    ld a,(T0)
    cp 10
    jp nc,hexadecimal_format_L4
    jp hexadecimal_format_L5
hexadecimal_format_L4:
; HIGH_CHAR = T0 + T2
    ld a,(T0)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    add a,c
    ld (HIGH_CHAR),a
    jp hexadecimal_format_L6
hexadecimal_format_L5:
hexadecimal_format_L6:
; if T1 >= 10:
    ld a,(T1)
    cp 10
    jp nc,hexadecimal_format_L7
    jp hexadecimal_format_L8
hexadecimal_format_L7:
; LOW_CHAR = T1 + T2
    ld a,(T1)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    add a,c
    ld (LOW_CHAR),a
    jp hexadecimal_format_L9
hexadecimal_format_L8:
hexadecimal_format_L9:
    ret
component_end:
