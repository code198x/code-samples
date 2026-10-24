exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #13,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #2,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr decimal_parser_init
    bsr emit_state
    lea case_table,a3
    moveq #63,d6
case_loop:
    lea STATE,a0
    moveq #2,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr decimal_parser_init
    bsr preview_rules
    lea preview,a0
    moveq #7,d0
preview_clear:
    clr.b (a0)+
    dbra d0,preview_clear
    lea STATE,a0
    lea preview,a1
    moveq #2,d0
preview_copy:
    move.b (a0)+,(a1)+
    dbra d0,preview_copy
    move.b #239,(a4)+
    rts
checked_step:
    move.l #$52a39374,d4
    movea.l #$12345,a2
    bsr decimal_parser_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #2,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: retain private state between service calls.
preview_rules:
    ifne CUSTOM
; CHARACTER = 49
    move.b #49,d0
    move.b d0,CHARACTER
    ifne BROKEN
; VALUE = 0
    move.b #0,d0
    move.b d0,VALUE
    endif
    bsr checked_step
    bsr emit_state
; CHARACTER = 48
    move.b #48,d0
    move.b d0,CHARACTER
    ifne BROKEN
; VALUE = 0
    move.b #0,d0
    move.b d0,VALUE
    endif
    bsr checked_step
    bsr emit_state
; CHARACTER = 52
    move.b #52,d0
    move.b d0,CHARACTER
    ifne BROKEN
; VALUE = 0
    move.b #0,d0
    move.b d0,VALUE
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; CHARACTER = 50
    move.b #50,d0
    move.b d0,CHARACTER
    ifne BROKEN
; VALUE = 0
    move.b #0,d0
    move.b d0,VALUE
    endif
    bsr checked_step
    bsr emit_state
; CHARACTER = 53
    move.b #53,d0
    move.b d0,CHARACTER
    ifne BROKEN
; VALUE = 0
    move.b #0,d0
    move.b d0,VALUE
    endif
    bsr checked_step
    bsr emit_state
; CHARACTER = 54
    move.b #54,d0
    move.b d0,CHARACTER
    ifne BROKEN
; VALUE = 0
    move.b #0,d0
    move.b d0,VALUE
    endif
    bsr checked_step
    bsr emit_state
; CHARACTER = 53
    move.b #53,d0
    move.b d0,CHARACTER
    ifne BROKEN
; VALUE = 0
    move.b #0,d0
    move.b d0,VALUE
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of gamekit client.
