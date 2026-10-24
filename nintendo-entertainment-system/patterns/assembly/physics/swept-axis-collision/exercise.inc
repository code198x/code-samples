exercise_rules:
    lda #<(OUTPUT)
    sta ptr
    lda #>(OUTPUT)
    sta ptr+1
    lda #165
    jsr emit
    lda #11
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
    jsr swept_axis_collision_init
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
    jsr swept_axis_collision_init
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
    jsr swept_axis_collision_step
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
; OLD_POSITION = 20
    lda #20
    sta OLD_POSITION
; TARGET = 2
    lda #2
    sta TARGET
; SIZE = 2
    lda #2
    sta SIZE
; WALL_START = 10
    lda #10
    sta WALL_START
; WALL_END = 12
    lda #12
    sta WALL_END
.if BROKEN
; TARGET = OLD_POSITION
    lda OLD_POSITION
    sta TARGET
.endif
    jsr checked_step
    jsr emit_state
    rts
.else
; OLD_POSITION = 2
    lda #2
    sta OLD_POSITION
; TARGET = 20
    lda #20
    sta TARGET
; SIZE = 3
    lda #3
    sta SIZE
; WALL_START = 10
    lda #10
    sta WALL_START
; WALL_END = 12
    lda #12
    sta WALL_END
.if BROKEN
; TARGET = OLD_POSITION
    lda OLD_POSITION
    sta TARGET
.endif
    jsr checked_step
    jsr emit_state
.endif
    rts
; End of toolkit client.
