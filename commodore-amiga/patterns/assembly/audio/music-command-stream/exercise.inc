exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #7,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #22,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr music_command_stream_init
    bsr emit_state
    lea case_table,a3
    moveq #42,d6
case_loop:
    lea STATE,a0
    moveq #22,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr music_command_stream_init
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
    bsr music_command_stream_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #22,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: retain private state between service calls.
preview_rules:
    ifne CUSTOM
; COUNT = 2
    move.b #2,d0
    move.b d0,COUNT
; N0 = 72
    move.b #72,d0
    move.b d0,N0
; U0 = 1
    move.b #1,d0
    move.b d0,U0
; N1 = 255
    move.b #255,d0
    move.b d0,N1
; U1 = 0
    move.b #0,d0
    move.b d0,U1
    ifne BROKEN
; REMAINING = 0
    move.b #0,d0
    move.b d0,REMAINING
    endif
    bsr checked_step
    bsr emit_state

    ifne BROKEN
; REMAINING = 0
    move.b #0,d0
    move.b d0,REMAINING
    endif
    bsr checked_step
    bsr emit_state

    ifne BROKEN
; REMAINING = 0
    move.b #0,d0
    move.b d0,REMAINING
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; COUNT = 3
    move.b #3,d0
    move.b d0,COUNT
; N0 = 40
    move.b #40,d0
    move.b d0,N0
; U0 = 2
    move.b #2,d0
    move.b d0,U0
; N1 = 0
    move.b #0,d0
    move.b d0,N1
; U1 = 1
    move.b #1,d0
    move.b d0,U1
; N2 = 44
    move.b #44,d0
    move.b d0,N2
; U2 = 1
    move.b #1,d0
    move.b d0,U2
    ifne BROKEN
; REMAINING = 0
    move.b #0,d0
    move.b d0,REMAINING
    endif
    bsr checked_step
    bsr emit_state

    ifne BROKEN
; REMAINING = 0
    move.b #0,d0
    move.b d0,REMAINING
    endif
    bsr checked_step
    bsr emit_state

    ifne BROKEN
; REMAINING = 0
    move.b #0,d0
    move.b d0,REMAINING
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of nighttwo client.
