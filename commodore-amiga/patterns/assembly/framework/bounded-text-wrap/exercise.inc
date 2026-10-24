exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #9,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #21,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr bounded_text_wrap_init
    bsr emit_state
    lea case_table,a3
    moveq #44,d6
case_loop:
    lea STATE,a0
    moveq #21,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr bounded_text_wrap_init
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
    bsr bounded_text_wrap_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #21,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: retain private state between service calls.
preview_rules:
    ifne CUSTOM
; COUNT = 8
    move.b #8,d0
    move.b d0,COUNT
; WIDTH = 3
    move.b #3,d0
    move.b d0,WIDTH
; C0 = 65
    move.b #65,d0
    move.b d0,C0
; C1 = 66
    move.b #66,d0
    move.b d0,C1
; C2 = 67
    move.b #67,d0
    move.b d0,C2
; C3 = 68
    move.b #68,d0
    move.b d0,C3
; C4 = 69
    move.b #69,d0
    move.b d0,C4
; C5 = 70
    move.b #70,d0
    move.b d0,C5
; C6 = 71
    move.b #71,d0
    move.b d0,C6
; C7 = 72
    move.b #72,d0
    move.b d0,C7
    ifne BROKEN
; WIDTH = 1
    move.b #1,d0
    move.b d0,WIDTH
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; COUNT = 11
    move.b #11,d0
    move.b d0,COUNT
; WIDTH = 7
    move.b #7,d0
    move.b d0,WIDTH
; C0 = 72
    move.b #72,d0
    move.b d0,C0
; C1 = 69
    move.b #69,d0
    move.b d0,C1
; C2 = 76
    move.b #76,d0
    move.b d0,C2
; C3 = 76
    move.b #76,d0
    move.b d0,C3
; C4 = 79
    move.b #79,d0
    move.b d0,C4
; C5 = 32
    move.b #32,d0
    move.b d0,C5
; C6 = 87
    move.b #87,d0
    move.b d0,C6
; C7 = 79
    move.b #79,d0
    move.b d0,C7
; C8 = 82
    move.b #82,d0
    move.b d0,C8
; C9 = 76
    move.b #76,d0
    move.b d0,C9
; C10 = 68
    move.b #68,d0
    move.b d0,C10
    ifne BROKEN
; WIDTH = 1
    move.b #1,d0
    move.b d0,WIDTH
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of toolkit client.
