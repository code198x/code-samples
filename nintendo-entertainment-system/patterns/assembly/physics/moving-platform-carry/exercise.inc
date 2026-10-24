exercise_rules:
    lda #<(OUTPUT)
    sta ptr
    lda #>(OUTPUT)
    sta ptr+1
    lda #165
    jsr emit
    lda #5
    jsr emit
    lda #CUSTOM
    jsr emit
    ldx #0
    lda #255
dirty_state:
    sta STATE,x
    inx
    cpx #9
    bne dirty_state
    ldy #$93
    jsr moving_platform_carry_init
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
    cpx #9
    bne case_read
    jsr checked_step
    jsr emit_state
    dec cases_left
    bne case_loop
    jsr moving_platform_carry_init
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
    jsr moving_platform_carry_step
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
    cpx #9
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
; PASSENGER = 2
    lda #2
    sta PASSENGER
; PLATFORM_OLD = 10
    lda #10
    sta PLATFORM_OLD
; PLATFORM_NEW = 0
    lda #0
    sta PLATFORM_NEW
; SUPPORTED = 1
    lda #1
    sta SUPPORTED
; MINIMUM = 0
    lda #0
    sta MINIMUM
; MAXIMUM = 100
    lda #100
    sta MAXIMUM
.if BROKEN
; PLATFORM_OLD = PLATFORM_NEW
    lda PLATFORM_NEW
    sta PLATFORM_OLD
.endif
    jsr checked_step
    jsr emit_state
    rts
.else
; PASSENGER = 20
    lda #20
    sta PASSENGER
; PLATFORM_OLD = 5
    lda #5
    sta PLATFORM_OLD
; PLATFORM_NEW = 9
    lda #9
    sta PLATFORM_NEW
; SUPPORTED = 1
    lda #1
    sta SUPPORTED
; MINIMUM = 0
    lda #0
    sta MINIMUM
; MAXIMUM = 100
    lda #100
    sta MAXIMUM
.if BROKEN
; PLATFORM_OLD = PLATFORM_NEW
    lda PLATFORM_NEW
    sta PLATFORM_OLD
.endif
    jsr checked_step
    jsr emit_state
.endif
    rts
; End of nightone client.
