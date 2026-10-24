exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #12,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #28,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr bounded_rle_encoder_init
    bsr emit_state
    lea case_table,a3
    moveq #33,d6
case_loop:
    lea STATE,a0
    moveq #28,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr bounded_rle_encoder_init
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
    bsr bounded_rle_encoder_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #28,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: retain private state between service calls.
preview_rules:
    ifne CUSTOM
; INPUT_COUNT = 8
    move.b #8,d0
    move.b d0,INPUT_COUNT
; CAPACITY = 16
    move.b #16,d0
    move.b d0,CAPACITY
; B0 = 0
    move.b #0,d0
    move.b d0,B0
; B1 = 1
    move.b #1,d0
    move.b d0,B1
; B2 = 2
    move.b #2,d0
    move.b d0,B2
; B3 = 3
    move.b #3,d0
    move.b d0,B3
; B4 = 4
    move.b #4,d0
    move.b d0,B4
; B5 = 5
    move.b #5,d0
    move.b d0,B5
; B6 = 6
    move.b #6,d0
    move.b d0,B6
; B7 = 7
    move.b #7,d0
    move.b d0,B7
    ifne BROKEN
; CAPACITY = 0
    move.b #0,d0
    move.b d0,CAPACITY
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; INPUT_COUNT = 6
    move.b #6,d0
    move.b d0,INPUT_COUNT
; CAPACITY = 16
    move.b #16,d0
    move.b d0,CAPACITY
; B0 = 65
    move.b #65,d0
    move.b d0,B0
; B1 = 65
    move.b #65,d0
    move.b d0,B1
; B2 = 65
    move.b #65,d0
    move.b d0,B2
; B3 = 66
    move.b #66,d0
    move.b d0,B3
; B4 = 66
    move.b #66,d0
    move.b d0,B4
; B5 = 67
    move.b #67,d0
    move.b d0,B5
    ifne BROKEN
; CAPACITY = 0
    move.b #0,d0
    move.b d0,CAPACITY
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of worldkit client.
