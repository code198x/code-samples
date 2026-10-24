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
    cpx #21
    bne dirty_state
    ldy #$93
    jsr dictionary_lookup_init
    cpy #$93
    bne failed_register
    jsr emit_state
    lda #<(case_table)
    sta input_ptr
    lda #>(case_table)
    sta input_ptr+1
    lda #47
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
    cpx #21
    bne case_read
    jsr checked_step
    jsr emit_state
    dec cases_left
    bne case_loop
    jsr dictionary_lookup_init
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
    jsr dictionary_lookup_step
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
    cpx #21
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
; COUNT = 1
    lda #1
    sta COUNT
; K0 = 255
    lda #255
    sta K0
; Q0 = 0
    lda #0
    sta Q0
; KEY = 255
    lda #255
    sta KEY
!if BROKEN {
; KEY = 0
    lda #0
    sta KEY
}
    jsr checked_step
    jsr emit_state
    rts
} else {
; COUNT = 3
    lda #3
    sta COUNT
; K0 = 10
    lda #10
    sta K0
; K1 = 20
    lda #20
    sta K1
; K2 = 20
    lda #20
    sta K2
; Q0 = 4
    lda #4
    sta Q0
; Q1 = 7
    lda #7
    sta Q1
; Q2 = 9
    lda #9
    sta Q2
; KEY = 20
    lda #20
    sta KEY
!if BROKEN {
; KEY = 0
    lda #0
    sta KEY
}
    jsr checked_step
    jsr emit_state
}
    rts
; End of toolkit client.
