; SPDX-License-Identifier: MIT
; Decode Bounded RLE Data. Contiguous private bytes: WRITTEN, ERROR, INPUT_START, INPUT_END, OUTPUT_LIMIT, BUF0, BUF1, BUF2, BUF3, BUF4, BUF5, BUF6, BUF7.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; A/X/flags change; Y and decimal mode survive. D=0 for binary arithmetic.
bounded_rle_init:
    lda #0
    sta WRITTEN
    sta ERROR
    sta INPUT_START
    sta INPUT_END
    sta OUTPUT_LIMIT
    sta BUF0
    sta BUF1
    sta BUF2
    sta BUF3
    sta BUF4
    sta BUF5
    sta BUF6
    sta BUF7
    rts
bounded_rle_step:
    tya
    pha
    lda #0
    sta WRITTEN
    sta ERROR
    lda INPUT_END
    cmp #STREAM_BYTES+1
    bcs rle_bounds
    lda INPUT_START
    cmp INPUT_END
    bcc rle_check_output
    beq rle_check_output
rle_bounds:
    lda #1
    jmp rle_error
rle_check_output:
    lda OUTPUT_LIMIT
    cmp #9
    bcs rle_bounds
    ldx INPUT_START
rle_pair:
    cpx INPUT_END
    beq rle_done
    txa
    clc
    adc #1
    cmp INPUT_END
    bcs rle_truncated
    lda rle_stream,x
    beq rle_zero
    tay
    inx
    txa
    pha
    lda rle_stream,x
    ldx WRITTEN
rle_copy:
    cpx OUTPUT_LIMIT
    bcs rle_full
    sta BUF0,x
    inx
    dey
    bne rle_copy
    stx WRITTEN
    pla
    tax
    inx
    jmp rle_pair
rle_full:
    stx WRITTEN
    pla
    lda #4
    jmp rle_error
rle_truncated:
    lda #2
    jmp rle_error
rle_zero:
    lda #3
rle_error:
    sta ERROR
rle_done:
    pla
    tay
    rts
component_end:
