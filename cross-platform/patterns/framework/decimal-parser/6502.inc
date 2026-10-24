; SPDX-License-Identifier: MIT
; Parse a Bounded Decimal Number. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
decimal_parser_init:
    lda #0
    sta VALUE
    sta CHARACTER
    sta STATUS
    sta T0
    sta T1
    sta T2
    rts
decimal_parser_step:
; STATUS = 2
    lda #2
    sta STATUS
; if CHARACTER < 48:
    lda CHARACTER
    cmp #48
    bcc decimal_parser_L4
decimal_parser_L5:
    jmp decimal_parser_L2
decimal_parser_L4:
    jmp decimal_parser_L1
decimal_parser_L1:
; return
    rts
    jmp decimal_parser_L3
decimal_parser_L2:
decimal_parser_L3:
; if CHARACTER > 57:
    lda CHARACTER
    cmp #57
    beq decimal_parser_L10
    bcs decimal_parser_L9
decimal_parser_L10:
    jmp decimal_parser_L7
decimal_parser_L9:
    jmp decimal_parser_L6
decimal_parser_L6:
; return
    rts
    jmp decimal_parser_L8
decimal_parser_L7:
decimal_parser_L8:
; T0 = CHARACTER - 48
    lda CHARACTER
    sec
    sbc #48
    sta T0
; STATUS = 3
    lda #3
    sta STATUS
; if VALUE > 25:
    lda VALUE
    cmp #25
    beq decimal_parser_L15
    bcs decimal_parser_L14
decimal_parser_L15:
    jmp decimal_parser_L12
decimal_parser_L14:
    jmp decimal_parser_L11
decimal_parser_L11:
; return
    rts
    jmp decimal_parser_L13
decimal_parser_L12:
decimal_parser_L13:
; if VALUE == 25:
    lda VALUE
    cmp #25
    beq decimal_parser_L19
decimal_parser_L20:
    jmp decimal_parser_L17
decimal_parser_L19:
    jmp decimal_parser_L16
decimal_parser_L16:
; if T0 > 5:
    lda T0
    cmp #5
    beq decimal_parser_L25
    bcs decimal_parser_L24
decimal_parser_L25:
    jmp decimal_parser_L22
decimal_parser_L24:
    jmp decimal_parser_L21
decimal_parser_L21:
; return
    rts
    jmp decimal_parser_L23
decimal_parser_L22:
decimal_parser_L23:
    jmp decimal_parser_L18
decimal_parser_L17:
decimal_parser_L18:
; T1 = VALUE << 1
    lda VALUE
    asl
    sta T1
; T2 = VALUE << 3
    lda VALUE
    asl
    asl
    asl
    sta T2
; T1 = T1 + T2
    lda T1
    clc
    adc T2
    sta T1
; VALUE = T1 + T0
    lda T1
    clc
    adc T0
    sta VALUE
; STATUS = 1
    lda #1
    sta STATUS
    rts
component_end:
