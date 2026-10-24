exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #14,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #18,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr stable_compaction_init
    bsr emit_state
    lea case_table,a3
    moveq #51,d6
case_loop:
    lea STATE,a0
    moveq #18,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr stable_compaction_init
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
    bsr stable_compaction_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #18,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: retain private state between service calls.
preview_rules:
    ifne CUSTOM
; COUNT = 4
    move.b #4,d0
    move.b d0,COUNT
; F1 = 1
    move.b #1,d0
    move.b d0,F1
; F3 = 1
    move.b #1,d0
    move.b d0,F3
; I0 = 20
    move.b #20,d0
    move.b d0,I0
; I1 = 21
    move.b #21,d0
    move.b d0,I1
; I2 = 22
    move.b #22,d0
    move.b d0,I2
; I3 = 23
    move.b #23,d0
    move.b d0,I3
; I4 = 24
    move.b #24,d0
    move.b d0,I4
; I5 = 25
    move.b #25,d0
    move.b d0,I5
; I6 = 26
    move.b #26,d0
    move.b d0,I6
; I7 = 27
    move.b #27,d0
    move.b d0,I7
    ifne BROKEN
; COUNT = 8
    move.b #8,d0
    move.b d0,COUNT
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; COUNT = 6
    move.b #6,d0
    move.b d0,COUNT
; F0 = 1
    move.b #1,d0
    move.b d0,F0
; F2 = 1
    move.b #1,d0
    move.b d0,F2
; F4 = 1
    move.b #1,d0
    move.b d0,F4
; F7 = 1
    move.b #1,d0
    move.b d0,F7
; I0 = 10
    move.b #10,d0
    move.b d0,I0
; I1 = 11
    move.b #11,d0
    move.b d0,I1
; I2 = 12
    move.b #12,d0
    move.b d0,I2
; I3 = 13
    move.b #13,d0
    move.b d0,I3
; I4 = 14
    move.b #14,d0
    move.b d0,I4
; I5 = 15
    move.b #15,d0
    move.b d0,I5
; I6 = 16
    move.b #16,d0
    move.b d0,I6
; I7 = 99
    move.b #99,d0
    move.b d0,I7
    ifne BROKEN
; COUNT = 8
    move.b #8,d0
    move.b d0,COUNT
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of worldkit client.
