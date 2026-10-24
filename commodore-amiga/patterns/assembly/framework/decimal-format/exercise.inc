exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #9,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #8,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr decimal_format_init
    bsr emit_state
    lea case_table,a3
    moveq #95,d6
case_loop:
    lea STATE,a0
    moveq #8,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr decimal_format_init
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
    bsr decimal_format_step
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
; Sequential client: initialise once, then retain state between calls.
preview_rules:
    ifne CUSTOM
    move.b #0,VALUE_LO
    move.b #16,VALUE_HI
    ifne BROKEN
    move.b #0,VALUE_HI
    bsr checked_step
    else
    bsr checked_step
    endif
    bsr emit_state
    else
    move.b #255,VALUE_LO
    move.b #255,VALUE_HI
    ifne BROKEN
    move.b #0,VALUE_HI
    bsr checked_step
    else
    bsr checked_step
    endif
    bsr emit_state
    endif
    rts
; End of gameplay client.
