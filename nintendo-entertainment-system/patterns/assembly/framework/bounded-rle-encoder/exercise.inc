exercise_rules:
    lda #<(OUTPUT)
    sta ptr
    lda #>(OUTPUT)
    sta ptr+1
    lda #165
    jsr emit
    lda #12
    jsr emit
    lda #CUSTOM
    jsr emit
    ldx #0
    lda #255
dirty_state:
    sta STATE,x
    inx
    cpx #29
    bne dirty_state
    ldy #$93
    jsr bounded_rle_encoder_init
    cpy #$93
    bne failed_register
    jsr emit_state
    lda #<(case_table)
    sta input_ptr
    lda #>(case_table)
    sta input_ptr+1
    lda #34
    sta cases_left
case_loop:
    ldx #0
case_read:
    ldy #0
    lda (input_ptr),y
    sta STATE,x
    inc input_ptr
    bne case_read_next
    inc input_ptr+1
case_read_next:
    inx
    cpx #29
    bne case_read
    jsr checked_step
    jsr emit_state
    dec cases_left
    bne case_loop
    jsr bounded_rle_encoder_init
    jsr preview_rules
    ldx #0
preview_copy:
    lda #0
    sta preview,x
    inx
    cpx #8
    bne preview_copy
    ldx #0
preview_state:
    lda STATE,x
    sta preview,x
    inx
    cpx #8
    bne preview_state
    lda #239
    jsr emit
    rts
checked_step:
    ldy #$93
    jsr bounded_rle_encoder_step
    cpy #$93
    bne failed_register
    rts
failed_register:
    jmp failed_register
emit_state:
    ldx #0
emit_state_loop:
    lda STATE,x
    jsr emit
    inx
    cpx #29
    bne emit_state_loop
    rts
emit:
    sty saved_y
    ldy #0
    sta (ptr),y
    inc ptr
    bne emit_done
    inc ptr+1
emit_done:
    ldy saved_y
    rts
; Sequential client: retain private state between service calls.
preview_rules:
.if CUSTOM
; INPUT_COUNT = 8
    lda #8
    sta INPUT_COUNT
; CAPACITY = 16
    lda #16
    sta CAPACITY
; B0 = 0
    lda #0
    sta B0
; B1 = 1
    lda #1
    sta B1
; B2 = 2
    lda #2
    sta B2
; B3 = 3
    lda #3
    sta B3
; B4 = 4
    lda #4
    sta B4
; B5 = 5
    lda #5
    sta B5
; B6 = 6
    lda #6
    sta B6
; B7 = 7
    lda #7
    sta B7
.if BROKEN
; CAPACITY = 0
    lda #0
    sta CAPACITY
.endif
    jsr checked_step
    jsr emit_state
    rts
.else
; INPUT_COUNT = 6
    lda #6
    sta INPUT_COUNT
; CAPACITY = 16
    lda #16
    sta CAPACITY
; B0 = 65
    lda #65
    sta B0
; B1 = 65
    lda #65
    sta B1
; B2 = 65
    lda #65
    sta B2
; B3 = 66
    lda #66
    sta B3
; B4 = 66
    lda #66
    sta B4
; B5 = 67
    lda #67
    sta B5
.if BROKEN
; CAPACITY = 0
    lda #0
    sta CAPACITY
.endif
    jsr checked_step
    jsr emit_state
.endif
    rts
; End of worldkit client.
