exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #5,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #8,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr moving_platform_carry_init
    bsr emit_state
    lea case_table,a3
    moveq #63,d6
case_loop:
    lea STATE,a0
    moveq #8,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr moving_platform_carry_init
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
    bsr moving_platform_carry_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #8,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: retain private state between service calls.
preview_rules:
    ifne CUSTOM
; PASSENGER = 2
    move.b #2,d0
    move.b d0,PASSENGER
; PLATFORM_OLD = 10
    move.b #10,d0
    move.b d0,PLATFORM_OLD
; PLATFORM_NEW = 0
    move.b #0,d0
    move.b d0,PLATFORM_NEW
; SUPPORTED = 1
    move.b #1,d0
    move.b d0,SUPPORTED
; MINIMUM = 0
    move.b #0,d0
    move.b d0,MINIMUM
; MAXIMUM = 100
    move.b #100,d0
    move.b d0,MAXIMUM
    ifne BROKEN
; PLATFORM_OLD = PLATFORM_NEW
    move.b PLATFORM_NEW,d0
    move.b d0,PLATFORM_OLD
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; PASSENGER = 20
    move.b #20,d0
    move.b d0,PASSENGER
; PLATFORM_OLD = 5
    move.b #5,d0
    move.b d0,PLATFORM_OLD
; PLATFORM_NEW = 9
    move.b #9,d0
    move.b d0,PLATFORM_NEW
; SUPPORTED = 1
    move.b #1,d0
    move.b d0,SUPPORTED
; MINIMUM = 0
    move.b #0,d0
    move.b d0,MINIMUM
; MAXIMUM = 100
    move.b #100,d0
    move.b d0,MAXIMUM
    ifne BROKEN
; PLATFORM_OLD = PLATFORM_NEW
    move.b PLATFORM_NEW,d0
    move.b d0,PLATFORM_OLD
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of nightone client.
