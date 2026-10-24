exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #8,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #14,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr save_record_validation_init
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
    bsr save_record_validation_init
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
    bsr save_record_validation_step
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
; MODE = 0
    move.b #0,d0
    move.b d0,MODE
; L0 = 9
    move.b #9,d0
    move.b d0,L0
; C0 = 198
    move.b #198,d0
    move.b d0,C0
; C1 = 1
    move.b #1,d0
    move.b d0,C1
; C2 = 4
    move.b #4,d0
    move.b d0,C2
; C3 = 15
    move.b #15,d0
    move.b d0,C3
; C4 = 31
    move.b #31,d0
    move.b d0,C4
; C5 = 9
    move.b #9,d0
    move.b d0,C5
; C6 = 15
    move.b #15,d0
    move.b d0,C6
; C7 = 213
    move.b #213,d0
    move.b d0,C7
    ifne BROKEN
; C7 = 0
    move.b #0,d0
    move.b d0,C7
    endif
    bsr checked_step
    bsr emit_state
; MODE = 1
    move.b #1,d0
    move.b d0,MODE
    ifne BROKEN
; C7 = 0
    move.b #0,d0
    move.b d0,C7
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; MODE = 1
    move.b #1,d0
    move.b d0,MODE
; L0 = 2
    move.b #2,d0
    move.b d0,L0
; L1 = 3
    move.b #3,d0
    move.b d0,L1
; L2 = 4
    move.b #4,d0
    move.b d0,L2
; L3 = 5
    move.b #5,d0
    move.b d0,L3
; C0 = 198
    move.b #198,d0
    move.b d0,C0
; C1 = 1
    move.b #1,d0
    move.b d0,C1
; C2 = 4
    move.b #4,d0
    move.b d0,C2
; C3 = 7
    move.b #7,d0
    move.b d0,C3
; C4 = 20
    move.b #20,d0
    move.b d0,C4
; C5 = 3
    move.b #3,d0
    move.b d0,C5
; C6 = 2
    move.b #2,d0
    move.b d0,C6
; C7 = 209
    move.b #209,d0
    move.b d0,C7
    ifne BROKEN
; C7 = 0
    move.b #0,d0
    move.b d0,C7
    endif
    bsr checked_step
    bsr emit_state
; C5 = 255
    move.b #255,d0
    move.b d0,C5
    ifne BROKEN
; C7 = 0
    move.b #0,d0
    move.b d0,C7
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of nighttwo client.
