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
    cpx #4
    bne dirty_state
    ldy #$93
    jsr endpoint_patrol_init
    cpy #$93
    bne failed_register
    jsr emit_state
    lda #<(case_table)
    sta input_ptr
    lda #>(case_table)
    sta input_ptr+1
    lda #96
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
    cpx #4
    bne case_read
    jsr checked_step
    jsr emit_state
    dec cases_left
    bne case_loop
    jsr endpoint_patrol_init
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
    cpx #4
    bne preview_state
    lda #239
    jsr emit
    rts
checked_step:
    ldy #$93
    jsr endpoint_patrol_step
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
    cpx #4
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
; Sequential client: initialise once, then retain state between calls.
preview_rules:
.if CUSTOM
    lda #4
    sta POSITION
    lda #0
    sta LOWER
    lda #6
    sta UPPER
    lda #0
    sta DIRECTION
.if BROKEN
    lda DIRECTION
    beq bad_patrol_up_0_custom
    dec POSITION
    jmp bad_patrol_check_0_custom
bad_patrol_up_0_custom:
    inc POSITION
bad_patrol_check_0_custom:
    lda POSITION
    cmp LOWER
    bcc bad_patrol_flip_0_custom
    cmp UPPER
    bcc bad_patrol_end_0_custom
    beq bad_patrol_end_0_custom
bad_patrol_flip_0_custom:
    lda DIRECTION
    eor #1
    sta DIRECTION
bad_patrol_end_0_custom:
.else
    jsr checked_step
.endif
    jsr emit_state
.if BROKEN
    lda DIRECTION
    beq bad_patrol_up_1_custom
    dec POSITION
    jmp bad_patrol_check_1_custom
bad_patrol_up_1_custom:
    inc POSITION
bad_patrol_check_1_custom:
    lda POSITION
    cmp LOWER
    bcc bad_patrol_flip_1_custom
    cmp UPPER
    bcc bad_patrol_end_1_custom
    beq bad_patrol_end_1_custom
bad_patrol_flip_1_custom:
    lda DIRECTION
    eor #1
    sta DIRECTION
bad_patrol_end_1_custom:
.else
    jsr checked_step
.endif
    jsr emit_state
.if BROKEN
    lda DIRECTION
    beq bad_patrol_up_2_custom
    dec POSITION
    jmp bad_patrol_check_2_custom
bad_patrol_up_2_custom:
    inc POSITION
bad_patrol_check_2_custom:
    lda POSITION
    cmp LOWER
    bcc bad_patrol_flip_2_custom
    cmp UPPER
    bcc bad_patrol_end_2_custom
    beq bad_patrol_end_2_custom
bad_patrol_flip_2_custom:
    lda DIRECTION
    eor #1
    sta DIRECTION
bad_patrol_end_2_custom:
.else
    jsr checked_step
.endif
    jsr emit_state
.if BROKEN
    lda DIRECTION
    beq bad_patrol_up_3_custom
    dec POSITION
    jmp bad_patrol_check_3_custom
bad_patrol_up_3_custom:
    inc POSITION
bad_patrol_check_3_custom:
    lda POSITION
    cmp LOWER
    bcc bad_patrol_flip_3_custom
    cmp UPPER
    bcc bad_patrol_end_3_custom
    beq bad_patrol_end_3_custom
bad_patrol_flip_3_custom:
    lda DIRECTION
    eor #1
    sta DIRECTION
bad_patrol_end_3_custom:
.else
    jsr checked_step
.endif
    jsr emit_state
.if BROKEN
    lda DIRECTION
    beq bad_patrol_up_4_custom
    dec POSITION
    jmp bad_patrol_check_4_custom
bad_patrol_up_4_custom:
    inc POSITION
bad_patrol_check_4_custom:
    lda POSITION
    cmp LOWER
    bcc bad_patrol_flip_4_custom
    cmp UPPER
    bcc bad_patrol_end_4_custom
    beq bad_patrol_end_4_custom
bad_patrol_flip_4_custom:
    lda DIRECTION
    eor #1
    sta DIRECTION
bad_patrol_end_4_custom:
.else
    jsr checked_step
.endif
    jsr emit_state
.if BROKEN
    lda DIRECTION
    beq bad_patrol_up_5_custom
    dec POSITION
    jmp bad_patrol_check_5_custom
bad_patrol_up_5_custom:
    inc POSITION
bad_patrol_check_5_custom:
    lda POSITION
    cmp LOWER
    bcc bad_patrol_flip_5_custom
    cmp UPPER
    bcc bad_patrol_end_5_custom
    beq bad_patrol_end_5_custom
bad_patrol_flip_5_custom:
    lda DIRECTION
    eor #1
    sta DIRECTION
bad_patrol_end_5_custom:
.else
    jsr checked_step
.endif
    jsr emit_state
.else
    lda #4
    sta POSITION
    lda #0
    sta LOWER
    lda #4
    sta UPPER
    lda #0
    sta DIRECTION
.if BROKEN
    lda DIRECTION
    beq bad_patrol_up_0
    dec POSITION
    jmp bad_patrol_check_0
bad_patrol_up_0:
    inc POSITION
bad_patrol_check_0:
    lda POSITION
    cmp LOWER
    bcc bad_patrol_flip_0
    cmp UPPER
    bcc bad_patrol_end_0
    beq bad_patrol_end_0
bad_patrol_flip_0:
    lda DIRECTION
    eor #1
    sta DIRECTION
bad_patrol_end_0:
.else
    jsr checked_step
.endif
    jsr emit_state
.if BROKEN
    lda DIRECTION
    beq bad_patrol_up_1
    dec POSITION
    jmp bad_patrol_check_1
bad_patrol_up_1:
    inc POSITION
bad_patrol_check_1:
    lda POSITION
    cmp LOWER
    bcc bad_patrol_flip_1
    cmp UPPER
    bcc bad_patrol_end_1
    beq bad_patrol_end_1
bad_patrol_flip_1:
    lda DIRECTION
    eor #1
    sta DIRECTION
bad_patrol_end_1:
.else
    jsr checked_step
.endif
    jsr emit_state
.if BROKEN
    lda DIRECTION
    beq bad_patrol_up_2
    dec POSITION
    jmp bad_patrol_check_2
bad_patrol_up_2:
    inc POSITION
bad_patrol_check_2:
    lda POSITION
    cmp LOWER
    bcc bad_patrol_flip_2
    cmp UPPER
    bcc bad_patrol_end_2
    beq bad_patrol_end_2
bad_patrol_flip_2:
    lda DIRECTION
    eor #1
    sta DIRECTION
bad_patrol_end_2:
.else
    jsr checked_step
.endif
    jsr emit_state
.if BROKEN
    lda DIRECTION
    beq bad_patrol_up_3
    dec POSITION
    jmp bad_patrol_check_3
bad_patrol_up_3:
    inc POSITION
bad_patrol_check_3:
    lda POSITION
    cmp LOWER
    bcc bad_patrol_flip_3
    cmp UPPER
    bcc bad_patrol_end_3
    beq bad_patrol_end_3
bad_patrol_flip_3:
    lda DIRECTION
    eor #1
    sta DIRECTION
bad_patrol_end_3:
.else
    jsr checked_step
.endif
    jsr emit_state
.if BROKEN
    lda DIRECTION
    beq bad_patrol_up_4
    dec POSITION
    jmp bad_patrol_check_4
bad_patrol_up_4:
    inc POSITION
bad_patrol_check_4:
    lda POSITION
    cmp LOWER
    bcc bad_patrol_flip_4
    cmp UPPER
    bcc bad_patrol_end_4
    beq bad_patrol_end_4
bad_patrol_flip_4:
    lda DIRECTION
    eor #1
    sta DIRECTION
bad_patrol_end_4:
.else
    jsr checked_step
.endif
    jsr emit_state
.if BROKEN
    lda DIRECTION
    beq bad_patrol_up_5
    dec POSITION
    jmp bad_patrol_check_5
bad_patrol_up_5:
    inc POSITION
bad_patrol_check_5:
    lda POSITION
    cmp LOWER
    bcc bad_patrol_flip_5
    cmp UPPER
    bcc bad_patrol_end_5
    beq bad_patrol_end_5
bad_patrol_flip_5:
    lda DIRECTION
    eor #1
    sta DIRECTION
bad_patrol_end_5:
.else
    jsr checked_step
.endif
    jsr emit_state
.endif
    rts
; End of gameplay client.
