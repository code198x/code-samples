exercise_rules:
    lda #<(OUTPUT)
    sta ptr
    lda #>(OUTPUT)
    sta ptr+1
    lda #165
    jsr emit
    lda #8
    jsr emit
    lda #CUSTOM
    jsr emit
    ldx #0
    lda #255
dirty_state:
    sta STATE,x
    inx
    cpx #15
    bne dirty_state
    ldy #$93
    jsr save_record_validation_init
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
    cpx #15
    bne case_read
    jsr checked_step
    jsr emit_state
    dec cases_left
    bne case_loop
    jsr save_record_validation_init
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
    jsr save_record_validation_step
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
    cpx #15
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
; MODE = 0
    lda #0
    sta MODE
; L0 = 9
    lda #9
    sta L0
; C0 = 198
    lda #198
    sta C0
; C1 = 1
    lda #1
    sta C1
; C2 = 4
    lda #4
    sta C2
; C3 = 15
    lda #15
    sta C3
; C4 = 31
    lda #31
    sta C4
; C5 = 9
    lda #9
    sta C5
; C6 = 15
    lda #15
    sta C6
; C7 = 213
    lda #213
    sta C7
!if BROKEN {
; C7 = 0
    lda #0
    sta C7
}
    jsr checked_step
    jsr emit_state
; MODE = 1
    lda #1
    sta MODE
!if BROKEN {
; C7 = 0
    lda #0
    sta C7
}
    jsr checked_step
    jsr emit_state
    rts
} else {
; MODE = 1
    lda #1
    sta MODE
; L0 = 2
    lda #2
    sta L0
; L1 = 3
    lda #3
    sta L1
; L2 = 4
    lda #4
    sta L2
; L3 = 5
    lda #5
    sta L3
; C0 = 198
    lda #198
    sta C0
; C1 = 1
    lda #1
    sta C1
; C2 = 4
    lda #4
    sta C2
; C3 = 7
    lda #7
    sta C3
; C4 = 20
    lda #20
    sta C4
; C5 = 3
    lda #3
    sta C5
; C6 = 2
    lda #2
    sta C6
; C7 = 209
    lda #209
    sta C7
!if BROKEN {
; C7 = 0
    lda #0
    sta C7
}
    jsr checked_step
    jsr emit_state
; C5 = 255
    lda #255
    sta C5
!if BROKEN {
; C7 = 0
    lda #0
    sta C7
}
    jsr checked_step
    jsr emit_state
}
    rts
; End of nighttwo client.
