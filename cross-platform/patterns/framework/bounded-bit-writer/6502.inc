; SPDX-License-Identifier: MIT
; Write Packed Bits with Bounds. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_bit_writer_init:
    lda #0
    sta VALID
    sta CURSOR
    sta COUNT
    sta VALUE
    sta B0
    sta B1
    sta B2
    sta B3
    sta T0
    sta T1
    sta T2
    sta T3
    sta T4
    sta T5
    sta T6
    sta EXPR_SAVE
    rts
bounded_bit_writer_step:
; VALID = 0
    lda #0
    sta VALID
; if COUNT > 8:
    lda COUNT
    cmp #8
    beq bounded_bit_writer_L5
    bcs bounded_bit_writer_L4
bounded_bit_writer_L5:
    jmp bounded_bit_writer_L2
bounded_bit_writer_L4:
    jmp bounded_bit_writer_L1
bounded_bit_writer_L1:
; return
    rts
    jmp bounded_bit_writer_L3
bounded_bit_writer_L2:
bounded_bit_writer_L3:
; if CURSOR > 32:
    lda CURSOR
    cmp #32
    beq bounded_bit_writer_L10
    bcs bounded_bit_writer_L9
bounded_bit_writer_L10:
    jmp bounded_bit_writer_L7
bounded_bit_writer_L9:
    jmp bounded_bit_writer_L6
bounded_bit_writer_L6:
; return
    rts
    jmp bounded_bit_writer_L8
bounded_bit_writer_L7:
bounded_bit_writer_L8:
; T0 = CURSOR + COUNT
    lda CURSOR
    clc
    adc COUNT
    sta T0
; if T0 > 32:
    lda T0
    cmp #32
    beq bounded_bit_writer_L15
    bcs bounded_bit_writer_L14
bounded_bit_writer_L15:
    jmp bounded_bit_writer_L12
bounded_bit_writer_L14:
    jmp bounded_bit_writer_L11
bounded_bit_writer_L11:
; return
    rts
    jmp bounded_bit_writer_L13
bounded_bit_writer_L12:
bounded_bit_writer_L13:
; VALID = 1
    lda #1
    sta VALID
; T0 = COUNT
    lda COUNT
    sta T0
; while T0 != 0:
bounded_bit_writer_L16:
    lda T0
    cmp #0
    bne bounded_bit_writer_L19
bounded_bit_writer_L20:
    jmp bounded_bit_writer_L18
bounded_bit_writer_L19:
    jmp bounded_bit_writer_L17
bounded_bit_writer_L17:
; T0 = T0 - 1
    lda T0
    sec
    sbc #1
    sta T0
; T1 = VALUE
    lda VALUE
    sta T1
; T2 = T0
    lda T0
    sta T2
; while T2 != 0:
bounded_bit_writer_L21:
    lda T2
    cmp #0
    bne bounded_bit_writer_L24
bounded_bit_writer_L25:
    jmp bounded_bit_writer_L23
bounded_bit_writer_L24:
    jmp bounded_bit_writer_L22
bounded_bit_writer_L22:
; T1 = T1 >> 1
    lda T1
    lsr
    sta T1
; T2 = T2 - 1
    lda T2
    sec
    sbc #1
    sta T2
    jmp bounded_bit_writer_L21
bounded_bit_writer_L23:
; T1 = T1 & 1
    lda T1
    and #1
    sta T1
; T2 = CURSOR >> 3
    lda CURSOR
    lsr
    lsr
    lsr
    sta T2
; T3 = CURSOR & 7
    lda CURSOR
    and #7
    sta T3
; T4 = 128
    lda #128
    sta T4
; while T3 != 0:
bounded_bit_writer_L26:
    lda T3
    cmp #0
    bne bounded_bit_writer_L29
bounded_bit_writer_L30:
    jmp bounded_bit_writer_L28
bounded_bit_writer_L29:
    jmp bounded_bit_writer_L27
bounded_bit_writer_L27:
; T4 = T4 >> 1
    lda T4
    lsr
    sta T4
; T3 = T3 - 1
    lda T3
    sec
    sbc #1
    sta T3
    jmp bounded_bit_writer_L26
bounded_bit_writer_L28:
; T5 = T4 ^ 255
    lda T4
    eor #255
    sta T5
; T6 = B[T2]
    ldx T2
    lda B0,x
    sta T6
; T6 = T6 & T5
    lda T6
    and T5
    sta T6
; if T1 != 0:
    lda T1
    cmp #0
    bne bounded_bit_writer_L34
bounded_bit_writer_L35:
    jmp bounded_bit_writer_L32
bounded_bit_writer_L34:
    jmp bounded_bit_writer_L31
bounded_bit_writer_L31:
; T6 = T6 | T4
    lda T6
    ora T4
    sta T6
    jmp bounded_bit_writer_L33
bounded_bit_writer_L32:
bounded_bit_writer_L33:
; B[T2] = T6
    lda T6
    sta EXPR_SAVE
    ldx T2
    lda EXPR_SAVE
    sta B0,x
; CURSOR = CURSOR + 1
    lda CURSOR
    clc
    adc #1
    sta CURSOR
    jmp bounded_bit_writer_L16
bounded_bit_writer_L18:
    rts
component_end:
