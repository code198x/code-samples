exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #8,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #5,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr priority_arbiter_init
    bsr emit_state
    lea case_table,a3
    moveq #95,d6
case_loop:
    lea STATE,a0
    moveq #5,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr priority_arbiter_init
    bsr preview_rules
    lea preview,a0
    moveq #7,d0
preview_clear:
    clr.b (a0)+
    dbra d0,preview_clear
    lea STATE,a0
    lea preview,a1
    moveq #5,d0
preview_copy:
    move.b (a0)+,(a1)+
    dbra d0,preview_copy
    move.b #239,(a4)+
    rts
checked_step:
    move.l #$52a39374,d4
    movea.l #$12345,a2
    bsr priority_arbiter_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #5,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: initialise once, then retain state between calls.
preview_rules:
    ifne CUSTOM
    move.b #7,REQUEST_ID
    move.b #1,REQUEST_PRIORITY
    ifne BROKEN
    move.b #0,PRESENT
    bsr checked_step
    else
    bsr checked_step
    endif
    bsr emit_state
    move.b #9,REQUEST_ID
    move.b #8,REQUEST_PRIORITY
    ifne BROKEN
    move.b #0,PRESENT
    bsr checked_step
    else
    bsr checked_step
    endif
    bsr emit_state
    move.b #5,REQUEST_ID
    move.b #2,REQUEST_PRIORITY
    ifne BROKEN
    move.b #0,PRESENT
    bsr checked_step
    else
    bsr checked_step
    endif
    bsr emit_state
    else
    move.b #7,REQUEST_ID
    move.b #8,REQUEST_PRIORITY
    ifne BROKEN
    move.b #0,PRESENT
    bsr checked_step
    else
    bsr checked_step
    endif
    bsr emit_state
    move.b #9,REQUEST_ID
    move.b #8,REQUEST_PRIORITY
    ifne BROKEN
    move.b #0,PRESENT
    bsr checked_step
    else
    bsr checked_step
    endif
    bsr emit_state
    move.b #5,REQUEST_ID
    move.b #2,REQUEST_PRIORITY
    ifne BROKEN
    move.b #0,PRESENT
    bsr checked_step
    else
    bsr checked_step
    endif
    bsr emit_state
    endif
    rts
; End of gameplay client.
