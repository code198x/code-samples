; SPDX-License-Identifier: MIT
; Parse Two Hexadecimal Digits. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
hexadecimal_parser_init:
    lda #0
    sta VALUE
    sta VALID
    sta FIRST
    sta SECOND
    sta T0
    sta T1
    sta T2
    rts
hexadecimal_parser_step:
; VALUE = 0
    lda #0
    sta VALUE
; VALID = 0
    lda #0
    sta VALID
; T0 = 0
    lda #0
    sta T0
; while T0 < 2:
hexadecimal_parser_L1:
    lda T0
    cmp #2
    bcc hexadecimal_parser_L4
hexadecimal_parser_L5:
    jmp hexadecimal_parser_L3
hexadecimal_parser_L4:
    jmp hexadecimal_parser_L2
hexadecimal_parser_L2:
; T1 = FIRST
    lda FIRST
    sta T1
; if T0 != 0:
    lda T0
    cmp #0
    bne hexadecimal_parser_L9
hexadecimal_parser_L10:
    jmp hexadecimal_parser_L7
hexadecimal_parser_L9:
    jmp hexadecimal_parser_L6
hexadecimal_parser_L6:
; T1 = SECOND
    lda SECOND
    sta T1
    jmp hexadecimal_parser_L8
hexadecimal_parser_L7:
hexadecimal_parser_L8:
; T2 = 255
    lda #255
    sta T2
; if T1 >= 48:
    lda T1
    cmp #48
    bcs hexadecimal_parser_L14
hexadecimal_parser_L15:
    jmp hexadecimal_parser_L12
hexadecimal_parser_L14:
    jmp hexadecimal_parser_L11
hexadecimal_parser_L11:
; if T1 <= 57:
    lda T1
    cmp #57
    bcc hexadecimal_parser_L19
    beq hexadecimal_parser_L19
hexadecimal_parser_L20:
    jmp hexadecimal_parser_L17
hexadecimal_parser_L19:
    jmp hexadecimal_parser_L16
hexadecimal_parser_L16:
; T2 = T1 - 48
    lda T1
    sec
    sbc #48
    sta T2
    jmp hexadecimal_parser_L18
hexadecimal_parser_L17:
hexadecimal_parser_L18:
    jmp hexadecimal_parser_L13
hexadecimal_parser_L12:
hexadecimal_parser_L13:
; if T1 >= 65:
    lda T1
    cmp #65
    bcs hexadecimal_parser_L24
hexadecimal_parser_L25:
    jmp hexadecimal_parser_L22
hexadecimal_parser_L24:
    jmp hexadecimal_parser_L21
hexadecimal_parser_L21:
; if T1 <= 70:
    lda T1
    cmp #70
    bcc hexadecimal_parser_L29
    beq hexadecimal_parser_L29
hexadecimal_parser_L30:
    jmp hexadecimal_parser_L27
hexadecimal_parser_L29:
    jmp hexadecimal_parser_L26
hexadecimal_parser_L26:
; T2 = T1 - 55
    lda T1
    sec
    sbc #55
    sta T2
    jmp hexadecimal_parser_L28
hexadecimal_parser_L27:
hexadecimal_parser_L28:
    jmp hexadecimal_parser_L23
hexadecimal_parser_L22:
hexadecimal_parser_L23:
; if T1 >= 97:
    lda T1
    cmp #97
    bcs hexadecimal_parser_L34
hexadecimal_parser_L35:
    jmp hexadecimal_parser_L32
hexadecimal_parser_L34:
    jmp hexadecimal_parser_L31
hexadecimal_parser_L31:
; if T1 <= 102:
    lda T1
    cmp #102
    bcc hexadecimal_parser_L39
    beq hexadecimal_parser_L39
hexadecimal_parser_L40:
    jmp hexadecimal_parser_L37
hexadecimal_parser_L39:
    jmp hexadecimal_parser_L36
hexadecimal_parser_L36:
; T2 = T1 - 87
    lda T1
    sec
    sbc #87
    sta T2
    jmp hexadecimal_parser_L38
hexadecimal_parser_L37:
hexadecimal_parser_L38:
    jmp hexadecimal_parser_L33
hexadecimal_parser_L32:
hexadecimal_parser_L33:
; if T2 == 255:
    lda T2
    cmp #255
    beq hexadecimal_parser_L44
hexadecimal_parser_L45:
    jmp hexadecimal_parser_L42
hexadecimal_parser_L44:
    jmp hexadecimal_parser_L41
hexadecimal_parser_L41:
; VALUE = 0
    lda #0
    sta VALUE
; return
    rts
    jmp hexadecimal_parser_L43
hexadecimal_parser_L42:
hexadecimal_parser_L43:
; VALUE = VALUE << 4
    lda VALUE
    asl
    asl
    asl
    asl
    sta VALUE
; VALUE = VALUE | T2
    lda VALUE
    ora T2
    sta VALUE
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp hexadecimal_parser_L1
hexadecimal_parser_L3:
; VALID = 1
    lda #1
    sta VALID
    rts
component_end:
