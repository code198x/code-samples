exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #8,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #20,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr dictionary_lookup_init
    bsr emit_state
    lea case_table,a3
    moveq #46,d6
case_loop:
    lea STATE,a0
    moveq #20,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr dictionary_lookup_init
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
    bsr dictionary_lookup_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #20,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: retain private state between service calls.
preview_rules:
    ifne CUSTOM
; COUNT = 1
    move.b #1,d0
    move.b d0,COUNT
; K0 = 255
    move.b #255,d0
    move.b d0,K0
; Q0 = 0
    move.b #0,d0
    move.b d0,Q0
; KEY = 255
    move.b #255,d0
    move.b d0,KEY
    ifne BROKEN
; KEY = 0
    move.b #0,d0
    move.b d0,KEY
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; COUNT = 3
    move.b #3,d0
    move.b d0,COUNT
; K0 = 10
    move.b #10,d0
    move.b d0,K0
; K1 = 20
    move.b #20,d0
    move.b d0,K1
; K2 = 20
    move.b #20,d0
    move.b d0,K2
; Q0 = 4
    move.b #4,d0
    move.b d0,Q0
; Q1 = 7
    move.b #7,d0
    move.b d0,Q1
; Q2 = 9
    move.b #9,d0
    move.b d0,Q2
; KEY = 20
    move.b #20,d0
    move.b d0,KEY
    ifne BROKEN
; KEY = 0
    move.b #0,d0
    move.b d0,KEY
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of toolkit client.
