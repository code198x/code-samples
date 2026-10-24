exercise_rules:
    lda #<(OUTPUT)
    sta ptr
    lda #>(OUTPUT)
    sta ptr+1
    lda #165
    jsr emit
    lda #2
    jsr emit
    lda #CUSTOM
    jsr emit
    ldx #0
    lda #255
dirty_state:
    sta STATE,x
    inx
    cpx #8
    bne dirty_state
    ldy #$93
    jsr aimed_projectile_init
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
    cpx #8
    bne case_read
    jsr checked_step
    jsr emit_state
    dec cases_left
    bne case_loop
    jsr aimed_projectile_init
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
    jsr aimed_projectile_step
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
    cpx #8
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
; ORIGIN_X = 0
    lda #0
    sta ORIGIN_X
; ORIGIN_Y = 0
    lda #0
    sta ORIGIN_Y
; TARGET_X = 255
    lda #255
    sta TARGET_X
; TARGET_Y = 128
    lda #128
    sta TARGET_Y
; SPEED = 15
    lda #15
    sta SPEED
.if BROKEN
; TARGET_X = ORIGIN_X
    lda ORIGIN_X
    sta TARGET_X
.endif
    jsr checked_step
    jsr emit_state
    rts
.else
; ORIGIN_X = 100
    lda #100
    sta ORIGIN_X
; ORIGIN_Y = 100
    lda #100
    sta ORIGIN_Y
; TARGET_X = 80
    lda #80
    sta TARGET_X
; TARGET_Y = 90
    lda #90
    sta TARGET_Y
; SPEED = 6
    lda #6
    sta SPEED
.if BROKEN
; TARGET_X = ORIGIN_X
    lda ORIGIN_X
    sta TARGET_X
.endif
    jsr checked_step
    jsr emit_state
.endif
    rts
; End of nighttwo client.
