; SPDX-License-Identifier: MIT
; Format a 16-bit Decimal Number. Bind these contiguous private bytes: VALUE_LO, VALUE_HI, DIGIT0, DIGIT1, DIGIT2, DIGIT3, DIGIT4, WORK_LO, WORK_HI.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; A/X/flags may change; Y and decimal mode survive. Binary arithmetic requires D=0.
decimal_format_init:
    lda #0
    sta VALUE_LO
    sta VALUE_HI
    sta DIGIT0
    sta DIGIT1
    sta DIGIT2
    sta DIGIT3
    sta DIGIT4
    sta WORK_LO
    sta WORK_HI
    rts
decimal_format_step:
    lda VALUE_LO
    sta WORK_LO
    lda VALUE_HI
    sta WORK_HI
    lda #48
    sta DIGIT0
format_0:
    lda WORK_HI
    cmp #39
    bcc format_next_0
    bne format_sub_0
    lda WORK_LO
    cmp #16
    bcc format_next_0
format_sub_0:
    lda WORK_LO
    sec
    sbc #16
    sta WORK_LO
    lda WORK_HI
    sbc #39
    sta WORK_HI
    inc DIGIT0
    jmp format_0
format_next_0:
    lda #48
    sta DIGIT1
format_1:
    lda WORK_HI
    cmp #3
    bcc format_next_1
    bne format_sub_1
    lda WORK_LO
    cmp #232
    bcc format_next_1
format_sub_1:
    lda WORK_LO
    sec
    sbc #232
    sta WORK_LO
    lda WORK_HI
    sbc #3
    sta WORK_HI
    inc DIGIT1
    jmp format_1
format_next_1:
    lda #48
    sta DIGIT2
format_2:
    lda WORK_HI
    cmp #0
    bcc format_next_2
    bne format_sub_2
    lda WORK_LO
    cmp #100
    bcc format_next_2
format_sub_2:
    lda WORK_LO
    sec
    sbc #100
    sta WORK_LO
    lda WORK_HI
    sbc #0
    sta WORK_HI
    inc DIGIT2
    jmp format_2
format_next_2:
    lda #48
    sta DIGIT3
format_3:
    lda WORK_HI
    cmp #0
    bcc format_next_3
    bne format_sub_3
    lda WORK_LO
    cmp #10
    bcc format_next_3
format_sub_3:
    lda WORK_LO
    sec
    sbc #10
    sta WORK_LO
    lda WORK_HI
    sbc #0
    sta WORK_HI
    inc DIGIT3
    jmp format_3
format_next_3:
    lda #48
    sta DIGIT4
format_4:
    lda WORK_HI
    cmp #0
    bcc format_next_4
    bne format_sub_4
    lda WORK_LO
    cmp #1
    bcc format_next_4
format_sub_4:
    lda WORK_LO
    sec
    sbc #1
    sta WORK_LO
    lda WORK_HI
    sbc #0
    sta WORK_HI
    inc DIGIT4
    jmp format_4
format_next_4:
    rts
component_end:
