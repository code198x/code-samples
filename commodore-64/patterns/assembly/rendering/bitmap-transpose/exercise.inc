exercise_rules:
    lda #<(OUTPUT)
    sta ptr
    lda #>(OUTPUT)
    sta ptr+1
    lda #165
    jsr emit
    lda #15
    jsr emit
    lda #CUSTOM
    jsr emit
    ldx #0
    lda #255
dirty_state:
    sta STATE,x
    inx
    cpx #16
    bne dirty_state
    ldy #$93
    jsr bitmap_transpose_init
    cpy #$93
    bne failed_register
    jsr emit_state
    lda #<(case_table)
    sta input_ptr
    lda #>(case_table)
    sta input_ptr+1
    lda #62
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
    cpx #16
    bne case_read
    jsr checked_step
    jsr emit_state
    dec cases_left
    bne case_loop
    jsr bitmap_transpose_init
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
    jsr bitmap_transpose_step
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
    cpx #16
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
; C0 = 128
    lda #128
    sta C0
; C1 = 64
    lda #64
    sta C1
; C2 = 32
    lda #32
    sta C2
; C3 = 16
    lda #16
    sta C3
; C4 = 8
    lda #8
    sta C4
; C5 = 4
    lda #4
    sta C5
; C6 = 2
    lda #2
    sta C6
; C7 = 1
    lda #1
    sta C7
!if BROKEN {
; C0 = 0
    lda #0
    sta C0
}
    jsr checked_step
    jsr emit_state
    rts
} else {
; C0 = 255
    lda #255
    sta C0
; C1 = 128
    lda #128
    sta C1
; C2 = 128
    lda #128
    sta C2
; C3 = 128
    lda #128
    sta C3
!if BROKEN {
; C0 = 0
    lda #0
    sta C0
}
    jsr checked_step
    jsr emit_state
}
    rts
; End of toolkit client.
