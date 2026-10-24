exercise_rules:
    lda #<(OUTPUT)
    sta ptr
    lda #>(OUTPUT)
    sta ptr+1
    lda #165
    jsr emit
    lda #9
    jsr emit
    lda #CUSTOM
    jsr emit
    ldx #0
    lda #255
dirty_state:
    sta STATE,x
    inx
    cpx #22
    bne dirty_state
    ldy #$93
    jsr bounded_text_wrap_init
    cpy #$93
    bne failed_register
    jsr emit_state
    lda #<(case_table)
    sta input_ptr
    lda #>(case_table)
    sta input_ptr+1
    lda #45
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
    cpx #22
    bne case_read
    jsr checked_step
    jsr emit_state
    dec cases_left
    bne case_loop
    jsr bounded_text_wrap_init
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
    jsr bounded_text_wrap_step
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
    cpx #22
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
; COUNT = 8
    lda #8
    sta COUNT
; WIDTH = 3
    lda #3
    sta WIDTH
; C0 = 65
    lda #65
    sta C0
; C1 = 66
    lda #66
    sta C1
; C2 = 67
    lda #67
    sta C2
; C3 = 68
    lda #68
    sta C3
; C4 = 69
    lda #69
    sta C4
; C5 = 70
    lda #70
    sta C5
; C6 = 71
    lda #71
    sta C6
; C7 = 72
    lda #72
    sta C7
.if BROKEN
; WIDTH = 1
    lda #1
    sta WIDTH
.endif
    jsr checked_step
    jsr emit_state
    rts
.else
; COUNT = 11
    lda #11
    sta COUNT
; WIDTH = 7
    lda #7
    sta WIDTH
; C0 = 72
    lda #72
    sta C0
; C1 = 69
    lda #69
    sta C1
; C2 = 76
    lda #76
    sta C2
; C3 = 76
    lda #76
    sta C3
; C4 = 79
    lda #79
    sta C4
; C5 = 32
    lda #32
    sta C5
; C6 = 87
    lda #87
    sta C6
; C7 = 79
    lda #79
    sta C7
; C8 = 82
    lda #82
    sta C8
; C9 = 76
    lda #76
    sta C9
; C10 = 68
    lda #68
    sta C10
.if BROKEN
; WIDTH = 1
    lda #1
    sta WIDTH
.endif
    jsr checked_step
    jsr emit_state
.endif
    rts
; End of toolkit client.
