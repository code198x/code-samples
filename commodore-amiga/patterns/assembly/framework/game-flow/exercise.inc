exercise_flow:
    lea OUTPUT,a2
    move.l #165,d0
    bsr emit
    moveq #RESET_HEALTH,d0
    bsr emit
    moveq #0,d4
case_state_loop:
    moveq #0,d5
case_events_loop:
    move.b d4,flow_state
    move.b d5,flow_events
    bsr checked_step
    bsr emit_flow
    addq.l #1,d5
    cmpi.l #16,d5
    bne.s case_events_loop
    addq.l #1,d4
    cmpi.l #4,d4
    bne.s case_state_loop
invalid_state_loop:
    move.b d4,flow_state
    clr.b flow_events
    bsr checked_step
    bsr emit_flow
    addq.l #1,d4
    cmpi.l #256,d4
    bne.s invalid_state_loop
    move.b flow_error,invalid_seen
    moveq #0,d4
upper_state_loop:
    moveq #0,d5
upper_event_loop:
    lea upper_events,a0
    move.b 0(a0,d5.w),flow_events
    move.b d4,flow_state
    bsr checked_step
    bsr emit_flow
    addq.l #1,d5
    cmpi.l #3,d5
    bne.s upper_event_loop
    addq.l #1,d4
    cmpi.l #4,d4
    bne.s upper_state_loop
    bsr preview_flow
    move.l #239,d0
    bsr emit
    rts
checked_step:
    move.l #$9352,d1
    bsr flow_step
    cmpi.l #$9352,d1
    bne.s flow_failed
    rts
flow_failed:
    bra flow_failed
emit_flow:
    move.b flow_state,d0
    bsr emit
    move.b flow_changed,d0
    bsr emit
    move.b flow_fresh,d0
    bsr emit
    move.b flow_error,d0
    bra emit
emit:
    move.b d0,(a2)+
    rts
; Minimal logical session client; input history is not session payload.
preview_flow:
    bsr flow_init
    clr.b previous
    clr.b score
    clr.b resets
    move.b #RESET_HEALTH,health
    moveq #0,d4
trace_loop:
    lea held_samples,a0
    move.b 0(a0,d4.w),d0
    move.b d0,held
    move.b previous,d0
    not.b d0
    and.b held,d0
    move.b d0,flow_events
    move.b held,previous
    cmpi.b #1,flow_state
    bne.s trace_decide
    addq.b #1,score
trace_decide:
    bsr checked_step
    ifne BROKEN
    tst.b flow_changed
    beq.s trace_after_reset
    cmpi.b #1,flow_state
    bne.s trace_after_reset
    else
    tst.b flow_fresh
    beq.s trace_after_reset
    endc
    bsr reset_session
trace_after_reset:
    cmpi.l #8,d4
    bne.s trace_not_resume
    move.b score,resumed
trace_not_resume:
    cmpi.l #10,d4
    bne.s trace_record
    move.b score,finished
trace_record:
    bsr emit_flow
    move.b score,d0
    bsr emit
    move.b previous,d0
    bsr emit
    addq.l #1,d4
    cmpi.l #15,d4
    bne trace_loop
    move.b resumed,preview
    move.b resets,preview+1
    move.b flow_state,preview+2
    move.b score,preview+3
    move.b health,preview+4
    move.b finished,preview+5
    move.b invalid_seen,preview+6
    move.b flow_changed,preview+7
    rts
reset_session:
    clr.b score
    move.b #RESET_HEALTH,health
    addq.b #1,resets
    rts
; End of session client.
upper_events: dc.b 16,128,255
held_samples: dc.b 0,3,3,0,0,3,3,0,3,0,4,0,8,8,0
    even
