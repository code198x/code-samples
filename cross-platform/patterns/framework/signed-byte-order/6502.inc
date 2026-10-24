; SPDX-License-Identifier: MIT
; Compare Signed Byte Values. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
signed_byte_order_init:
    lda #0
    sta ORDER
    sta LEFT
    sta RIGHT
    sta T0
    sta T1
    rts
signed_byte_order_step:
; T0 = LEFT ^ 128
    lda LEFT
    eor #128
    sta T0
; T1 = RIGHT ^ 128
    lda RIGHT
    eor #128
    sta T1
; ORDER = 1
    lda #1
    sta ORDER
; if T0 < T1:
    lda T0
    cmp T1
    bcc signed_byte_order_L4
signed_byte_order_L5:
    jmp signed_byte_order_L2
signed_byte_order_L4:
    jmp signed_byte_order_L1
signed_byte_order_L1:
; ORDER = 0
    lda #0
    sta ORDER
    jmp signed_byte_order_L3
signed_byte_order_L2:
signed_byte_order_L3:
; if T0 > T1:
    lda T0
    cmp T1
    beq signed_byte_order_L10
    bcs signed_byte_order_L9
signed_byte_order_L10:
    jmp signed_byte_order_L7
signed_byte_order_L9:
    jmp signed_byte_order_L6
signed_byte_order_L6:
; ORDER = 2
    lda #2
    sta ORDER
    jmp signed_byte_order_L8
signed_byte_order_L7:
signed_byte_order_L8:
    rts
component_end:
