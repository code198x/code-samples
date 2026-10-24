exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #11,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #7,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr swept_axis_collision_init
    bsr emit_state
    lea case_table,a3
    moveq #63,d6
case_loop:
    lea STATE,a0
    moveq #7,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr swept_axis_collision_init
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
    bsr swept_axis_collision_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #7,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: retain private state between service calls.
preview_rules:
    ifne CUSTOM
; OLD_POSITION = 20
    move.b #20,d0
    move.b d0,OLD_POSITION
; TARGET = 2
    move.b #2,d0
    move.b d0,TARGET
; SIZE = 2
    move.b #2,d0
    move.b d0,SIZE
; WALL_START = 10
    move.b #10,d0
    move.b d0,WALL_START
; WALL_END = 12
    move.b #12,d0
    move.b d0,WALL_END
    ifne BROKEN
; TARGET = OLD_POSITION
    move.b OLD_POSITION,d0
    move.b d0,TARGET
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; OLD_POSITION = 2
    move.b #2,d0
    move.b d0,OLD_POSITION
; TARGET = 20
    move.b #20,d0
    move.b d0,TARGET
; SIZE = 3
    move.b #3,d0
    move.b d0,SIZE
; WALL_START = 10
    move.b #10,d0
    move.b d0,WALL_START
; WALL_END = 12
    move.b #12,d0
    move.b d0,WALL_END
    ifne BROKEN
; TARGET = OLD_POSITION
    move.b OLD_POSITION,d0
    move.b d0,TARGET
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of toolkit client.
