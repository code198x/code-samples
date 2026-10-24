exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #4,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #9,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr interaction_focus_init
    bsr emit_state
    lea case_table,a3
    moveq #63,d6
case_loop:
    lea STATE,a0
    moveq #9,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr interaction_focus_init
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
    bsr interaction_focus_step
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
; Sequential client: retain private state between service calls.
preview_rules:
    ifne CUSTOM
; CURRENT = 3
    move.b #3,d0
    move.b d0,CURRENT
; ACTIVE = 15
    move.b #15,d0
    move.b d0,ACTIVE
; RANGE = 10
    move.b #10,d0
    move.b d0,RANGE
; MARGIN = 0
    move.b #0,d0
    move.b d0,MARGIN
; DIST0 = 10
    move.b #10,d0
    move.b d0,DIST0
; DIST1 = 10
    move.b #10,d0
    move.b d0,DIST1
; DIST2 = 10
    move.b #10,d0
    move.b d0,DIST2
; DIST3 = 10
    move.b #10,d0
    move.b d0,DIST3
    ifne BROKEN
; CURRENT = 255
    move.b #255,d0
    move.b d0,CURRENT
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; CURRENT = 1
    move.b #1,d0
    move.b d0,CURRENT
; ACTIVE = 3
    move.b #3,d0
    move.b d0,ACTIVE
; RANGE = 20
    move.b #20,d0
    move.b d0,RANGE
; MARGIN = 2
    move.b #2,d0
    move.b d0,MARGIN
; DIST0 = 9
    move.b #9,d0
    move.b d0,DIST0
; DIST1 = 10
    move.b #10,d0
    move.b d0,DIST1
    ifne BROKEN
; CURRENT = 255
    move.b #255,d0
    move.b d0,CURRENT
    endif
    bsr checked_step
    bsr emit_state
; CURRENT = 1
    move.b #1,d0
    move.b d0,CURRENT
; DIST0 = 8
    move.b #8,d0
    move.b d0,DIST0
    ifne BROKEN
; CURRENT = 255
    move.b #255,d0
    move.b d0,CURRENT
    endif
    bsr checked_step
    bsr emit_state
; CURRENT = 1
    move.b #1,d0
    move.b d0,CURRENT
; DIST0 = 8
    move.b #8,d0
    move.b d0,DIST0
    ifne BROKEN
; CURRENT = 255
    move.b #255,d0
    move.b d0,CURRENT
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of nighttwo client.
