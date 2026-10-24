exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #5,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #5,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr bitset_slot_allocation_init
    bsr emit_state
    lea case_table,a3
    moveq #63,d6
case_loop:
    lea STATE,a0
    moveq #5,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr bitset_slot_allocation_init
    bsr preview_rules
    lea preview,a0
    moveq #7,d0
preview_clear:
    clr.b (a0)+
    dbra d0,preview_clear
    lea STATE,a0
    lea preview,a1
    moveq #5,d0
preview_copy:
    move.b (a0)+,(a1)+
    dbra d0,preview_copy
    move.b #239,(a4)+
    rts
checked_step:
    move.l #$52a39374,d4
    movea.l #$12345,a2
    bsr bitset_slot_allocation_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #5,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: retain private state between service calls.
preview_rules:
    ifne CUSTOM
; USED = 254
    move.b #254,d0
    move.b d0,USED
    ifne BROKEN
; USED = 0
    move.b #0,d0
    move.b d0,USED
    endif
    bsr checked_step
    bsr emit_state

    ifne BROKEN
; USED = 0
    move.b #0,d0
    move.b d0,USED
    endif
    bsr checked_step
    bsr emit_state
; MODE = 1
    move.b #1,d0
    move.b d0,MODE
; REQUEST = 7
    move.b #7,d0
    move.b d0,REQUEST
    ifne BROKEN
; USED = 0
    move.b #0,d0
    move.b d0,USED
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; USED = 3
    move.b #3,d0
    move.b d0,USED
    ifne BROKEN
; USED = 0
    move.b #0,d0
    move.b d0,USED
    endif
    bsr checked_step
    bsr emit_state

    ifne BROKEN
; USED = 0
    move.b #0,d0
    move.b d0,USED
    endif
    bsr checked_step
    bsr emit_state
; MODE = 1
    move.b #1,d0
    move.b d0,MODE
; REQUEST = 1
    move.b #1,d0
    move.b d0,REQUEST
    ifne BROKEN
; USED = 0
    move.b #0,d0
    move.b d0,USED
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of toolkit client.
