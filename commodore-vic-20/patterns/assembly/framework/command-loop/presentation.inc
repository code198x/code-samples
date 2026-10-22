; Caller-owned presentation. Clears the screen and prints one counter.
; Clobbers A/X/Y, flags and print_value/print_digit; default screen channel only.
draw_count:
    lda #147
    jsr $ffd2
    lda #84
    jsr $ffd2
    lda #85
    jsr $ffd2
    lda #82
    jsr $ffd2
    lda #78
    jsr $ffd2
    lda #32
    jsr $ffd2
    lda turn_count
    sta print_value
    lda #48
    sta print_digit
hundreds:
    lda print_value
    cmp #100
    bcc emit_hundreds
    sec
    sbc #100
    sta print_value
    inc print_digit
    bne hundreds
emit_hundreds:
    lda print_digit
    jsr $ffd2
    lda #48
    sta print_digit
tens:
    lda print_value
    cmp #10
    bcc emit_tens
    sec
    sbc #10
    sta print_value
    inc print_digit
    bne tens
emit_tens:
    lda print_digit
    jsr $ffd2
    lda print_value
    clc
    adc #48
    jsr $ffd2
    lda #13
    jmp $ffd2
print_value: !byte 0
print_digit: !byte 0
