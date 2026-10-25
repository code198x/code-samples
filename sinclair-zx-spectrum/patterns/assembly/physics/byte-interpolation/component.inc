; SPDX-License-Identifier: MIT
; Interpolate Between Byte Endpoints. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
byte_interpolation_init:
    ld a,0
    ld (VALUE),a
    ld (START),a
    ld (ENDPOINT),a
    ld (FRACTION),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T4),a
    ld (T5),a
    ld (T6),a
    ld (T7),a
    ld (T8),a
    ld (T9),a
    ld (T10),a
    ld (T11),a
    ret
byte_interpolation_step:
; T10 = 0
    ld a,0
    ld (T10),a
; if ENDPOINT >= START:
    ld a,(ENDPOINT)
    ld b,a
    ld a,(START)
    ld c,a
    ld a,b
    cp c
    jp nc,byte_interpolation_L1
    jp byte_interpolation_L2
byte_interpolation_L1:
; T11 = ENDPOINT - START
    ld a,(ENDPOINT)
    ld b,a
    ld a,(START)
    ld c,a
    ld a,b
    sub c
    ld (T11),a
    jp byte_interpolation_L3
byte_interpolation_L2:
; T11 = START - ENDPOINT
    ld a,(START)
    ld b,a
    ld a,(ENDPOINT)
    ld c,a
    ld a,b
    sub c
    ld (T11),a
; T10 = 1
    ld a,1
    ld (T10),a
byte_interpolation_L3:
; T4 = T11
    ld a,(T11)
    ld (T4),a
; T5 = 0
    ld a,0
    ld (T5),a
; T1 = FRACTION
    ld a,(FRACTION)
    ld (T1),a
; T6 = 0
    ld a,0
    ld (T6),a
; T7 = 0
    ld a,0
    ld (T7),a
; T0 = 8
    ld a,8
    ld (T0),a
; while T0 != 0:
byte_interpolation_L4:
    ld a,(T0)
    cp 0
    jp nz,byte_interpolation_L5
    jp byte_interpolation_L6
byte_interpolation_L5:
; T9 = T1 & 1
    ld a,(T1)
    and 1
    ld (T9),a
; if T9 != 0:
    ld a,(T9)
    cp 0
    jp nz,byte_interpolation_L7
    jp byte_interpolation_L8
byte_interpolation_L7:
; T8 = T6
    ld a,(T6)
    ld (T8),a
; T6 = T6 + T4
    ld a,(T6)
    ld b,a
    ld a,(T4)
    ld c,a
    ld a,b
    add a,c
    ld (T6),a
; T9 = 0
    ld a,0
    ld (T9),a
; if T6 < T8:
    ld a,(T6)
    ld b,a
    ld a,(T8)
    ld c,a
    ld a,b
    cp c
    jp c,byte_interpolation_L10
    jp byte_interpolation_L11
byte_interpolation_L10:
; T9 = 1
    ld a,1
    ld (T9),a
    jp byte_interpolation_L12
byte_interpolation_L11:
byte_interpolation_L12:
; T7 = T7 + T5
    ld a,(T7)
    ld b,a
    ld a,(T5)
    ld c,a
    ld a,b
    add a,c
    ld (T7),a
; T7 = T7 + T9
    ld a,(T7)
    ld b,a
    ld a,(T9)
    ld c,a
    ld a,b
    add a,c
    ld (T7),a
    jp byte_interpolation_L9
byte_interpolation_L8:
byte_interpolation_L9:
; T9 = T4 >> 7
    ld a,(T4)
    srl a
    srl a
    srl a
    srl a
    srl a
    srl a
    srl a
    ld (T9),a
; T4 = T4 << 1
    ld a,(T4)
    sla a
    ld (T4),a
; T5 = T5 << 1
    ld a,(T5)
    sla a
    ld (T5),a
; T5 = T5 | T9
    ld a,(T5)
    ld b,a
    ld a,(T9)
    ld c,a
    ld a,b
    or c
    ld (T5),a
; T1 = T1 >> 1
    ld a,(T1)
    srl a
    ld (T1),a
; T0 = T0 - 1
    ld a,(T0)
    sub 1
    ld (T0),a
    jp byte_interpolation_L4
byte_interpolation_L6:
; T2 = 0
    ld a,0
    ld (T2),a
; while T7 != 0:
byte_interpolation_L13:
    ld a,(T7)
    cp 0
    jp nz,byte_interpolation_L14
    jp byte_interpolation_L15
byte_interpolation_L14:
; T8 = 0
    ld a,0
    ld (T8),a
; if T6 < 255:
    ld a,(T6)
    cp 255
    jp c,byte_interpolation_L16
    jp byte_interpolation_L17
byte_interpolation_L16:
; T8 = 1
    ld a,1
    ld (T8),a
    jp byte_interpolation_L18
byte_interpolation_L17:
byte_interpolation_L18:
; T6 = T6 - 255
    ld a,(T6)
    sub 255
    ld (T6),a
; T7 = T7 - T8
    ld a,(T7)
    ld b,a
    ld a,(T8)
    ld c,a
    ld a,b
    sub c
    ld (T7),a
; T2 = T2 + 1
    ld a,(T2)
    add a,1
    ld (T2),a
    jp byte_interpolation_L13
byte_interpolation_L15:
; if T6 == 255:
    ld a,(T6)
    cp 255
    jp z,byte_interpolation_L19
    jp byte_interpolation_L20
byte_interpolation_L19:
; T2 = T2 + 1
    ld a,(T2)
    add a,1
    ld (T2),a
    jp byte_interpolation_L21
byte_interpolation_L20:
byte_interpolation_L21:
; VALUE = START
    ld a,(START)
    ld (VALUE),a
; if T10 == 0:
    ld a,(T10)
    cp 0
    jp z,byte_interpolation_L22
    jp byte_interpolation_L23
byte_interpolation_L22:
; VALUE = VALUE + T2
    ld a,(VALUE)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    add a,c
    ld (VALUE),a
    jp byte_interpolation_L24
byte_interpolation_L23:
; VALUE = VALUE - T2
    ld a,(VALUE)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    sub c
    ld (VALUE),a
byte_interpolation_L24:
    ret
component_end:
