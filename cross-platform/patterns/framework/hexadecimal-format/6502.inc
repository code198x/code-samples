; SPDX-License-Identifier: MIT
; Format a Byte as Hexadecimal. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
hexadecimal_format_init:
    lda #0
    sta HIGH_CHAR
    sta LOW_CHAR
    sta VALUE
    sta LOWERCASE
    sta T0
    sta T1
    sta T2
    rts
hexadecimal_format_step:
; T0 = VALUE >> 4
    lda VALUE
    lsr
    lsr
    lsr
    lsr
    sta T0
; T1 = VALUE & 15
    lda VALUE
    and #15
    sta T1
; HIGH_CHAR = T0 + 48
    lda T0
    clc
    adc #48
    sta HIGH_CHAR
; LOW_CHAR = T1 + 48
    lda T1
    clc
    adc #48
    sta LOW_CHAR
; T2 = 55
    lda #55
    sta T2
; if LOWERCASE != 0:
    lda LOWERCASE
    cmp #0
    bne hexadecimal_format_L4
hexadecimal_format_L5:
    jmp hexadecimal_format_L2
hexadecimal_format_L4:
    jmp hexadecimal_format_L1
hexadecimal_format_L1:
; T2 = 87
    lda #87
    sta T2
    jmp hexadecimal_format_L3
hexadecimal_format_L2:
hexadecimal_format_L3:
; if T0 >= 10:
    lda T0
    cmp #10
    bcs hexadecimal_format_L9
hexadecimal_format_L10:
    jmp hexadecimal_format_L7
hexadecimal_format_L9:
    jmp hexadecimal_format_L6
hexadecimal_format_L6:
; HIGH_CHAR = T0 + T2
    lda T0
    clc
    adc T2
    sta HIGH_CHAR
    jmp hexadecimal_format_L8
hexadecimal_format_L7:
hexadecimal_format_L8:
; if T1 >= 10:
    lda T1
    cmp #10
    bcs hexadecimal_format_L14
hexadecimal_format_L15:
    jmp hexadecimal_format_L12
hexadecimal_format_L14:
    jmp hexadecimal_format_L11
hexadecimal_format_L11:
; LOW_CHAR = T1 + T2
    lda T1
    clc
    adc T2
    sta LOW_CHAR
    jmp hexadecimal_format_L13
hexadecimal_format_L12:
hexadecimal_format_L13:
    rts
component_end:
