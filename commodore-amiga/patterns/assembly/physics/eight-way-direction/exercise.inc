exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #13,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #6,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr eight_way_direction_init
    bsr emit_state
    lea case_table,a3
    moveq #63,d6
case_loop:
    lea STATE,a0
    moveq #6,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr eight_way_direction_init
    bsr preview_rules
    lea preview,a0
    moveq #7,d0
preview_clear:
    clr.b (a0)+
    dbra d0,preview_clear
    lea STATE,a0
    lea preview,a1
    moveq #6,d0
preview_copy:
    move.b (a0)+,(a1)+
    dbra d0,preview_copy
    move.b #239,(a4)+
    rts
checked_step:
    move.l #$52a39374,d4
    movea.l #$12345,a2
    bsr eight_way_direction_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #6,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: retain private state between service calls.
preview_rules:
    ifne CUSTOM
; FROM_X = 100
    move.b #100,d0
    move.b d0,FROM_X
; FROM_Y = 100
    move.b #100,d0
    move.b d0,FROM_Y
; TO_X = 90
    move.b #90,d0
    move.b d0,TO_X
; TO_Y = 90
    move.b #90,d0
    move.b d0,TO_Y
    ifne BROKEN
; TO_Y = FROM_Y
    move.b FROM_Y,d0
    move.b d0,TO_Y
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; TO_X = 10
    move.b #10,d0
    move.b d0,TO_X
; TO_Y = 3
    move.b #3,d0
    move.b d0,TO_Y
    ifne BROKEN
; TO_Y = FROM_Y
    move.b FROM_Y,d0
    move.b d0,TO_Y
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of toolkit client.
