exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #3,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #9,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr event_queue_init
    bsr emit_state
    lea case_table,a3
    moveq #95,d6
case_loop:
    lea STATE,a0
    moveq #9,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr event_queue_init
    bsr preview_rules
    lea preview,a0
    moveq #7,d0
preview_clear:
    clr.b (a0)+
    dbra d0,preview_clear
    lea STATE,a0
    lea preview,a1
    moveq #7,d0
preview_copy:
    move.b (a0)+,(a1)+
    dbra d0,preview_copy
    move.b #239,(a4)+
    rts
checked_step:
    move.l #$52a39374,d4
    movea.l #$12345,a2
    bsr event_queue_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #9,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: initialise once, then retain state between calls.
preview_rules:
    ifne CUSTOM
    move.b #17,VALUE
    move.b #1,MODE
    ifne BROKEN
    cmp.b #1,MODE
    bne.s trace_skip_reset_0_custom
    move.b #0,HEAD
    move.b #0,TAIL
    move.b #0,COUNT
trace_skip_reset_0_custom:
    bsr checked_step
    else
    bsr checked_step
    endif
    bsr emit_state
    move.b #34,VALUE
    move.b #1,MODE
    ifne BROKEN
    cmp.b #1,MODE
    bne.s trace_skip_reset_1_custom
    move.b #0,HEAD
    move.b #0,TAIL
    move.b #0,COUNT
trace_skip_reset_1_custom:
    bsr checked_step
    else
    bsr checked_step
    endif
    bsr emit_state
    move.b #51,VALUE
    move.b #1,MODE
    ifne BROKEN
    cmp.b #1,MODE
    bne.s trace_skip_reset_2_custom
    move.b #0,HEAD
    move.b #0,TAIL
    move.b #0,COUNT
trace_skip_reset_2_custom:
    bsr checked_step
    else
    bsr checked_step
    endif
    bsr emit_state
    move.b #2,MODE
    ifne BROKEN
    cmp.b #1,MODE
    bne.s trace_skip_reset_3_custom
    move.b #0,HEAD
    move.b #0,TAIL
    move.b #0,COUNT
trace_skip_reset_3_custom:
    bsr checked_step
    else
    bsr checked_step
    endif
    bsr emit_state
    move.b #2,MODE
    ifne BROKEN
    cmp.b #1,MODE
    bne.s trace_skip_reset_4_custom
    move.b #0,HEAD
    move.b #0,TAIL
    move.b #0,COUNT
trace_skip_reset_4_custom:
    bsr checked_step
    else
    bsr checked_step
    endif
    bsr emit_state
    move.b #2,MODE
    ifne BROKEN
    cmp.b #1,MODE
    bne.s trace_skip_reset_5_custom
    move.b #0,HEAD
    move.b #0,TAIL
    move.b #0,COUNT
trace_skip_reset_5_custom:
    bsr checked_step
    else
    bsr checked_step
    endif
    bsr emit_state
    else
    move.b #17,VALUE
    move.b #1,MODE
    ifne BROKEN
    cmp.b #1,MODE
    bne.s trace_skip_reset_0
    move.b #0,HEAD
    move.b #0,TAIL
    move.b #0,COUNT
trace_skip_reset_0:
    bsr checked_step
    else
    bsr checked_step
    endif
    bsr emit_state
    move.b #34,VALUE
    move.b #1,MODE
    ifne BROKEN
    cmp.b #1,MODE
    bne.s trace_skip_reset_1
    move.b #0,HEAD
    move.b #0,TAIL
    move.b #0,COUNT
trace_skip_reset_1:
    bsr checked_step
    else
    bsr checked_step
    endif
    bsr emit_state
    move.b #51,VALUE
    move.b #1,MODE
    ifne BROKEN
    cmp.b #1,MODE
    bne.s trace_skip_reset_2
    move.b #0,HEAD
    move.b #0,TAIL
    move.b #0,COUNT
trace_skip_reset_2:
    bsr checked_step
    else
    bsr checked_step
    endif
    bsr emit_state
    move.b #2,MODE
    ifne BROKEN
    cmp.b #1,MODE
    bne.s trace_skip_reset_3
    move.b #0,HEAD
    move.b #0,TAIL
    move.b #0,COUNT
trace_skip_reset_3:
    bsr checked_step
    else
    bsr checked_step
    endif
    bsr emit_state
    move.b #2,MODE
    ifne BROKEN
    cmp.b #1,MODE
    bne.s trace_skip_reset_4
    move.b #0,HEAD
    move.b #0,TAIL
    move.b #0,COUNT
trace_skip_reset_4:
    bsr checked_step
    else
    bsr checked_step
    endif
    bsr emit_state
    move.b #2,MODE
    ifne BROKEN
    cmp.b #1,MODE
    bne.s trace_skip_reset_5
    move.b #0,HEAD
    move.b #0,TAIL
    move.b #0,COUNT
trace_skip_reset_5:
    bsr checked_step
    else
    bsr checked_step
    endif
    bsr emit_state
    endif
    rts
; End of gameplay client.
