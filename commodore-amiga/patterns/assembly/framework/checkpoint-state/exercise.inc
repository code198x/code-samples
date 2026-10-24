exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #9,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #9,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr checkpoint_state_init
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
    bsr checkpoint_state_init
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
    bsr checkpoint_state_step
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
; LIVE_X = 250
    move.b #250,d0
    move.b d0,LIVE_X
; LIVE_Y = 1
    move.b #1,d0
    move.b d0,LIVE_Y
; LIVE_RESOURCE = 255
    move.b #255,d0
    move.b d0,LIVE_RESOURCE
    ifne BROKEN
; SAVED_RESOURCE = 0
    move.b #0,d0
    move.b d0,SAVED_RESOURCE
    endif
    bsr checked_step
    bsr emit_state
; LIVE_X = 0
    move.b #0,d0
    move.b d0,LIVE_X
; MODE = 1
    move.b #1,d0
    move.b d0,MODE
    ifne BROKEN
; SAVED_RESOURCE = 0
    move.b #0,d0
    move.b d0,SAVED_RESOURCE
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; LIVE_X = 20
    move.b #20,d0
    move.b d0,LIVE_X
; LIVE_Y = 30
    move.b #30,d0
    move.b d0,LIVE_Y
; LIVE_RESOURCE = 4
    move.b #4,d0
    move.b d0,LIVE_RESOURCE
    ifne BROKEN
; SAVED_RESOURCE = 0
    move.b #0,d0
    move.b d0,SAVED_RESOURCE
    endif
    bsr checked_step
    bsr emit_state
; LIVE_X = 99
    move.b #99,d0
    move.b d0,LIVE_X
; LIVE_Y = 88
    move.b #88,d0
    move.b d0,LIVE_Y
; LIVE_RESOURCE = 0
    move.b #0,d0
    move.b d0,LIVE_RESOURCE
; MODE = 1
    move.b #1,d0
    move.b d0,MODE
    ifne BROKEN
; SAVED_RESOURCE = 0
    move.b #0,d0
    move.b d0,SAVED_RESOURCE
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of worldkit client.
