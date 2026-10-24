exercise_rules:
    lda #<(OUTPUT)
    sta ptr
    lda #>(OUTPUT)
    sta ptr+1
    lda #165
    jsr emit
    lda #PERIOD
    jsr emit
    lda #255
    sta HEALTH
    sta REMAINING
    sta AMOUNT
    sta APPLIED
    sta KILLED
    jsr damage_init
    lda HEALTH
    jsr emit
    lda REMAINING
    jsr emit
    lda AMOUNT
    jsr emit
    lda APPLIED
    jsr emit
    lda KILLED
    jsr emit
    lda #<(case_table)
    sta input_ptr
    lda #>(case_table)
    sta input_ptr+1
    lda #<(298)
    sta cases_left
    lda #>(298)
    sta cases_left+1
case_loop:
    jsr read_case
    sta HEALTH
    jsr read_case
    sta REMAINING
    jsr read_case
    sta AMOUNT
    lda #255
    sta APPLIED
    sta KILLED
    jsr checked_step
    jsr emit_state
    lda cases_left
    bne case_no_borrow
    dec cases_left+1
case_no_borrow:
    dec cases_left
    lda cases_left
    ora cases_left+1
    bne case_loop
    jsr preview_rules
    lda #239
    jsr emit
    rts
read_case:
    ldy #0
    lda (input_ptr),y
    inc input_ptr
    bne read_done
    inc input_ptr+1
read_done:
    rts
checked_step:
    ldx #$52
    ldy #$93
    jsr damage_step
    cpx #$52
    bne rules_failed
    cpy #$93
    bne rules_failed
    rts
rules_failed:
    jmp rules_failed
emit_state:
    lda HEALTH
    jsr emit
    lda REMAINING
    jsr emit
    lda APPLIED
    jsr emit
    lda KILLED
    jmp emit
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
; Sustained contact: aggregate before one service/entity/update.
preview_rules:
    jsr damage_init
    lda #0
    sta accepted
    sta deaths
    sta blocked
    sta trace_index
    lda #255
    sta first_death
trace_loop:
    lda #1
    sta AMOUNT
!if BROKEN {
    lda #PERIOD
    sta REMAINING
}
    jsr checked_step
    lda APPLIED
    beq trace_no_apply
    inc accepted
trace_no_apply:
    lda KILLED
    beq trace_no_death
    inc deaths
    lda first_death
    cmp #255
    bne trace_no_death
    lda trace_index
    sta first_death
trace_no_death:
    lda HEALTH
    beq trace_after_block
    lda APPLIED
    bne trace_after_block
    inc blocked
trace_after_block:
    lda trace_index
    cmp #4
    bne trace_record
    lda HEALTH
    sta snapshot
trace_record:
    jsr emit_state
    inc trace_index
    lda trace_index
    cmp #12
    bne trace_loop
    lda accepted
    sta preview
    lda first_death
    sta preview+1
    lda HEALTH
    sta preview+2
    lda REMAINING
    sta preview+3
    lda deaths
    sta preview+4
    lda blocked
    sta preview+5
    lda snapshot
    sta preview+6
    lda #PERIOD
    sta preview+7
    rts
; End of rules client.
