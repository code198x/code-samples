; SPDX-License-Identifier: MIT
; Interpolate Between Byte Endpoints. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
byte_interpolation_init:
    lda #0
    sta VALUE
    sta START
    sta END
    sta FRACTION
    sta T0
    sta T1
    sta T2
    sta T4
    sta T5
    sta T6
    sta T7
    sta T8
    sta T9
    sta T10
    sta T11
    rts
byte_interpolation_step:
; T10 = 0
    lda #0
    sta T10
; if END >= START:
    lda END
    cmp START
    bcs byte_interpolation_L4
byte_interpolation_L5:
    jmp byte_interpolation_L2
byte_interpolation_L4:
    jmp byte_interpolation_L1
byte_interpolation_L1:
; T11 = END - START
    lda END
    sec
    sbc START
    sta T11
    jmp byte_interpolation_L3
byte_interpolation_L2:
; T11 = START - END
    lda START
    sec
    sbc END
    sta T11
; T10 = 1
    lda #1
    sta T10
byte_interpolation_L3:
; T4 = T11
    lda T11
    sta T4
; T5 = 0
    lda #0
    sta T5
; T1 = FRACTION
    lda FRACTION
    sta T1
; T6 = 0
    lda #0
    sta T6
; T7 = 0
    lda #0
    sta T7
; T0 = 8
    lda #8
    sta T0
; while T0 != 0:
byte_interpolation_L6:
    lda T0
    cmp #0
    bne byte_interpolation_L9
byte_interpolation_L10:
    jmp byte_interpolation_L8
byte_interpolation_L9:
    jmp byte_interpolation_L7
byte_interpolation_L7:
; T9 = T1 & 1
    lda T1
    and #1
    sta T9
; if T9 != 0:
    lda T9
    cmp #0
    bne byte_interpolation_L14
byte_interpolation_L15:
    jmp byte_interpolation_L12
byte_interpolation_L14:
    jmp byte_interpolation_L11
byte_interpolation_L11:
; T8 = T6
    lda T6
    sta T8
; T6 = T6 + T4
    lda T6
    clc
    adc T4
    sta T6
; T9 = 0
    lda #0
    sta T9
; if T6 < T8:
    lda T6
    cmp T8
    bcc byte_interpolation_L19
byte_interpolation_L20:
    jmp byte_interpolation_L17
byte_interpolation_L19:
    jmp byte_interpolation_L16
byte_interpolation_L16:
; T9 = 1
    lda #1
    sta T9
    jmp byte_interpolation_L18
byte_interpolation_L17:
byte_interpolation_L18:
; T7 = T7 + T5
    lda T7
    clc
    adc T5
    sta T7
; T7 = T7 + T9
    lda T7
    clc
    adc T9
    sta T7
    jmp byte_interpolation_L13
byte_interpolation_L12:
byte_interpolation_L13:
; T9 = T4 >> 7
    lda T4
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    sta T9
; T4 = T4 << 1
    lda T4
    asl
    sta T4
; T5 = T5 << 1
    lda T5
    asl
    sta T5
; T5 = T5 | T9
    lda T5
    ora T9
    sta T5
; T1 = T1 >> 1
    lda T1
    lsr
    sta T1
; T0 = T0 - 1
    lda T0
    sec
    sbc #1
    sta T0
    jmp byte_interpolation_L6
byte_interpolation_L8:
; T2 = 0
    lda #0
    sta T2
; while T7 != 0:
byte_interpolation_L21:
    lda T7
    cmp #0
    bne byte_interpolation_L24
byte_interpolation_L25:
    jmp byte_interpolation_L23
byte_interpolation_L24:
    jmp byte_interpolation_L22
byte_interpolation_L22:
; T8 = 0
    lda #0
    sta T8
; if T6 < 255:
    lda T6
    cmp #255
    bcc byte_interpolation_L29
byte_interpolation_L30:
    jmp byte_interpolation_L27
byte_interpolation_L29:
    jmp byte_interpolation_L26
byte_interpolation_L26:
; T8 = 1
    lda #1
    sta T8
    jmp byte_interpolation_L28
byte_interpolation_L27:
byte_interpolation_L28:
; T6 = T6 - 255
    lda T6
    sec
    sbc #255
    sta T6
; T7 = T7 - T8
    lda T7
    sec
    sbc T8
    sta T7
; T2 = T2 + 1
    lda T2
    clc
    adc #1
    sta T2
    jmp byte_interpolation_L21
byte_interpolation_L23:
; if T6 == 255:
    lda T6
    cmp #255
    beq byte_interpolation_L34
byte_interpolation_L35:
    jmp byte_interpolation_L32
byte_interpolation_L34:
    jmp byte_interpolation_L31
byte_interpolation_L31:
; T2 = T2 + 1
    lda T2
    clc
    adc #1
    sta T2
    jmp byte_interpolation_L33
byte_interpolation_L32:
byte_interpolation_L33:
; VALUE = START
    lda START
    sta VALUE
; if T10 == 0:
    lda T10
    cmp #0
    beq byte_interpolation_L39
byte_interpolation_L40:
    jmp byte_interpolation_L37
byte_interpolation_L39:
    jmp byte_interpolation_L36
byte_interpolation_L36:
; VALUE = VALUE + T2
    lda VALUE
    clc
    adc T2
    sta VALUE
    jmp byte_interpolation_L38
byte_interpolation_L37:
; VALUE = VALUE - T2
    lda VALUE
    sec
    sbc T2
    sta VALUE
byte_interpolation_L38:
    rts
component_end:
