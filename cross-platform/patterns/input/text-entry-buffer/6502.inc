; SPDX-License-Identifier: MIT
; A Counted Text-entry Buffer. Contiguous private bytes: LENGTH, STATUS, KEY, MODE, BUF0, BUF1, BUF2, BUF3, BUF4, BUF5, BUF6, BUF7.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; A/X/flags change; Y and decimal mode survive. D=0 for binary arithmetic.
text_entry_buffer_init:
    lda #0
    sta LENGTH
    sta STATUS
    sta KEY
    sta MODE
    sta BUF0
    sta BUF1
    sta BUF2
    sta BUF3
    sta BUF4
    sta BUF5
    sta BUF6
    sta BUF7
    rts
text_entry_buffer_step:
    lda #0
    sta STATUS
    lda MODE
    cmp #2
    beq text_clear
    lda LENGTH
    cmp #TEXT_CAP
    bcc text_mode
    beq text_mode
    jmp text_bad
text_mode:
    lda MODE
    beq text_append
    cmp #1
    bne text_bad
    ldx LENGTH
    beq text_done
    dex
    stx LENGTH
    lda #0
    sta BUF0,x
    jmp text_changed
text_append:
    lda KEY
    cmp #32
    bcc text_bad_key
    cmp #127
    bcs text_bad_key
    ldx LENGTH
    cpx #TEXT_CAP
    bcs text_done
    sta BUF0,x
    inc LENGTH
text_changed:
    lda #1
    sta STATUS
text_done:
    rts
text_bad_key:
    lda #2
    sta STATUS
    rts
text_bad:
    lda #3
    sta STATUS
    rts
text_clear:
    ldx #7
    lda #0
text_clear_loop:
    sta BUF0,x
    dex
    bpl text_clear_loop
    sta LENGTH
    jmp text_changed
component_end:
