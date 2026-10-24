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
    cpx #15
    bne dirty_state
    ldy #$93
    jsr nearest_target_init
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
    jsr nearest_target_init
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
    jsr nearest_target_step
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
; ACTIVE = 9
    lda #9
    sta ACTIVE
; ORIGIN_X = 255
    lda #255
    sta ORIGIN_X
; ORIGIN_Y = 255
    lda #255
    sta ORIGIN_Y
; PX0 = 0
    lda #0
    sta PX0
; PY0 = 0
    lda #0
    sta PY0
; PX3 = 254
    lda #254
    sta PX3
; PY3 = 255
    lda #255
    sta PY3
!if BROKEN {
; ACTIVE = 1
    lda #1
    sta ACTIVE
}
    jsr checked_step
    jsr emit_state
    rts
} else {
; ACTIVE = 3
    lda #3
    sta ACTIVE
; PX0 = 100
    lda #100
    sta PX0
; PY0 = 100
    lda #100
    sta PY0
; PX1 = 2
    lda #2
    sta PX1
; PY1 = 3
    lda #3
    sta PY1
!if BROKEN {
; ACTIVE = 1
    lda #1
    sta ACTIVE
}
    jsr checked_step
    jsr emit_state
}
    rts
; End of toolkit client.
