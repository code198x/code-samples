exercise_rules:
    lda #<(OUTPUT)
    sta ptr
    lda #>(OUTPUT)
    sta ptr+1
    lda #165
    jsr emit
    lda #15
    jsr emit
    lda #CUSTOM
    jsr emit
    ldx #0
    lda #255
dirty_state:
    sta STATE,x
    inx
    cpx #25
    bne dirty_state
    ldy #$93
    jsr motion_history_init
    cpy #$93
    bne failed_register
    jsr emit_state
    lda #<(case_table)
    sta input_ptr
    lda #>(case_table)
    sta input_ptr+1
    lda #40
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
    cpx #25
    bne case_read
    jsr checked_step
    jsr emit_state
    dec cases_left
    bne case_loop
    jsr motion_history_init
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
    jsr motion_history_step
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
    cpx #25
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
; INPUT_X = 0
    lda #0
    sta INPUT_X
; INPUT_Y = 1
    lda #1
    sta INPUT_Y
; PUSH = 1
    lda #1
    sta PUSH
.if BROKEN
; HEAD = 0
    lda #0
    sta HEAD
.endif
    jsr checked_step
    jsr emit_state
; INPUT_X = 1
    lda #1
    sta INPUT_X
; INPUT_Y = 2
    lda #2
    sta INPUT_Y
; PUSH = 1
    lda #1
    sta PUSH
.if BROKEN
; HEAD = 0
    lda #0
    sta HEAD
.endif
    jsr checked_step
    jsr emit_state
; INPUT_X = 2
    lda #2
    sta INPUT_X
; INPUT_Y = 3
    lda #3
    sta INPUT_Y
; PUSH = 1
    lda #1
    sta PUSH
.if BROKEN
; HEAD = 0
    lda #0
    sta HEAD
.endif
    jsr checked_step
    jsr emit_state
; INPUT_X = 3
    lda #3
    sta INPUT_X
; INPUT_Y = 4
    lda #4
    sta INPUT_Y
; PUSH = 1
    lda #1
    sta PUSH
.if BROKEN
; HEAD = 0
    lda #0
    sta HEAD
.endif
    jsr checked_step
    jsr emit_state
; INPUT_X = 4
    lda #4
    sta INPUT_X
; INPUT_Y = 5
    lda #5
    sta INPUT_Y
; PUSH = 1
    lda #1
    sta PUSH
.if BROKEN
; HEAD = 0
    lda #0
    sta HEAD
.endif
    jsr checked_step
    jsr emit_state
; INPUT_X = 5
    lda #5
    sta INPUT_X
; INPUT_Y = 6
    lda #6
    sta INPUT_Y
; PUSH = 1
    lda #1
    sta PUSH
.if BROKEN
; HEAD = 0
    lda #0
    sta HEAD
.endif
    jsr checked_step
    jsr emit_state
; INPUT_X = 6
    lda #6
    sta INPUT_X
; INPUT_Y = 7
    lda #7
    sta INPUT_Y
; PUSH = 1
    lda #1
    sta PUSH
.if BROKEN
; HEAD = 0
    lda #0
    sta HEAD
.endif
    jsr checked_step
    jsr emit_state
; INPUT_X = 7
    lda #7
    sta INPUT_X
; INPUT_Y = 8
    lda #8
    sta INPUT_Y
; PUSH = 1
    lda #1
    sta PUSH
.if BROKEN
; HEAD = 0
    lda #0
    sta HEAD
.endif
    jsr checked_step
    jsr emit_state
; INPUT_X = 8
    lda #8
    sta INPUT_X
; INPUT_Y = 9
    lda #9
    sta INPUT_Y
; PUSH = 1
    lda #1
    sta PUSH
.if BROKEN
; HEAD = 0
    lda #0
    sta HEAD
.endif
    jsr checked_step
    jsr emit_state
; PUSH = 0
    lda #0
    sta PUSH
; LAG = 7
    lda #7
    sta LAG
.if BROKEN
; HEAD = 0
    lda #0
    sta HEAD
.endif
    jsr checked_step
    jsr emit_state
    rts
.else
; INPUT_X = 10
    lda #10
    sta INPUT_X
; INPUT_Y = 20
    lda #20
    sta INPUT_Y
; PUSH = 1
    lda #1
    sta PUSH
.if BROKEN
; HEAD = 0
    lda #0
    sta HEAD
.endif
    jsr checked_step
    jsr emit_state
; INPUT_X = 30
    lda #30
    sta INPUT_X
; INPUT_Y = 40
    lda #40
    sta INPUT_Y
.if BROKEN
; HEAD = 0
    lda #0
    sta HEAD
.endif
    jsr checked_step
    jsr emit_state
; INPUT_X = 50
    lda #50
    sta INPUT_X
; INPUT_Y = 60
    lda #60
    sta INPUT_Y
.if BROKEN
; HEAD = 0
    lda #0
    sta HEAD
.endif
    jsr checked_step
    jsr emit_state
; PUSH = 0
    lda #0
    sta PUSH
; LAG = 2
    lda #2
    sta LAG
.if BROKEN
; HEAD = 0
    lda #0
    sta HEAD
.endif
    jsr checked_step
    jsr emit_state
.endif
    rts
; End of worldkit client.
