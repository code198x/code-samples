exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #10,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #14,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr spawn_timeline_init
    bsr emit_state
    lea case_table,a3
    moveq #63,d6
case_loop:
    lea STATE,a0
    moveq #14,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr spawn_timeline_init
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
    bsr spawn_timeline_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #14,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: retain private state between service calls.
preview_rules:
    ifne CUSTOM
; COUNT = 2
    move.b #2,d0
    move.b d0,COUNT
; E0 = 9
    move.b #9,d0
    move.b d0,E0
; E1 = 3
    move.b #3,d0
    move.b d0,E1
; L0 = 1
    move.b #1,d0
    move.b d0,L0
; L1 = 0
    move.b #0,d0
    move.b d0,L1
    ifne BROKEN
; INDEX = 0
    move.b #0,d0
    move.b d0,INDEX
    endif
    bsr checked_step
    bsr emit_state

    ifne BROKEN
; INDEX = 0
    move.b #0,d0
    move.b d0,INDEX
    endif
    bsr checked_step
    bsr emit_state

    ifne BROKEN
; INDEX = 0
    move.b #0,d0
    move.b d0,INDEX
    endif
    bsr checked_step
    bsr emit_state

    ifne BROKEN
; INDEX = 0
    move.b #0,d0
    move.b d0,INDEX
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; COUNT = 3
    move.b #3,d0
    move.b d0,COUNT
; E0 = 2
    move.b #2,d0
    move.b d0,E0
; E1 = 4
    move.b #4,d0
    move.b d0,E1
; E2 = 7
    move.b #7,d0
    move.b d0,E2
; L0 = 0
    move.b #0,d0
    move.b d0,L0
; L1 = 2
    move.b #2,d0
    move.b d0,L1
; L2 = 1
    move.b #1,d0
    move.b d0,L2
    ifne BROKEN
; INDEX = 0
    move.b #0,d0
    move.b d0,INDEX
    endif
    bsr checked_step
    bsr emit_state

    ifne BROKEN
; INDEX = 0
    move.b #0,d0
    move.b d0,INDEX
    endif
    bsr checked_step
    bsr emit_state

    ifne BROKEN
; INDEX = 0
    move.b #0,d0
    move.b d0,INDEX
    endif
    bsr checked_step
    bsr emit_state

    ifne BROKEN
; INDEX = 0
    move.b #0,d0
    move.b d0,INDEX
    endif
    bsr checked_step
    bsr emit_state

    ifne BROKEN
; INDEX = 0
    move.b #0,d0
    move.b d0,INDEX
    endif
    bsr checked_step
    bsr emit_state

    ifne BROKEN
; INDEX = 0
    move.b #0,d0
    move.b d0,INDEX
    endif
    bsr checked_step
    bsr emit_state

    ifne BROKEN
; INDEX = 0
    move.b #0,d0
    move.b d0,INDEX
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of worldkit client.
