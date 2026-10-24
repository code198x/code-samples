; SPDX-License-Identifier: MIT
; Interpolate Between Byte Endpoints. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
byte_interpolation_init:
    move.b #0,d0
    move.b d0,VALUE
    move.b d0,START
    move.b d0,END
    move.b d0,FRACTION
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T4
    move.b d0,T5
    move.b d0,T6
    move.b d0,T7
    move.b d0,T8
    move.b d0,T9
    move.b d0,T10
    move.b d0,T11
    rts
byte_interpolation_step:
; T10 = 0
    move.b #0,d0
    move.b d0,T10
; if END >= START:
    move.b END,d0
    move.b START,d1
    cmp.b d1,d0
    bcc byte_interpolation_L1
    jmp byte_interpolation_L2
byte_interpolation_L1:
; T11 = END - START
    move.b END,d0
    move.b START,d1
    sub.b d1,d0
    move.b d0,T11
    jmp byte_interpolation_L3
byte_interpolation_L2:
; T11 = START - END
    move.b START,d0
    move.b END,d1
    sub.b d1,d0
    move.b d0,T11
; T10 = 1
    move.b #1,d0
    move.b d0,T10
byte_interpolation_L3:
; T4 = T11
    move.b T11,d0
    move.b d0,T4
; T5 = 0
    move.b #0,d0
    move.b d0,T5
; T1 = FRACTION
    move.b FRACTION,d0
    move.b d0,T1
; T6 = 0
    move.b #0,d0
    move.b d0,T6
; T7 = 0
    move.b #0,d0
    move.b d0,T7
; T0 = 8
    move.b #8,d0
    move.b d0,T0
; while T0 != 0:
byte_interpolation_L4:
    move.b T0,d0
    cmp.b #0,d0
    bne byte_interpolation_L5
    jmp byte_interpolation_L6
byte_interpolation_L5:
; T9 = T1 & 1
    move.b T1,d0
    and.b #1,d0
    move.b d0,T9
; if T9 != 0:
    move.b T9,d0
    cmp.b #0,d0
    bne byte_interpolation_L7
    jmp byte_interpolation_L8
byte_interpolation_L7:
; T8 = T6
    move.b T6,d0
    move.b d0,T8
; T6 = T6 + T4
    move.b T6,d0
    move.b T4,d1
    add.b d1,d0
    move.b d0,T6
; T9 = 0
    move.b #0,d0
    move.b d0,T9
; if T6 < T8:
    move.b T6,d0
    move.b T8,d1
    cmp.b d1,d0
    bcs byte_interpolation_L10
    jmp byte_interpolation_L11
byte_interpolation_L10:
; T9 = 1
    move.b #1,d0
    move.b d0,T9
    jmp byte_interpolation_L12
byte_interpolation_L11:
byte_interpolation_L12:
; T7 = T7 + T5
    move.b T7,d0
    move.b T5,d1
    add.b d1,d0
    move.b d0,T7
; T7 = T7 + T9
    move.b T7,d0
    move.b T9,d1
    add.b d1,d0
    move.b d0,T7
    jmp byte_interpolation_L9
byte_interpolation_L8:
byte_interpolation_L9:
; T9 = T4 >> 7
    move.b T4,d0
    lsr.b #7,d0
    move.b d0,T9
; T4 = T4 << 1
    move.b T4,d0
    lsl.b #1,d0
    move.b d0,T4
; T5 = T5 << 1
    move.b T5,d0
    lsl.b #1,d0
    move.b d0,T5
; T5 = T5 | T9
    move.b T5,d0
    move.b T9,d1
    or.b d1,d0
    move.b d0,T5
; T1 = T1 >> 1
    move.b T1,d0
    lsr.b #1,d0
    move.b d0,T1
; T0 = T0 - 1
    move.b T0,d0
    sub.b #1,d0
    move.b d0,T0
    jmp byte_interpolation_L4
byte_interpolation_L6:
; T2 = 0
    move.b #0,d0
    move.b d0,T2
; while T7 != 0:
byte_interpolation_L13:
    move.b T7,d0
    cmp.b #0,d0
    bne byte_interpolation_L14
    jmp byte_interpolation_L15
byte_interpolation_L14:
; T8 = 0
    move.b #0,d0
    move.b d0,T8
; if T6 < 255:
    move.b T6,d0
    cmp.b #255,d0
    bcs byte_interpolation_L16
    jmp byte_interpolation_L17
byte_interpolation_L16:
; T8 = 1
    move.b #1,d0
    move.b d0,T8
    jmp byte_interpolation_L18
byte_interpolation_L17:
byte_interpolation_L18:
; T6 = T6 - 255
    move.b T6,d0
    sub.b #255,d0
    move.b d0,T6
; T7 = T7 - T8
    move.b T7,d0
    move.b T8,d1
    sub.b d1,d0
    move.b d0,T7
; T2 = T2 + 1
    move.b T2,d0
    add.b #1,d0
    move.b d0,T2
    jmp byte_interpolation_L13
byte_interpolation_L15:
; if T6 == 255:
    move.b T6,d0
    cmp.b #255,d0
    beq byte_interpolation_L19
    jmp byte_interpolation_L20
byte_interpolation_L19:
; T2 = T2 + 1
    move.b T2,d0
    add.b #1,d0
    move.b d0,T2
    jmp byte_interpolation_L21
byte_interpolation_L20:
byte_interpolation_L21:
; VALUE = START
    move.b START,d0
    move.b d0,VALUE
; if T10 == 0:
    move.b T10,d0
    cmp.b #0,d0
    beq byte_interpolation_L22
    jmp byte_interpolation_L23
byte_interpolation_L22:
; VALUE = VALUE + T2
    move.b VALUE,d0
    move.b T2,d1
    add.b d1,d0
    move.b d0,VALUE
    jmp byte_interpolation_L24
byte_interpolation_L23:
; VALUE = VALUE - T2
    move.b VALUE,d0
    move.b T2,d1
    sub.b d1,d0
    move.b d0,VALUE
byte_interpolation_L24:
    rts
component_end:
