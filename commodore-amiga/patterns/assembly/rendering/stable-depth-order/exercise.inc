exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #14,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #17,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr stable_depth_order_init
    bsr emit_state
    lea case_table,a3
    moveq #54,d6
case_loop:
    lea STATE,a0
    moveq #17,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr stable_depth_order_init
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
    bsr stable_depth_order_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #17,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: retain private state between service calls.
preview_rules:
    ifne CUSTOM
; COUNT = 5
    move.b #5,d0
    move.b d0,COUNT
; Z0 = 1
    move.b #1,d0
    move.b d0,Z0
; Z1 = 8
    move.b #8,d0
    move.b d0,Z1
; Z2 = 1
    move.b #1,d0
    move.b d0,Z2
; Z3 = 8
    move.b #8,d0
    move.b d0,Z3
; Z4 = 2
    move.b #2,d0
    move.b d0,Z4
    ifne BROKEN
; COUNT = 0
    move.b #0,d0
    move.b d0,COUNT
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; COUNT = 5
    move.b #5,d0
    move.b d0,COUNT
; Z0 = 8
    move.b #8,d0
    move.b d0,Z0
; Z1 = 2
    move.b #2,d0
    move.b d0,Z1
; Z2 = 8
    move.b #8,d0
    move.b d0,Z2
; Z3 = 1
    move.b #1,d0
    move.b d0,Z3
; Z4 = 2
    move.b #2,d0
    move.b d0,Z4
    ifne BROKEN
; COUNT = 0
    move.b #0,d0
    move.b d0,COUNT
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of gamekit client.
