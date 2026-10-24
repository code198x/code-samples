exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #7,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #10,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr moving_solid_push_init
    bsr emit_state
    lea case_table,a3
    moveq #63,d6
case_loop:
    lea STATE,a0
    moveq #10,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr moving_solid_push_init
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
    bsr moving_solid_push_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #10,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: retain private state between service calls.
preview_rules:
    ifne CUSTOM
; ACTOR_POSITION = 5
    move.b #5,d0
    move.b d0,ACTOR_POSITION
; ACTOR_SIZE = 2
    move.b #2,d0
    move.b d0,ACTOR_SIZE
; SOLID_OLD = 10
    move.b #10,d0
    move.b d0,SOLID_OLD
; SOLID_NEW = 0
    move.b #0,d0
    move.b d0,SOLID_NEW
; SOLID_SIZE = 2
    move.b #2,d0
    move.b d0,SOLID_SIZE
; MINIMUM = 0
    move.b #0,d0
    move.b d0,MINIMUM
; MAXIMUM = 30
    move.b #30,d0
    move.b d0,MAXIMUM
    ifne BROKEN
; SOLID_OLD = SOLID_NEW
    move.b SOLID_NEW,d0
    move.b d0,SOLID_OLD
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; ACTOR_POSITION = 10
    move.b #10,d0
    move.b d0,ACTOR_POSITION
; ACTOR_SIZE = 2
    move.b #2,d0
    move.b d0,ACTOR_SIZE
; SOLID_OLD = 0
    move.b #0,d0
    move.b d0,SOLID_OLD
; SOLID_NEW = 12
    move.b #12,d0
    move.b d0,SOLID_NEW
; SOLID_SIZE = 2
    move.b #2,d0
    move.b d0,SOLID_SIZE
; MINIMUM = 0
    move.b #0,d0
    move.b d0,MINIMUM
; MAXIMUM = 30
    move.b #30,d0
    move.b d0,MAXIMUM
    ifne BROKEN
; SOLID_OLD = SOLID_NEW
    move.b SOLID_NEW,d0
    move.b d0,SOLID_OLD
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of nightone client.
