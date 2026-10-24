exercise_rules:
    lda #<(OUTPUT)
    sta ptr
    lda #>(OUTPUT)
    sta ptr+1
    lda #165
    jsr emit
    lda #17
    jsr emit
    lda #CUSTOM
    jsr emit
    ldx #0
    lda #255
dirty_state:
    sta STATE,x
    inx
    cpx #20
    bne dirty_state
    ldy #$93
    jsr pixel_mask_collision_init
    cpy #$93
    bne failed_register
    jsr emit_state
    lda #<(case_table)
    sta input_ptr
    lda #>(case_table)
    sta input_ptr+1
    lda #50
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
    cpx #20
    bne case_read
    jsr checked_step
    jsr emit_state
    dec cases_left
    bne case_loop
    jsr pixel_mask_collision_init
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
    jsr pixel_mask_collision_step
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
    cpx #20
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
; SHIFT_X = 0
    lda #0
    sta SHIFT_X
; P0 = 128
    lda #128
    sta P0
; Q0 = 128
    lda #128
    sta Q0
.if BROKEN
; SHIFT_X = 0
    lda #0
    sta SHIFT_X
.endif
    jsr checked_step
    jsr emit_state
    rts
.else
; SHIFT_X = 1
    lda #1
    sta SHIFT_X
; P0 = 128
    lda #128
    sta P0
; Q0 = 128
    lda #128
    sta Q0
.if BROKEN
; SHIFT_X = 0
    lda #0
    sta SHIFT_X
.endif
    jsr checked_step
    jsr emit_state
.endif
    rts
; End of worldkit client.
