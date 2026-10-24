exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #16,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #7,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr bounded_bit_reader_init
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
    bsr bounded_bit_reader_init
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
    bsr bounded_bit_reader_step
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
; B0 = 171
    move.b #171,d0
    move.b d0,B0
; B1 = 192
    move.b #192,d0
    move.b d0,B1
; COUNT = 8
    move.b #8,d0
    move.b d0,COUNT
    ifne BROKEN
; CURSOR = 0
    move.b #0,d0
    move.b d0,CURSOR
    endif
    bsr checked_step
    bsr emit_state

    ifne BROKEN
; CURSOR = 0
    move.b #0,d0
    move.b d0,CURSOR
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; B0 = 171
    move.b #171,d0
    move.b d0,B0
; B1 = 192
    move.b #192,d0
    move.b d0,B1
; COUNT = 4
    move.b #4,d0
    move.b d0,COUNT
    ifne BROKEN
; CURSOR = 0
    move.b #0,d0
    move.b d0,CURSOR
    endif
    bsr checked_step
    bsr emit_state

    ifne BROKEN
; CURSOR = 0
    move.b #0,d0
    move.b d0,CURSOR
    endif
    bsr checked_step
    bsr emit_state

    ifne BROKEN
; CURSOR = 0
    move.b #0,d0
    move.b d0,CURSOR
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of worldkit client.
