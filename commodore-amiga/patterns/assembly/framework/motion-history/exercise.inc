exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #15,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #24,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr motion_history_init
    bsr emit_state
    lea case_table,a3
    moveq #39,d6
case_loop:
    lea STATE,a0
    moveq #24,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr motion_history_init
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
    bsr motion_history_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #24,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: retain private state between service calls.
preview_rules:
    ifne CUSTOM
; INPUT_X = 0
    move.b #0,d0
    move.b d0,INPUT_X
; INPUT_Y = 1
    move.b #1,d0
    move.b d0,INPUT_Y
; PUSH = 1
    move.b #1,d0
    move.b d0,PUSH
    ifne BROKEN
; HEAD = 0
    move.b #0,d0
    move.b d0,HEAD
    endif
    bsr checked_step
    bsr emit_state
; INPUT_X = 1
    move.b #1,d0
    move.b d0,INPUT_X
; INPUT_Y = 2
    move.b #2,d0
    move.b d0,INPUT_Y
; PUSH = 1
    move.b #1,d0
    move.b d0,PUSH
    ifne BROKEN
; HEAD = 0
    move.b #0,d0
    move.b d0,HEAD
    endif
    bsr checked_step
    bsr emit_state
; INPUT_X = 2
    move.b #2,d0
    move.b d0,INPUT_X
; INPUT_Y = 3
    move.b #3,d0
    move.b d0,INPUT_Y
; PUSH = 1
    move.b #1,d0
    move.b d0,PUSH
    ifne BROKEN
; HEAD = 0
    move.b #0,d0
    move.b d0,HEAD
    endif
    bsr checked_step
    bsr emit_state
; INPUT_X = 3
    move.b #3,d0
    move.b d0,INPUT_X
; INPUT_Y = 4
    move.b #4,d0
    move.b d0,INPUT_Y
; PUSH = 1
    move.b #1,d0
    move.b d0,PUSH
    ifne BROKEN
; HEAD = 0
    move.b #0,d0
    move.b d0,HEAD
    endif
    bsr checked_step
    bsr emit_state
; INPUT_X = 4
    move.b #4,d0
    move.b d0,INPUT_X
; INPUT_Y = 5
    move.b #5,d0
    move.b d0,INPUT_Y
; PUSH = 1
    move.b #1,d0
    move.b d0,PUSH
    ifne BROKEN
; HEAD = 0
    move.b #0,d0
    move.b d0,HEAD
    endif
    bsr checked_step
    bsr emit_state
; INPUT_X = 5
    move.b #5,d0
    move.b d0,INPUT_X
; INPUT_Y = 6
    move.b #6,d0
    move.b d0,INPUT_Y
; PUSH = 1
    move.b #1,d0
    move.b d0,PUSH
    ifne BROKEN
; HEAD = 0
    move.b #0,d0
    move.b d0,HEAD
    endif
    bsr checked_step
    bsr emit_state
; INPUT_X = 6
    move.b #6,d0
    move.b d0,INPUT_X
; INPUT_Y = 7
    move.b #7,d0
    move.b d0,INPUT_Y
; PUSH = 1
    move.b #1,d0
    move.b d0,PUSH
    ifne BROKEN
; HEAD = 0
    move.b #0,d0
    move.b d0,HEAD
    endif
    bsr checked_step
    bsr emit_state
; INPUT_X = 7
    move.b #7,d0
    move.b d0,INPUT_X
; INPUT_Y = 8
    move.b #8,d0
    move.b d0,INPUT_Y
; PUSH = 1
    move.b #1,d0
    move.b d0,PUSH
    ifne BROKEN
; HEAD = 0
    move.b #0,d0
    move.b d0,HEAD
    endif
    bsr checked_step
    bsr emit_state
; INPUT_X = 8
    move.b #8,d0
    move.b d0,INPUT_X
; INPUT_Y = 9
    move.b #9,d0
    move.b d0,INPUT_Y
; PUSH = 1
    move.b #1,d0
    move.b d0,PUSH
    ifne BROKEN
; HEAD = 0
    move.b #0,d0
    move.b d0,HEAD
    endif
    bsr checked_step
    bsr emit_state
; PUSH = 0
    move.b #0,d0
    move.b d0,PUSH
; LAG = 7
    move.b #7,d0
    move.b d0,LAG
    ifne BROKEN
; HEAD = 0
    move.b #0,d0
    move.b d0,HEAD
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; INPUT_X = 10
    move.b #10,d0
    move.b d0,INPUT_X
; INPUT_Y = 20
    move.b #20,d0
    move.b d0,INPUT_Y
; PUSH = 1
    move.b #1,d0
    move.b d0,PUSH
    ifne BROKEN
; HEAD = 0
    move.b #0,d0
    move.b d0,HEAD
    endif
    bsr checked_step
    bsr emit_state
; INPUT_X = 30
    move.b #30,d0
    move.b d0,INPUT_X
; INPUT_Y = 40
    move.b #40,d0
    move.b d0,INPUT_Y
    ifne BROKEN
; HEAD = 0
    move.b #0,d0
    move.b d0,HEAD
    endif
    bsr checked_step
    bsr emit_state
; INPUT_X = 50
    move.b #50,d0
    move.b d0,INPUT_X
; INPUT_Y = 60
    move.b #60,d0
    move.b d0,INPUT_Y
    ifne BROKEN
; HEAD = 0
    move.b #0,d0
    move.b d0,HEAD
    endif
    bsr checked_step
    bsr emit_state
; PUSH = 0
    move.b #0,d0
    move.b d0,PUSH
; LAG = 2
    move.b #2,d0
    move.b d0,LAG
    ifne BROKEN
; HEAD = 0
    move.b #0,d0
    move.b d0,HEAD
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of worldkit client.
