exercise_rules:
    lda #<(OUTPUT)
    sta ptr
    lda #>(OUTPUT)
    sta ptr+1
    lda #165
    jsr emit
    lda #10
    jsr emit
    lda #CUSTOM
    jsr emit
    ldx #0
    lda #255
dirty_state:
    sta STATE,x
    inx
    cpx #14
    bne dirty_state
    ldy #$93
    jsr rectangle_clipping_init
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
    cpx #14
    bne case_read
    jsr checked_step
    jsr emit_state
    dec cases_left
    bne case_loop
    jsr rectangle_clipping_init
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
    jsr rectangle_clipping_step
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
    cpx #14
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
; LEFT = 0
    lda #0
    sta LEFT
; TOP = 0
    lda #0
    sta TOP
; RIGHT = 255
    lda #255
    sta RIGHT
; BOTTOM = 255
    lda #255
    sta BOTTOM
; VIEW_LEFT = 10
    lda #10
    sta VIEW_LEFT
; VIEW_TOP = 20
    lda #20
    sta VIEW_TOP
; VIEW_RIGHT = 30
    lda #30
    sta VIEW_RIGHT
; VIEW_BOTTOM = 40
    lda #40
    sta VIEW_BOTTOM
!if BROKEN {
; VIEW_RIGHT = 255
    lda #255
    sta VIEW_RIGHT
}
    jsr checked_step
    jsr emit_state
    rts
} else {
; LEFT = 2
    lda #2
    sta LEFT
; TOP = 3
    lda #3
    sta TOP
; RIGHT = 12
    lda #12
    sta RIGHT
; BOTTOM = 15
    lda #15
    sta BOTTOM
; VIEW_LEFT = 5
    lda #5
    sta VIEW_LEFT
; VIEW_TOP = 0
    lda #0
    sta VIEW_TOP
; VIEW_RIGHT = 10
    lda #10
    sta VIEW_RIGHT
; VIEW_BOTTOM = 10
    lda #10
    sta VIEW_BOTTOM
!if BROKEN {
; VIEW_RIGHT = 255
    lda #255
    sta VIEW_RIGHT
}
    jsr checked_step
    jsr emit_state
}
    rts
; End of toolkit client.
