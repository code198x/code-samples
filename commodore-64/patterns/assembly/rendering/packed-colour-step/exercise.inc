exercise_rules:
    lda #<(OUTPUT)
    sta ptr
    lda #>(OUTPUT)
    sta ptr+1
    lda #165
    jsr emit
    lda #16
    jsr emit
    lda #CUSTOM
    jsr emit
    ldx #0
    lda #255
dirty_state:
    sta STATE,x
    inx
    cpx #2
    bne dirty_state
    ldy #$93
    jsr packed_colour_step_init
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
    cpx #2
    bne case_read
    jsr checked_step
    jsr emit_state
    dec cases_left
    bne case_loop
    jsr packed_colour_step_init
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
    cpx #2
    bne preview_state
    lda #239
    jsr emit
    rts
checked_step:
    ldy #$93
    jsr packed_colour_step_step
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
    cpx #2
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
; COLOUR = 255
    lda #255
    sta COLOUR
; TARGET = 0
    lda #0
    sta TARGET
!if BROKEN {
; COLOUR = 0
    lda #0
    sta COLOUR
}
    jsr checked_step
    jsr emit_state

!if BROKEN {
; COLOUR = 0
    lda #0
    sta COLOUR
}
    jsr checked_step
    jsr emit_state

!if BROKEN {
; COLOUR = 0
    lda #0
    sta COLOUR
}
    jsr checked_step
    jsr emit_state

!if BROKEN {
; COLOUR = 0
    lda #0
    sta COLOUR
}
    jsr checked_step
    jsr emit_state
    rts
} else {
; TARGET = 255
    lda #255
    sta TARGET
!if BROKEN {
; COLOUR = 0
    lda #0
    sta COLOUR
}
    jsr checked_step
    jsr emit_state

!if BROKEN {
; COLOUR = 0
    lda #0
    sta COLOUR
}
    jsr checked_step
    jsr emit_state

!if BROKEN {
; COLOUR = 0
    lda #0
    sta COLOUR
}
    jsr checked_step
    jsr emit_state

!if BROKEN {
; COLOUR = 0
    lda #0
    sta COLOUR
}
    jsr checked_step
    jsr emit_state
}
    rts
; End of toolkit client.
