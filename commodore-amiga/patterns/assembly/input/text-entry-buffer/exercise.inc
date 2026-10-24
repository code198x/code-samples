exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #6,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #11,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr text_entry_buffer_init
    bsr emit_state
    lea case_table,a3
    moveq #63,d6
case_loop:
    lea STATE,a0
    moveq #11,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr text_entry_buffer_init
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
    bsr text_entry_buffer_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #11,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: retain private state between service calls.
preview_rules:
    ifne CUSTOM
    move.b #0,MODE
    move.b #65,KEY
    ifne BROKEN
    cmp.b #1,MODE
    bne.s bad_text_regular_0_custom
    tst.b LENGTH
    bne.s bad_text_regular_0_custom
    subq.b #1,LENGTH
    move.b #1,STATUS
    bra.s bad_text_done_0_custom
bad_text_regular_0_custom:
    bsr checked_step
bad_text_done_0_custom:
    else
    bsr checked_step
    endif
    bsr emit_state
    move.b #66,KEY
    ifne BROKEN
    cmp.b #1,MODE
    bne.s bad_text_regular_1_custom
    tst.b LENGTH
    bne.s bad_text_regular_1_custom
    subq.b #1,LENGTH
    move.b #1,STATUS
    bra.s bad_text_done_1_custom
bad_text_regular_1_custom:
    bsr checked_step
bad_text_done_1_custom:
    else
    bsr checked_step
    endif
    bsr emit_state
    move.b #1,MODE
    ifne BROKEN
    cmp.b #1,MODE
    bne.s bad_text_regular_2_custom
    tst.b LENGTH
    bne.s bad_text_regular_2_custom
    subq.b #1,LENGTH
    move.b #1,STATUS
    bra.s bad_text_done_2_custom
bad_text_regular_2_custom:
    bsr checked_step
bad_text_done_2_custom:
    else
    bsr checked_step
    endif
    bsr emit_state
    ifne BROKEN
    cmp.b #1,MODE
    bne.s bad_text_regular_3_custom
    tst.b LENGTH
    bne.s bad_text_regular_3_custom
    subq.b #1,LENGTH
    move.b #1,STATUS
    bra.s bad_text_done_3_custom
bad_text_regular_3_custom:
    bsr checked_step
bad_text_done_3_custom:
    else
    bsr checked_step
    endif
    bsr emit_state
    ifne BROKEN
    cmp.b #1,MODE
    bne.s bad_text_regular_4_custom
    tst.b LENGTH
    bne.s bad_text_regular_4_custom
    subq.b #1,LENGTH
    move.b #1,STATUS
    bra.s bad_text_done_4_custom
bad_text_regular_4_custom:
    bsr checked_step
bad_text_done_4_custom:
    else
    bsr checked_step
    endif
    bsr emit_state
    move.b #0,MODE
    move.b #67,KEY
    ifne BROKEN
    cmp.b #1,MODE
    bne.s bad_text_regular_5_custom
    tst.b LENGTH
    bne.s bad_text_regular_5_custom
    subq.b #1,LENGTH
    move.b #1,STATUS
    bra.s bad_text_done_5_custom
bad_text_regular_5_custom:
    bsr checked_step
bad_text_done_5_custom:
    else
    bsr checked_step
    endif
    bsr emit_state
    else
    move.b #0,MODE
    move.b #65,KEY
    ifne BROKEN
    cmp.b #1,MODE
    bne.s bad_text_regular_0
    tst.b LENGTH
    bne.s bad_text_regular_0
    subq.b #1,LENGTH
    move.b #1,STATUS
    bra.s bad_text_done_0
bad_text_regular_0:
    bsr checked_step
bad_text_done_0:
    else
    bsr checked_step
    endif
    bsr emit_state
    move.b #66,KEY
    ifne BROKEN
    cmp.b #1,MODE
    bne.s bad_text_regular_1
    tst.b LENGTH
    bne.s bad_text_regular_1
    subq.b #1,LENGTH
    move.b #1,STATUS
    bra.s bad_text_done_1
bad_text_regular_1:
    bsr checked_step
bad_text_done_1:
    else
    bsr checked_step
    endif
    bsr emit_state
    move.b #1,MODE
    ifne BROKEN
    cmp.b #1,MODE
    bne.s bad_text_regular_2
    tst.b LENGTH
    bne.s bad_text_regular_2
    subq.b #1,LENGTH
    move.b #1,STATUS
    bra.s bad_text_done_2
bad_text_regular_2:
    bsr checked_step
bad_text_done_2:
    else
    bsr checked_step
    endif
    bsr emit_state
    ifne BROKEN
    cmp.b #1,MODE
    bne.s bad_text_regular_3
    tst.b LENGTH
    bne.s bad_text_regular_3
    subq.b #1,LENGTH
    move.b #1,STATUS
    bra.s bad_text_done_3
bad_text_regular_3:
    bsr checked_step
bad_text_done_3:
    else
    bsr checked_step
    endif
    bsr emit_state
    ifne BROKEN
    cmp.b #1,MODE
    bne.s bad_text_regular_4
    tst.b LENGTH
    bne.s bad_text_regular_4
    subq.b #1,LENGTH
    move.b #1,STATUS
    bra.s bad_text_done_4
bad_text_regular_4:
    bsr checked_step
bad_text_done_4:
    else
    bsr checked_step
    endif
    bsr emit_state
    endif
    rts
; End of playtools client.
