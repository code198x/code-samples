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
    cpx #19
    bne dirty_state
    ldy #$93
    jsr stable_compaction_init
    cpy #$93
    bne failed_register
    jsr emit_state
    lda #<(case_table)
    sta input_ptr
    lda #>(case_table)
    sta input_ptr+1
    lda #52
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
    cpx #19
    bne case_read
    jsr checked_step
    jsr emit_state
    dec cases_left
    bne case_loop
    jsr stable_compaction_init
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
    jsr stable_compaction_step
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
    cpx #19
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
; COUNT = 4
    lda #4
    sta COUNT
; F1 = 1
    lda #1
    sta F1
; F3 = 1
    lda #1
    sta F3
; I0 = 20
    lda #20
    sta I0
; I1 = 21
    lda #21
    sta I1
; I2 = 22
    lda #22
    sta I2
; I3 = 23
    lda #23
    sta I3
; I4 = 24
    lda #24
    sta I4
; I5 = 25
    lda #25
    sta I5
; I6 = 26
    lda #26
    sta I6
; I7 = 27
    lda #27
    sta I7
.if BROKEN
; COUNT = 8
    lda #8
    sta COUNT
.endif
    jsr checked_step
    jsr emit_state
    rts
.else
; COUNT = 6
    lda #6
    sta COUNT
; F0 = 1
    lda #1
    sta F0
; F2 = 1
    lda #1
    sta F2
; F4 = 1
    lda #1
    sta F4
; F7 = 1
    lda #1
    sta F7
; I0 = 10
    lda #10
    sta I0
; I1 = 11
    lda #11
    sta I1
; I2 = 12
    lda #12
    sta I2
; I3 = 13
    lda #13
    sta I3
; I4 = 14
    lda #14
    sta I4
; I5 = 15
    lda #15
    sta I5
; I6 = 16
    lda #16
    sta I6
; I7 = 99
    lda #99
    sta I7
.if BROKEN
; COUNT = 8
    lda #8
    sta COUNT
.endif
    jsr checked_step
    jsr emit_state
.endif
    rts
; End of worldkit client.
