exercise_rules:
    lda #<(OUTPUT)
    sta ptr
    lda #>(OUTPUT)
    sta ptr+1
    lda #165
    jsr emit
    lda #6
    jsr emit
    lda #CUSTOM
    jsr emit
    ldx #0
    lda #255
dirty_state:
    sta STATE,x
    inx
    cpx #12
    bne dirty_state
    ldy #$93
    jsr text_entry_buffer_init
    cpy #$93
    bne failed_register
    jsr emit_state
    lda #<(case_table)
    sta input_ptr
    lda #>(case_table)
    sta input_ptr+1
    lda #64
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
    cpx #12
    bne case_read
    jsr checked_step
    jsr emit_state
    dec cases_left
    bne case_loop
    jsr text_entry_buffer_init
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
    jsr text_entry_buffer_step
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
    cpx #12
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
!if CUSTOM {
    lda #0
    sta MODE
    lda #65
    sta KEY
!if BROKEN {
    lda MODE
    cmp #1
    bne bad_text_regular_0_custom
    lda LENGTH
    bne bad_text_regular_0_custom
    dec LENGTH
    lda #1
    sta STATUS
    jmp bad_text_done_0_custom
bad_text_regular_0_custom:
    jsr checked_step
bad_text_done_0_custom:
} else {
    jsr checked_step
}
    jsr emit_state
    lda #66
    sta KEY
!if BROKEN {
    lda MODE
    cmp #1
    bne bad_text_regular_1_custom
    lda LENGTH
    bne bad_text_regular_1_custom
    dec LENGTH
    lda #1
    sta STATUS
    jmp bad_text_done_1_custom
bad_text_regular_1_custom:
    jsr checked_step
bad_text_done_1_custom:
} else {
    jsr checked_step
}
    jsr emit_state
    lda #1
    sta MODE
!if BROKEN {
    lda MODE
    cmp #1
    bne bad_text_regular_2_custom
    lda LENGTH
    bne bad_text_regular_2_custom
    dec LENGTH
    lda #1
    sta STATUS
    jmp bad_text_done_2_custom
bad_text_regular_2_custom:
    jsr checked_step
bad_text_done_2_custom:
} else {
    jsr checked_step
}
    jsr emit_state
!if BROKEN {
    lda MODE
    cmp #1
    bne bad_text_regular_3_custom
    lda LENGTH
    bne bad_text_regular_3_custom
    dec LENGTH
    lda #1
    sta STATUS
    jmp bad_text_done_3_custom
bad_text_regular_3_custom:
    jsr checked_step
bad_text_done_3_custom:
} else {
    jsr checked_step
}
    jsr emit_state
!if BROKEN {
    lda MODE
    cmp #1
    bne bad_text_regular_4_custom
    lda LENGTH
    bne bad_text_regular_4_custom
    dec LENGTH
    lda #1
    sta STATUS
    jmp bad_text_done_4_custom
bad_text_regular_4_custom:
    jsr checked_step
bad_text_done_4_custom:
} else {
    jsr checked_step
}
    jsr emit_state
    lda #0
    sta MODE
    lda #67
    sta KEY
!if BROKEN {
    lda MODE
    cmp #1
    bne bad_text_regular_5_custom
    lda LENGTH
    bne bad_text_regular_5_custom
    dec LENGTH
    lda #1
    sta STATUS
    jmp bad_text_done_5_custom
bad_text_regular_5_custom:
    jsr checked_step
bad_text_done_5_custom:
} else {
    jsr checked_step
}
    jsr emit_state
} else {
    lda #0
    sta MODE
    lda #65
    sta KEY
!if BROKEN {
    lda MODE
    cmp #1
    bne bad_text_regular_0
    lda LENGTH
    bne bad_text_regular_0
    dec LENGTH
    lda #1
    sta STATUS
    jmp bad_text_done_0
bad_text_regular_0:
    jsr checked_step
bad_text_done_0:
} else {
    jsr checked_step
}
    jsr emit_state
    lda #66
    sta KEY
!if BROKEN {
    lda MODE
    cmp #1
    bne bad_text_regular_1
    lda LENGTH
    bne bad_text_regular_1
    dec LENGTH
    lda #1
    sta STATUS
    jmp bad_text_done_1
bad_text_regular_1:
    jsr checked_step
bad_text_done_1:
} else {
    jsr checked_step
}
    jsr emit_state
    lda #1
    sta MODE
!if BROKEN {
    lda MODE
    cmp #1
    bne bad_text_regular_2
    lda LENGTH
    bne bad_text_regular_2
    dec LENGTH
    lda #1
    sta STATUS
    jmp bad_text_done_2
bad_text_regular_2:
    jsr checked_step
bad_text_done_2:
} else {
    jsr checked_step
}
    jsr emit_state
!if BROKEN {
    lda MODE
    cmp #1
    bne bad_text_regular_3
    lda LENGTH
    bne bad_text_regular_3
    dec LENGTH
    lda #1
    sta STATUS
    jmp bad_text_done_3
bad_text_regular_3:
    jsr checked_step
bad_text_done_3:
} else {
    jsr checked_step
}
    jsr emit_state
!if BROKEN {
    lda MODE
    cmp #1
    bne bad_text_regular_4
    lda LENGTH
    bne bad_text_regular_4
    dec LENGTH
    lda #1
    sta STATUS
    jmp bad_text_done_4
bad_text_regular_4:
    jsr checked_step
bad_text_done_4:
} else {
    jsr checked_step
}
    jsr emit_state
}
    rts
; End of playtools client.
