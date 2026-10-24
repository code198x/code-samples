exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #3,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #9,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr one_way_platform_init
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
    bsr one_way_platform_init
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
    bsr one_way_platform_step
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
    move.b #20,ACTOR_X
    move.b #16,ACTOR_W
    move.b #90,PREV_BOTTOM
    move.b #110,NEW_BOTTOM
    move.b #10,PLATFORM_X
    move.b #64,PLATFORM_W
    move.b #100,PLATFORM_Y
    move.b #1,DROP
    ifne BROKEN
    bsr checked_step
    move.b NEW_BOTTOM,d0
    cmp.b PLATFORM_Y,d0
    beq.s bad_platform_done_0_custom
    move.b d0,SNAP
    clr.b LANDED
bad_platform_done_0_custom:
    else
    bsr checked_step
    endif
    bsr emit_state
    else
    move.b #20,ACTOR_X
    move.b #16,ACTOR_W
    move.b #90,PREV_BOTTOM
    move.b #110,NEW_BOTTOM
    move.b #10,PLATFORM_X
    move.b #64,PLATFORM_W
    move.b #100,PLATFORM_Y
    move.b #0,DROP
    ifne BROKEN
    bsr checked_step
    move.b NEW_BOTTOM,d0
    cmp.b PLATFORM_Y,d0
    beq.s bad_platform_done_0
    move.b d0,SNAP
    clr.b LANDED
bad_platform_done_0:
    else
    bsr checked_step
    endif
    bsr emit_state
    endif
    rts
; End of playtools client.
