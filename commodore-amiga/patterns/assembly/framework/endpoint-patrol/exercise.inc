exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #6,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #3,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr endpoint_patrol_init
    bsr emit_state
    lea case_table,a3
    moveq #95,d6
case_loop:
    lea STATE,a0
    moveq #3,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr endpoint_patrol_init
    bsr preview_rules
    lea preview,a0
    moveq #7,d0
preview_clear:
    clr.b (a0)+
    dbra d0,preview_clear
    lea STATE,a0
    lea preview,a1
    moveq #3,d0
preview_copy:
    move.b (a0)+,(a1)+
    dbra d0,preview_copy
    move.b #239,(a4)+
    rts
checked_step:
    move.l #$52a39374,d4
    movea.l #$12345,a2
    bsr endpoint_patrol_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #3,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: initialise once, then retain state between calls.
preview_rules:
    ifne CUSTOM
    move.b #4,POSITION
    move.b #0,LOWER
    move.b #6,UPPER
    move.b #0,DIRECTION
    ifne BROKEN
    tst.b DIRECTION
    beq.s bad_patrol_up_0_custom
    subq.b #1,POSITION
    bra.s bad_patrol_check_0_custom
bad_patrol_up_0_custom:
    addq.b #1,POSITION
bad_patrol_check_0_custom:
    move.b POSITION,d0
    cmp.b LOWER,d0
    blo.s bad_patrol_flip_0_custom
    cmp.b UPPER,d0
    bls.s bad_patrol_end_0_custom
bad_patrol_flip_0_custom:
    eori.b #1,DIRECTION
bad_patrol_end_0_custom:
    else
    bsr checked_step
    endif
    bsr emit_state
    ifne BROKEN
    tst.b DIRECTION
    beq.s bad_patrol_up_1_custom
    subq.b #1,POSITION
    bra.s bad_patrol_check_1_custom
bad_patrol_up_1_custom:
    addq.b #1,POSITION
bad_patrol_check_1_custom:
    move.b POSITION,d0
    cmp.b LOWER,d0
    blo.s bad_patrol_flip_1_custom
    cmp.b UPPER,d0
    bls.s bad_patrol_end_1_custom
bad_patrol_flip_1_custom:
    eori.b #1,DIRECTION
bad_patrol_end_1_custom:
    else
    bsr checked_step
    endif
    bsr emit_state
    ifne BROKEN
    tst.b DIRECTION
    beq.s bad_patrol_up_2_custom
    subq.b #1,POSITION
    bra.s bad_patrol_check_2_custom
bad_patrol_up_2_custom:
    addq.b #1,POSITION
bad_patrol_check_2_custom:
    move.b POSITION,d0
    cmp.b LOWER,d0
    blo.s bad_patrol_flip_2_custom
    cmp.b UPPER,d0
    bls.s bad_patrol_end_2_custom
bad_patrol_flip_2_custom:
    eori.b #1,DIRECTION
bad_patrol_end_2_custom:
    else
    bsr checked_step
    endif
    bsr emit_state
    ifne BROKEN
    tst.b DIRECTION
    beq.s bad_patrol_up_3_custom
    subq.b #1,POSITION
    bra.s bad_patrol_check_3_custom
bad_patrol_up_3_custom:
    addq.b #1,POSITION
bad_patrol_check_3_custom:
    move.b POSITION,d0
    cmp.b LOWER,d0
    blo.s bad_patrol_flip_3_custom
    cmp.b UPPER,d0
    bls.s bad_patrol_end_3_custom
bad_patrol_flip_3_custom:
    eori.b #1,DIRECTION
bad_patrol_end_3_custom:
    else
    bsr checked_step
    endif
    bsr emit_state
    ifne BROKEN
    tst.b DIRECTION
    beq.s bad_patrol_up_4_custom
    subq.b #1,POSITION
    bra.s bad_patrol_check_4_custom
bad_patrol_up_4_custom:
    addq.b #1,POSITION
bad_patrol_check_4_custom:
    move.b POSITION,d0
    cmp.b LOWER,d0
    blo.s bad_patrol_flip_4_custom
    cmp.b UPPER,d0
    bls.s bad_patrol_end_4_custom
bad_patrol_flip_4_custom:
    eori.b #1,DIRECTION
bad_patrol_end_4_custom:
    else
    bsr checked_step
    endif
    bsr emit_state
    ifne BROKEN
    tst.b DIRECTION
    beq.s bad_patrol_up_5_custom
    subq.b #1,POSITION
    bra.s bad_patrol_check_5_custom
bad_patrol_up_5_custom:
    addq.b #1,POSITION
bad_patrol_check_5_custom:
    move.b POSITION,d0
    cmp.b LOWER,d0
    blo.s bad_patrol_flip_5_custom
    cmp.b UPPER,d0
    bls.s bad_patrol_end_5_custom
bad_patrol_flip_5_custom:
    eori.b #1,DIRECTION
bad_patrol_end_5_custom:
    else
    bsr checked_step
    endif
    bsr emit_state
    else
    move.b #4,POSITION
    move.b #0,LOWER
    move.b #4,UPPER
    move.b #0,DIRECTION
    ifne BROKEN
    tst.b DIRECTION
    beq.s bad_patrol_up_0
    subq.b #1,POSITION
    bra.s bad_patrol_check_0
bad_patrol_up_0:
    addq.b #1,POSITION
bad_patrol_check_0:
    move.b POSITION,d0
    cmp.b LOWER,d0
    blo.s bad_patrol_flip_0
    cmp.b UPPER,d0
    bls.s bad_patrol_end_0
bad_patrol_flip_0:
    eori.b #1,DIRECTION
bad_patrol_end_0:
    else
    bsr checked_step
    endif
    bsr emit_state
    ifne BROKEN
    tst.b DIRECTION
    beq.s bad_patrol_up_1
    subq.b #1,POSITION
    bra.s bad_patrol_check_1
bad_patrol_up_1:
    addq.b #1,POSITION
bad_patrol_check_1:
    move.b POSITION,d0
    cmp.b LOWER,d0
    blo.s bad_patrol_flip_1
    cmp.b UPPER,d0
    bls.s bad_patrol_end_1
bad_patrol_flip_1:
    eori.b #1,DIRECTION
bad_patrol_end_1:
    else
    bsr checked_step
    endif
    bsr emit_state
    ifne BROKEN
    tst.b DIRECTION
    beq.s bad_patrol_up_2
    subq.b #1,POSITION
    bra.s bad_patrol_check_2
bad_patrol_up_2:
    addq.b #1,POSITION
bad_patrol_check_2:
    move.b POSITION,d0
    cmp.b LOWER,d0
    blo.s bad_patrol_flip_2
    cmp.b UPPER,d0
    bls.s bad_patrol_end_2
bad_patrol_flip_2:
    eori.b #1,DIRECTION
bad_patrol_end_2:
    else
    bsr checked_step
    endif
    bsr emit_state
    ifne BROKEN
    tst.b DIRECTION
    beq.s bad_patrol_up_3
    subq.b #1,POSITION
    bra.s bad_patrol_check_3
bad_patrol_up_3:
    addq.b #1,POSITION
bad_patrol_check_3:
    move.b POSITION,d0
    cmp.b LOWER,d0
    blo.s bad_patrol_flip_3
    cmp.b UPPER,d0
    bls.s bad_patrol_end_3
bad_patrol_flip_3:
    eori.b #1,DIRECTION
bad_patrol_end_3:
    else
    bsr checked_step
    endif
    bsr emit_state
    ifne BROKEN
    tst.b DIRECTION
    beq.s bad_patrol_up_4
    subq.b #1,POSITION
    bra.s bad_patrol_check_4
bad_patrol_up_4:
    addq.b #1,POSITION
bad_patrol_check_4:
    move.b POSITION,d0
    cmp.b LOWER,d0
    blo.s bad_patrol_flip_4
    cmp.b UPPER,d0
    bls.s bad_patrol_end_4
bad_patrol_flip_4:
    eori.b #1,DIRECTION
bad_patrol_end_4:
    else
    bsr checked_step
    endif
    bsr emit_state
    ifne BROKEN
    tst.b DIRECTION
    beq.s bad_patrol_up_5
    subq.b #1,POSITION
    bra.s bad_patrol_check_5
bad_patrol_up_5:
    addq.b #1,POSITION
bad_patrol_check_5:
    move.b POSITION,d0
    cmp.b LOWER,d0
    blo.s bad_patrol_flip_5
    cmp.b UPPER,d0
    bls.s bad_patrol_end_5
bad_patrol_flip_5:
    eori.b #1,DIRECTION
bad_patrol_end_5:
    else
    bsr checked_step
    endif
    bsr emit_state
    endif
    rts
; End of gameplay client.
