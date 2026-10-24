exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #15,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #15,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr bitmap_transpose_init
    bsr emit_state
    lea case_table,a3
    moveq #61,d6
case_loop:
    lea STATE,a0
    moveq #15,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr bitmap_transpose_init
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
    bsr bitmap_transpose_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #15,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: retain private state between service calls.
preview_rules:
    ifne CUSTOM
; C0 = 128
    move.b #128,d0
    move.b d0,C0
; C1 = 64
    move.b #64,d0
    move.b d0,C1
; C2 = 32
    move.b #32,d0
    move.b d0,C2
; C3 = 16
    move.b #16,d0
    move.b d0,C3
; C4 = 8
    move.b #8,d0
    move.b d0,C4
; C5 = 4
    move.b #4,d0
    move.b d0,C5
; C6 = 2
    move.b #2,d0
    move.b d0,C6
; C7 = 1
    move.b #1,d0
    move.b d0,C7
    ifne BROKEN
; C0 = 0
    move.b #0,d0
    move.b d0,C0
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; C0 = 255
    move.b #255,d0
    move.b d0,C0
; C1 = 128
    move.b #128,d0
    move.b d0,C1
; C2 = 128
    move.b #128,d0
    move.b d0,C2
; C3 = 128
    move.b #128,d0
    move.b d0,C3
    ifne BROKEN
; C0 = 0
    move.b #0,d0
    move.b d0,C0
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of toolkit client.
