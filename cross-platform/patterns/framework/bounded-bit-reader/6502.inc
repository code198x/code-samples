; SPDX-License-Identifier: MIT
; Read Bits from a Bounded Data Block. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_bit_reader_init:
    lda #0
    sta VALUE
    sta VALID
    sta CURSOR
    sta COUNT
    sta B0
    sta B1
    sta B2
    sta B3
    sta T0
    sta T1
    sta T2
    sta T3
    sta T4
    rts
bounded_bit_reader_step:
; VALUE = 0
    lda #0
    sta VALUE
; VALID = 0
    lda #0
    sta VALID
; if CURSOR > 32:
    lda CURSOR
    cmp #32
    beq bounded_bit_reader_L5
    bcs bounded_bit_reader_L4
bounded_bit_reader_L5:
    jmp bounded_bit_reader_L2
bounded_bit_reader_L4:
    jmp bounded_bit_reader_L1
bounded_bit_reader_L1:
; return
    rts
    jmp bounded_bit_reader_L3
bounded_bit_reader_L2:
bounded_bit_reader_L3:
; if COUNT > 8:
    lda COUNT
    cmp #8
    beq bounded_bit_reader_L10
    bcs bounded_bit_reader_L9
bounded_bit_reader_L10:
    jmp bounded_bit_reader_L7
bounded_bit_reader_L9:
    jmp bounded_bit_reader_L6
bounded_bit_reader_L6:
; return
    rts
    jmp bounded_bit_reader_L8
bounded_bit_reader_L7:
bounded_bit_reader_L8:
; T0 = 32 - CURSOR
    lda #32
    sec
    sbc CURSOR
    sta T0
; if COUNT > T0:
    lda COUNT
    cmp T0
    beq bounded_bit_reader_L15
    bcs bounded_bit_reader_L14
bounded_bit_reader_L15:
    jmp bounded_bit_reader_L12
bounded_bit_reader_L14:
    jmp bounded_bit_reader_L11
bounded_bit_reader_L11:
; return
    rts
    jmp bounded_bit_reader_L13
bounded_bit_reader_L12:
bounded_bit_reader_L13:
; VALID = 1
    lda #1
    sta VALID
; T0 = COUNT
    lda COUNT
    sta T0
; while T0 != 0:
bounded_bit_reader_L16:
    lda T0
    cmp #0
    bne bounded_bit_reader_L19
bounded_bit_reader_L20:
    jmp bounded_bit_reader_L18
bounded_bit_reader_L19:
    jmp bounded_bit_reader_L17
bounded_bit_reader_L17:
; T1 = CURSOR >> 3
    lda CURSOR
    lsr
    lsr
    lsr
    sta T1
; T2 = CURSOR & 7
    lda CURSOR
    and #7
    sta T2
; T3 = 128
    lda #128
    sta T3
; while T2 != 0:
bounded_bit_reader_L21:
    lda T2
    cmp #0
    bne bounded_bit_reader_L24
bounded_bit_reader_L25:
    jmp bounded_bit_reader_L23
bounded_bit_reader_L24:
    jmp bounded_bit_reader_L22
bounded_bit_reader_L22:
; T3 = T3 >> 1
    lda T3
    lsr
    sta T3
; T2 = T2 - 1
    lda T2
    sec
    sbc #1
    sta T2
    jmp bounded_bit_reader_L21
bounded_bit_reader_L23:
; T4 = B[T1]
    ldx T1
    lda B0,x
    sta T4
; T4 = T4 & T3
    lda T4
    and T3
    sta T4
; VALUE = VALUE << 1
    lda VALUE
    asl
    sta VALUE
; if T4 != 0:
    lda T4
    cmp #0
    bne bounded_bit_reader_L29
bounded_bit_reader_L30:
    jmp bounded_bit_reader_L27
bounded_bit_reader_L29:
    jmp bounded_bit_reader_L26
bounded_bit_reader_L26:
; VALUE = VALUE | 1
    lda VALUE
    ora #1
    sta VALUE
    jmp bounded_bit_reader_L28
bounded_bit_reader_L27:
bounded_bit_reader_L28:
; CURSOR = CURSOR + 1
    lda CURSOR
    clc
    adc #1
    sta CURSOR
; T0 = T0 - 1
    lda T0
    sec
    sbc #1
    sta T0
    jmp bounded_bit_reader_L16
bounded_bit_reader_L18:
    rts
component_end:
