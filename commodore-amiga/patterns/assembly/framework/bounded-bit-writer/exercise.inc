exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #4,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #7,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr bounded_bit_writer_init
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
    bsr bounded_bit_writer_init
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
    bsr bounded_bit_writer_step
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
; COUNT = 8
    move.b #8,d0
    move.b d0,COUNT
; VALUE = 165
    move.b #165,d0
    move.b d0,VALUE
; CURSOR = 24
    move.b #24,d0
    move.b d0,CURSOR
    ifne BROKEN
; CURSOR = 0
    move.b #0,d0
    move.b d0,CURSOR
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; COUNT = 5
    move.b #5,d0
    move.b d0,COUNT
; VALUE = 21
    move.b #21,d0
    move.b d0,VALUE
; CURSOR = 6
    move.b #6,d0
    move.b d0,CURSOR
; B0 = 255
    move.b #255,d0
    move.b d0,B0
; B1 = 255
    move.b #255,d0
    move.b d0,B1
    ifne BROKEN
; CURSOR = 0
    move.b #0,d0
    move.b d0,CURSOR
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of toolkit client.
