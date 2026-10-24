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
    sta REMAINING
    sta REQUEST
    sta AVAILABLE
    sta GRANTED
    jsr cooldown_init
    lda REMAINING
    jsr emit
    lda REQUEST
    jsr emit
    lda AVAILABLE
    jsr emit
    lda GRANTED
    jsr emit
    lda #<(case_table)
    sta input_ptr
    lda #>(case_table)
    sta input_ptr+1
    lda #<(1024)
    sta cases_left
    lda #>(1024)
    sta cases_left+1
case_loop:
    jsr read_case
    sta case_kind
    jsr read_case
    sta REMAINING
    jsr read_case
    sta REQUEST
    jsr read_case
    sta AVAILABLE
    lda #255
    sta GRANTED
    lda case_kind
    bne case_no_tick
    jsr checked_tick
case_no_tick:
    jsr checked_try
    lda case_kind
    bne case_packed
    lda REMAINING
    jsr emit
    lda GRANTED
    jsr emit
    jmp case_next
case_packed:
    lda REMAINING
    bmi rules_failed
    lda GRANTED
    beq case_pack_plain
    lda REMAINING
    ora #128
    bne case_pack_emit
case_pack_plain:
    lda REMAINING
case_pack_emit:
    jsr emit
case_next:
    lda cases_left
    bne case_no_borrow
    dec cases_left+1
case_no_borrow:
    dec cases_left
    lda cases_left
    ora cases_left+1
    bne case_loop
    lda #0
    sta REMAINING
    sta AVAILABLE
    lda #1
    sta REQUEST
    jsr checked_try
    lda GRANTED
    ora REMAINING
    bne rules_failed
    lda #1
    sta availability_guard
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
checked_tick:
    ldx #$52
    ldy #$93
    jsr cooldown_tick
    jmp check_registers
checked_try:
    ldx #$52
    ldy #$93
    jsr cooldown_try
    lda GRANTED
    cmp #2
    bcs rules_failed
check_registers:
    cpx #$52
    bne rules_failed
    cpy #$93
    bne rules_failed
    rts
rules_failed:
    jmp rules_failed
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
; Tick independently of the action request; then commit only if a resource exists.
preview_rules:
    jsr cooldown_init
    lda #0
    sta accepted
    sta blocked
    sta trace_index
trace_loop:
    ldx trace_index
    lda trace_requests,x
    sta REQUEST
    lda #1
    sta AVAILABLE
.if BROKEN
    lda REQUEST
    beq trace_no_tick
.endif
    jsr checked_tick
trace_no_tick:
    jsr checked_try
    lda GRANTED
    beq trace_no_grant
    inc accepted
trace_no_grant:
    lda REQUEST
    beq trace_after_block
    lda GRANTED
    bne trace_after_block
    inc blocked
trace_after_block:
    lda trace_index
    cmp #3
    bne trace_not_three
    lda GRANTED
    sta at_three
trace_not_three:
    lda trace_index
    cmp #6
    bne trace_record
    lda GRANTED
    sta at_six
trace_record:
    lda REMAINING
    jsr emit
    lda REQUEST
    jsr emit
    lda AVAILABLE
    jsr emit
    lda GRANTED
    jsr emit
    inc trace_index
    lda trace_index
    cmp #12
    bne trace_loop
    lda accepted
    sta preview
    lda REMAINING
    sta preview+1
    lda at_three
    sta preview+2
    lda at_six
    sta preview+3
    lda blocked
    sta preview+4
    lda availability_guard
    sta preview+5
    lda #PERIOD
    sta preview+6
    lda GRANTED
    sta preview+7
    rts
; End of rules client.
trace_requests:
    .byte 1,0,0,1,0,0,1,0,0,1,0,0
