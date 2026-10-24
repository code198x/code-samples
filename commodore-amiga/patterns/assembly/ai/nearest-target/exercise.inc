exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #12,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #14,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr nearest_target_init
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
    bsr nearest_target_init
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
    bsr nearest_target_step
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
; ACTIVE = 9
    move.b #9,d0
    move.b d0,ACTIVE
; ORIGIN_X = 255
    move.b #255,d0
    move.b d0,ORIGIN_X
; ORIGIN_Y = 255
    move.b #255,d0
    move.b d0,ORIGIN_Y
; PX0 = 0
    move.b #0,d0
    move.b d0,PX0
; PY0 = 0
    move.b #0,d0
    move.b d0,PY0
; PX3 = 254
    move.b #254,d0
    move.b d0,PX3
; PY3 = 255
    move.b #255,d0
    move.b d0,PY3
    ifne BROKEN
; ACTIVE = 1
    move.b #1,d0
    move.b d0,ACTIVE
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; ACTIVE = 3
    move.b #3,d0
    move.b d0,ACTIVE
; PX0 = 100
    move.b #100,d0
    move.b d0,PX0
; PY0 = 100
    move.b #100,d0
    move.b d0,PY0
; PX1 = 2
    move.b #2,d0
    move.b d0,PX1
; PY1 = 3
    move.b #3,d0
    move.b d0,PY1
    ifne BROKEN
; ACTIVE = 1
    move.b #1,d0
    move.b d0,ACTIVE
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of toolkit client.
