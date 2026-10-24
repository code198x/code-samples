exercise_rules:
    lda #<(OUTPUT)
    sta ptr
    lda #>(OUTPUT)
    sta ptr+1
    lda #165
    jsr emit
    lda #14
    jsr emit
    lda #CUSTOM
    jsr emit
    ldx #0
    lda #255
dirty_state:
    sta STATE,x
    inx
    cpx #18
    bne dirty_state
    ldy #$93
    jsr stable_depth_order_init
    cpy #$93
    bne failed_register
    jsr emit_state
    lda #<(case_table)
    sta input_ptr
    lda #>(case_table)
    sta input_ptr+1
    lda #55
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
    cpx #18
    bne case_read
    jsr checked_step
    jsr emit_state
    dec cases_left
    bne case_loop
    jsr stable_depth_order_init
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
    jsr stable_depth_order_step
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
    cpx #18
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
; COUNT = 5
    lda #5
    sta COUNT
; Z0 = 1
    lda #1
    sta Z0
; Z1 = 8
    lda #8
    sta Z1
; Z2 = 1
    lda #1
    sta Z2
; Z3 = 8
    lda #8
    sta Z3
; Z4 = 2
    lda #2
    sta Z4
.if BROKEN
; COUNT = 0
    lda #0
    sta COUNT
.endif
    jsr checked_step
    jsr emit_state
    rts
.else
; COUNT = 5
    lda #5
    sta COUNT
; Z0 = 8
    lda #8
    sta Z0
; Z1 = 2
    lda #2
    sta Z1
; Z2 = 8
    lda #8
    sta Z2
; Z3 = 1
    lda #1
    sta Z3
; Z4 = 2
    lda #2
    sta Z4
.if BROKEN
; COUNT = 0
    lda #0
    sta COUNT
.endif
    jsr checked_step
    jsr emit_state
.endif
    rts
; End of gamekit client.
