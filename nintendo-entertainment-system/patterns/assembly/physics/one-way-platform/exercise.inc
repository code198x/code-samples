exercise_rules:
    lda #<(OUTPUT)
    sta ptr
    lda #>(OUTPUT)
    sta ptr+1
    lda #165
    jsr emit
    lda #3
    jsr emit
    lda #CUSTOM
    jsr emit
    ldx #0
    lda #255
dirty_state:
    sta STATE,x
    inx
    cpx #10
    bne dirty_state
    ldy #$93
    jsr one_way_platform_init
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
    cpx #10
    bne case_read
    jsr checked_step
    jsr emit_state
    dec cases_left
    bne case_loop
    jsr one_way_platform_init
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
    jsr one_way_platform_step
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
    cpx #10
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
    lda #20
    sta ACTOR_X
    lda #16
    sta ACTOR_W
    lda #90
    sta PREV_BOTTOM
    lda #110
    sta NEW_BOTTOM
    lda #10
    sta PLATFORM_X
    lda #64
    sta PLATFORM_W
    lda #100
    sta PLATFORM_Y
    lda #1
    sta DROP
.if BROKEN
    jsr checked_step
    lda NEW_BOTTOM
    cmp PLATFORM_Y
    beq bad_platform_done_0_custom
    sta SNAP
    lda #0
    sta LANDED
bad_platform_done_0_custom:
.else
    jsr checked_step
.endif
    jsr emit_state
.else
    lda #20
    sta ACTOR_X
    lda #16
    sta ACTOR_W
    lda #90
    sta PREV_BOTTOM
    lda #110
    sta NEW_BOTTOM
    lda #10
    sta PLATFORM_X
    lda #64
    sta PLATFORM_W
    lda #100
    sta PLATFORM_Y
    lda #0
    sta DROP
.if BROKEN
    jsr checked_step
    lda NEW_BOTTOM
    cmp PLATFORM_Y
    beq bad_platform_done_0
    sta SNAP
    lda #0
    sta LANDED
bad_platform_done_0:
.else
    jsr checked_step
.endif
    jsr emit_state
.endif
    rts
; End of playtools client.
