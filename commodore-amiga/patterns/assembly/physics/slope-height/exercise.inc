exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #19,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #12,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr slope_height_init
    bsr emit_state
    lea case_table,a3
    moveq #63,d6
case_loop:
    lea STATE,a0
    moveq #12,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr slope_height_init
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
    bsr slope_height_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #12,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: retain private state between service calls.
preview_rules:
    ifne CUSTOM
; LOCAL_X = 1
    move.b #1,d0
    move.b d0,LOCAL_X
; BASE_Y = 100
    move.b #100,d0
    move.b d0,BASE_Y
; H0 = 7
    move.b #7,d0
    move.b d0,H0
; H1 = 6
    move.b #6,d0
    move.b d0,H1
; H2 = 5
    move.b #5,d0
    move.b d0,H2
; H3 = 4
    move.b #4,d0
    move.b d0,H3
; H4 = 3
    move.b #3,d0
    move.b d0,H4
; H5 = 2
    move.b #2,d0
    move.b d0,H5
; H6 = 1
    move.b #1,d0
    move.b d0,H6
; H7 = 0
    move.b #0,d0
    move.b d0,H7
; MIRROR = 1
    move.b #1,d0
    move.b d0,MIRROR
    ifne BROKEN
; LOCAL_X = 0
    move.b #0,d0
    move.b d0,LOCAL_X
    endif
    bsr checked_step
    bsr emit_state
; LOCAL_X = 6
    move.b #6,d0
    move.b d0,LOCAL_X
    ifne BROKEN
; LOCAL_X = 0
    move.b #0,d0
    move.b d0,LOCAL_X
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; LOCAL_X = 1
    move.b #1,d0
    move.b d0,LOCAL_X
; BASE_Y = 100
    move.b #100,d0
    move.b d0,BASE_Y
; H0 = 7
    move.b #7,d0
    move.b d0,H0
; H1 = 6
    move.b #6,d0
    move.b d0,H1
; H2 = 5
    move.b #5,d0
    move.b d0,H2
; H3 = 4
    move.b #4,d0
    move.b d0,H3
; H4 = 3
    move.b #3,d0
    move.b d0,H4
; H5 = 2
    move.b #2,d0
    move.b d0,H5
; H6 = 1
    move.b #1,d0
    move.b d0,H6
; H7 = 0
    move.b #0,d0
    move.b d0,H7
    ifne BROKEN
; LOCAL_X = 0
    move.b #0,d0
    move.b d0,LOCAL_X
    endif
    bsr checked_step
    bsr emit_state
; LOCAL_X = 6
    move.b #6,d0
    move.b d0,LOCAL_X
    ifne BROKEN
; LOCAL_X = 0
    move.b #0,d0
    move.b d0,LOCAL_X
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of gamekit client.
