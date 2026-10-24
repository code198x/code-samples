exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #2,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #19,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr push_block_transaction_init
    bsr emit_state
    lea case_table,a3
    moveq #49,d6
case_loop:
    lea STATE,a0
    moveq #19,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr push_block_transaction_init
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
    bsr push_block_transaction_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #19,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: retain private state between service calls.
preview_rules:
    ifne CUSTOM
; CELL = 8
    move.b #8,d0
    move.b d0,CELL
; REQUEST = 3
    move.b #3,d0
    move.b d0,REQUEST
; C4 = 2
    move.b #2,d0
    move.b d0,C4
    ifne BROKEN
; C6 = 1
    move.b #1,d0
    move.b d0,C6
    endif
    bsr checked_step
    bsr emit_state
; REQUEST = 2
    move.b #2,d0
    move.b d0,REQUEST
    ifne BROKEN
; C6 = 1
    move.b #1,d0
    move.b d0,C6
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; CELL = 4
    move.b #4,d0
    move.b d0,CELL
; REQUEST = 2
    move.b #2,d0
    move.b d0,REQUEST
; C5 = 2
    move.b #2,d0
    move.b d0,C5
    ifne BROKEN
; C6 = 1
    move.b #1,d0
    move.b d0,C6
    endif
    bsr checked_step
    bsr emit_state

    ifne BROKEN
; C6 = 1
    move.b #1,d0
    move.b d0,C6
    endif
    bsr checked_step
    bsr emit_state

    ifne BROKEN
; C6 = 1
    move.b #1,d0
    move.b d0,C6
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of nightone client.
