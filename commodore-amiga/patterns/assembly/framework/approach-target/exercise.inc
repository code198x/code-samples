exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #5,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #3,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr approach_target_init
    bsr emit_state
    lea case_table,a3
    moveq #95,d6
case_loop:
    lea STATE,a0
    moveq #3,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr approach_target_init
    bsr preview_rules
    lea preview,a0
    moveq #7,d0
preview_clear:
    clr.b (a0)+
    dbra d0,preview_clear
    lea STATE,a0
    lea preview,a1
    moveq #3,d0
preview_copy:
    move.b (a0)+,(a1)+
    dbra d0,preview_copy
    move.b #239,(a4)+
    rts
checked_step:
    move.l #$52a39374,d4
    movea.l #$12345,a2
    bsr approach_target_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #3,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: initialise once, then retain state between calls.
preview_rules:
    ifne CUSTOM
    move.b #250,POSITION
    move.b #255,TARGET
    move.b #2,STEP
    ifne BROKEN
    move.b STEP,d0
    add.b d0,POSITION
    clr.b ARRIVED
    move.b POSITION,d0
    cmp.b TARGET,d0
    bne.s trace_bad_end_0_custom
    move.b #1,ARRIVED
trace_bad_end_0_custom:
    else
    bsr checked_step
    endif
    bsr emit_state
    ifne BROKEN
    move.b STEP,d0
    add.b d0,POSITION
    clr.b ARRIVED
    move.b POSITION,d0
    cmp.b TARGET,d0
    bne.s trace_bad_end_1_custom
    move.b #1,ARRIVED
trace_bad_end_1_custom:
    else
    bsr checked_step
    endif
    bsr emit_state
    else
    move.b #250,POSITION
    move.b #255,TARGET
    move.b #10,STEP
    ifne BROKEN
    move.b STEP,d0
    add.b d0,POSITION
    clr.b ARRIVED
    move.b POSITION,d0
    cmp.b TARGET,d0
    bne.s trace_bad_end_0
    move.b #1,ARRIVED
trace_bad_end_0:
    else
    bsr checked_step
    endif
    bsr emit_state
    ifne BROKEN
    move.b STEP,d0
    add.b d0,POSITION
    clr.b ARRIVED
    move.b POSITION,d0
    cmp.b TARGET,d0
    bne.s trace_bad_end_1
    move.b #1,ARRIVED
trace_bad_end_1:
    else
    bsr checked_step
    endif
    bsr emit_state
    endif
    rts
; End of gameplay client.
