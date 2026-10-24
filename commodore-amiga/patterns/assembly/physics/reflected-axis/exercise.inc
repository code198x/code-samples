exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #18,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #6,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr reflected_axis_init
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
    bsr reflected_axis_init
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
    bsr reflected_axis_step
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
; POSITION = 2
    move.b #2,d0
    move.b d0,POSITION
; MINIMUM = 0
    move.b #0,d0
    move.b d0,MINIMUM
; MAXIMUM = 3
    move.b #3,d0
    move.b d0,MAXIMUM
; DISTANCE = 7
    move.b #7,d0
    move.b d0,DISTANCE
; DIRECTION = 1
    move.b #1,d0
    move.b d0,DIRECTION
    ifne BROKEN
; DISTANCE = 1
    move.b #1,d0
    move.b d0,DISTANCE
    endif
    bsr checked_step
    bsr emit_state
; DISTANCE = 14
    move.b #14,d0
    move.b d0,DISTANCE
    ifne BROKEN
; DISTANCE = 1
    move.b #1,d0
    move.b d0,DISTANCE
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; POSITION = 8
    move.b #8,d0
    move.b d0,POSITION
; MINIMUM = 0
    move.b #0,d0
    move.b d0,MINIMUM
; MAXIMUM = 10
    move.b #10,d0
    move.b d0,MAXIMUM
; DISTANCE = 7
    move.b #7,d0
    move.b d0,DISTANCE
; DIRECTION = 1
    move.b #1,d0
    move.b d0,DIRECTION
    ifne BROKEN
; DISTANCE = 1
    move.b #1,d0
    move.b d0,DISTANCE
    endif
    bsr checked_step
    bsr emit_state
; DISTANCE = 14
    move.b #14,d0
    move.b d0,DISTANCE
    ifne BROKEN
; DISTANCE = 1
    move.b #1,d0
    move.b d0,DISTANCE
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of gamekit client.
