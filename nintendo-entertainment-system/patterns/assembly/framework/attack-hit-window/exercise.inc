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
    cpx #9
    bne dirty_state
    ldy #$93
    jsr attack_hit_window_init
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
    jsr attack_hit_window_init
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
    jsr attack_hit_window_step
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
; START_FRAME = 1
    lda #1
    sta START_FRAME
; END_FRAME = 3
    lda #3
    sta END_FRAME
; FRAME = 1
    lda #1
    sta FRAME
; TARGET = 7
    lda #7
    sta TARGET
; CONTACT = 1
    lda #1
    sta CONTACT
; NEW_ATTACK = 1
    lda #1
    sta NEW_ATTACK
.if BROKEN
; SEEN = 0
    lda #0
    sta SEEN
.endif
    jsr checked_step
    jsr emit_state
; NEW_ATTACK = 0
    lda #0
    sta NEW_ATTACK
; TARGET = 0
    lda #0
    sta TARGET
.if BROKEN
; SEEN = 0
    lda #0
    sta SEEN
.endif
    jsr checked_step
    jsr emit_state
; FRAME = 3
    lda #3
    sta FRAME
.if BROKEN
; SEEN = 0
    lda #0
    sta SEEN
.endif
    jsr checked_step
    jsr emit_state
    rts
.else
; START_FRAME = 2
    lda #2
    sta START_FRAME
; END_FRAME = 5
    lda #5
    sta END_FRAME
; FRAME = 2
    lda #2
    sta FRAME
; TARGET = 1
    lda #1
    sta TARGET
; CONTACT = 1
    lda #1
    sta CONTACT
; NEW_ATTACK = 1
    lda #1
    sta NEW_ATTACK
.if BROKEN
; SEEN = 0
    lda #0
    sta SEEN
.endif
    jsr checked_step
    jsr emit_state
; NEW_ATTACK = 0
    lda #0
    sta NEW_ATTACK
; FRAME = 3
    lda #3
    sta FRAME
.if BROKEN
; SEEN = 0
    lda #0
    sta SEEN
.endif
    jsr checked_step
    jsr emit_state

.if BROKEN
; SEEN = 0
    lda #0
    sta SEEN
.endif
    jsr checked_step
    jsr emit_state
.endif
    rts
; End of nighttwo client.
