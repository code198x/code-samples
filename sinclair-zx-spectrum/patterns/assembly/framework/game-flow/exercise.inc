exercise_flow:
    ld ix,OUTPUT
    ld a,165
    call emit
    ld a,RESET_HEALTH
    call emit
    xor a
    ld (case_state),a
case_state_loop:
    xor a
    ld (case_events),a
case_events_loop:
    ld a,(case_state)
    ld (flow_state),a
    ld a,(case_events)
    ld (flow_events),a
    call checked_step
    call emit_flow
    ld a,(case_events)
    inc a
    ld (case_events),a
    cp 16
    jr nz,case_events_loop
    ld a,(case_state)
    inc a
    ld (case_state),a
    cp 4
    jr nz,case_state_loop
invalid_state_loop:
    ld a,(case_state)
    ld (flow_state),a
    xor a
    ld (flow_events),a
    call checked_step
    call emit_flow
    ld a,(case_state)
    inc a
    ld (case_state),a
    jr nz,invalid_state_loop
    ld a,(flow_error)
    ld (invalid_seen),a
    xor a
    ld (case_state),a
upper_state_loop:
    xor a
    ld (case_events),a
upper_event_loop:
    ld a,(case_events)
    ld l,a
    ld h,0
    ld de,upper_events
    add hl,de
    ld a,(hl)
    ld (flow_events),a
    ld a,(case_state)
    ld (flow_state),a
    call checked_step
    call emit_flow
    ld a,(case_events)
    inc a
    ld (case_events),a
    cp 3
    jr nz,upper_event_loop
    ld a,(case_state)
    inc a
    ld (case_state),a
    cp 4
    jr nz,upper_state_loop
    call preview_flow
    ld a,239
    call emit
    ret
checked_step:
    ld bc,$9352
    ld de,$5a93
    ld hl,$1234
    call flow_step
    ld a,b
    cp $93
    jp nz,flow_failed
    ld a,c
    cp $52
    jp nz,flow_failed
    ld a,d
    cp $5a
    jp nz,flow_failed
    ld a,e
    cp $93
    jp nz,flow_failed
    ld a,h
    cp $12
    jp nz,flow_failed
    ld a,l
    cp $34
    jp nz,flow_failed
    ret
flow_failed:
    jp flow_failed
emit_flow:
    ld a,(flow_state)
    call emit
    ld a,(flow_changed)
    call emit
    ld a,(flow_fresh)
    call emit
    ld a,(flow_error)
    jp emit
emit:
    ld (ix+0),a
    inc ix
    ret
; Minimal session client; this supplied trace is logical input, not a reader.
preview_flow:
    call flow_init
    xor a
    ld (previous),a
    ld (score),a
    ld (resets),a
    ld (trace_index),a
    ld a,RESET_HEALTH
    ld (health),a
trace_loop:
    ld a,(trace_index)
    ld l,a
    ld h,0
    ld de,held_samples
    add hl,de
    ld a,(hl)
    ld (held),a
    ld a,(previous)
    cpl
    ld b,a
    ld a,(held)
    and b
    ld (flow_events),a
    ld a,(held)
    ld (previous),a
    ld a,(flow_state)
    cp 1
    jr nz,trace_decide
    ld a,(score)
    inc a
    ld (score),a
trace_decide:
    call checked_step
    if BROKEN
    ld a,(flow_changed)
    or a
    jr z,trace_after_reset
    ld a,(flow_state)
    cp 1
    jr nz,trace_after_reset
    else
    ld a,(flow_fresh)
    or a
    jr z,trace_after_reset
    endif
    call reset_session
trace_after_reset:
    ld a,(trace_index)
    cp 8
    jr nz,trace_not_resume
    ld a,(score)
    ld (resumed),a
trace_not_resume:
    ld a,(trace_index)
    cp 10
    jr nz,trace_record
    ld a,(score)
    ld (finished),a
trace_record:
    call emit_flow
    ld a,(score)
    call emit
    ld a,(previous)
    call emit
    ld a,(trace_index)
    inc a
    ld (trace_index),a
    cp 15
    jp nz,trace_loop
    ld a,(resumed)
    ld (preview),a
    ld a,(resets)
    ld (preview+1),a
    ld a,(flow_state)
    ld (preview+2),a
    ld a,(score)
    ld (preview+3),a
    ld a,(health)
    ld (preview+4),a
    ld a,(finished)
    ld (preview+5),a
    ld a,(invalid_seen)
    ld (preview+6),a
    ld a,(flow_changed)
    ld (preview+7),a
    ret
reset_session:
    xor a
    ld (score),a
    ld a,RESET_HEALTH
    ld (health),a
    ld a,(resets)
    inc a
    ld (resets),a
    ret
; End of session client.
upper_events: defb 16,128,255
held_samples: defb 0,3,3,0,0,3,3,0,3,0,4,0,8,8,0
