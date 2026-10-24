; Second client: enumerate decisions, invalid states and illegal event bits.
exercise_flow:
    lda #<(OUTPUT)
    sta ptr
    lda #>(OUTPUT)
    sta ptr+1
    lda #165
    jsr emit
    lda #RESET_HEALTH
    jsr emit
    lda #0
    sta case_state
case_state_loop:
    lda #0
    sta case_events
case_events_loop:
    lda case_state
    sta FLOW_STATE
    lda case_events
    sta FLOW_EVENTS
    jsr checked_step
    jsr emit_flow
    inc case_events
    lda case_events
    cmp #16
    bne case_events_loop
    inc case_state
    lda case_state
    cmp #4
    bne case_state_loop
invalid_state_loop:
    lda case_state
    sta FLOW_STATE
    lda #0
    sta FLOW_EVENTS
    jsr checked_step
    jsr emit_flow
    inc case_state
    bne invalid_state_loop
    lda FLOW_ERROR
    sta invalid_seen
    lda #0
    sta case_state
upper_state_loop:
    lda #0
    sta case_events
upper_event_loop:
    ldx case_events
    lda upper_events,x
    sta FLOW_EVENTS
    lda case_state
    sta FLOW_STATE
    jsr checked_step
    jsr emit_flow
    inc case_events
    lda case_events
    cmp #3
    bne upper_event_loop
    inc case_state
    lda case_state
    cmp #4
    bne upper_state_loop
    jsr preview_flow
    lda #239
    jsr emit
    rts
checked_step:
    ldx #$52
    ldy #$93
    jsr flow_step
    cpx #$52
    bne flow_failed
    cpy #$93
    bne flow_failed
    rts
flow_failed:
    jmp flow_failed
emit_flow:
    lda FLOW_STATE
    jsr emit
    lda FLOW_CHANGED
    jsr emit
    lda FLOW_FRESH
    jsr emit
    lda FLOW_ERROR
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
; Minimal integration: compute edges, update the OLD state, transition once,
; consume FRESH for session reset. Input history belongs to the sampler.
preview_flow:
    jsr flow_init
    lda #0
    sta previous
    sta score
    sta resets
    sta trace_index
    lda #RESET_HEALTH
    sta health
trace_loop:
    ldx trace_index
    lda held_samples,x
    sta held
    lda previous
    eor #255
    and held
    sta FLOW_EVENTS
    lda held
    sta previous
    lda FLOW_STATE
    cmp #1
    bne trace_decide
    inc score
trace_decide:
    jsr checked_step
!if BROKEN {
    lda FLOW_CHANGED
    beq trace_after_reset
    lda FLOW_STATE
    cmp #1
    bne trace_after_reset
} else {
    lda FLOW_FRESH
    beq trace_after_reset
}
    jsr reset_session
trace_after_reset:
    lda trace_index
    cmp #8
    bne trace_not_resume
    lda score
    sta resumed
trace_not_resume:
    lda trace_index
    cmp #10
    bne trace_record
    lda score
    sta finished
trace_record:
    jsr emit_flow
    lda score
    jsr emit
    lda previous
    jsr emit
    inc trace_index
    lda trace_index
    cmp #15
    bne trace_loop
    lda resumed
    sta preview
    lda resets
    sta preview+1
    lda FLOW_STATE
    sta preview+2
    lda score
    sta preview+3
    lda health
    sta preview+4
    lda finished
    sta preview+5
    lda invalid_seen
    sta preview+6
    lda FLOW_CHANGED
    sta preview+7
    rts
reset_session:
    lda #0
    sta score
    lda #RESET_HEALTH
    sta health
    inc resets
    rts
; End of session client.
upper_events:
    !byte 16,128,255
held_samples:
    !byte 0,3,3,0,0,3,3,0,3,0,4,0,8,8,0
