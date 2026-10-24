exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #10,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #13,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr rectangle_clipping_init
    bsr emit_state
    lea case_table,a3
    moveq #63,d6
case_loop:
    lea STATE,a0
    moveq #13,d0
case_read:
    move.b (a3)+,(a0)+
    dbra d0,case_read
    bsr checked_step
    bsr emit_state
    dbra d6,case_loop
    bsr rectangle_clipping_init
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
    bsr rectangle_clipping_step
    cmp.l #$52a39374,d4
    bne failed
    cmpa.l #$12345,a2
    bne failed
    rts
emit_state:
    lea STATE,a0
    moveq #13,d0
emit_state_loop:
    move.b (a0)+,(a4)+
    dbra d0,emit_state_loop
    rts
; Sequential client: retain private state between service calls.
preview_rules:
    ifne CUSTOM
; LEFT = 0
    move.b #0,d0
    move.b d0,LEFT
; TOP = 0
    move.b #0,d0
    move.b d0,TOP
; RIGHT = 255
    move.b #255,d0
    move.b d0,RIGHT
; BOTTOM = 255
    move.b #255,d0
    move.b d0,BOTTOM
; VIEW_LEFT = 10
    move.b #10,d0
    move.b d0,VIEW_LEFT
; VIEW_TOP = 20
    move.b #20,d0
    move.b d0,VIEW_TOP
; VIEW_RIGHT = 30
    move.b #30,d0
    move.b d0,VIEW_RIGHT
; VIEW_BOTTOM = 40
    move.b #40,d0
    move.b d0,VIEW_BOTTOM
    ifne BROKEN
; VIEW_RIGHT = 255
    move.b #255,d0
    move.b d0,VIEW_RIGHT
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; LEFT = 2
    move.b #2,d0
    move.b d0,LEFT
; TOP = 3
    move.b #3,d0
    move.b d0,TOP
; RIGHT = 12
    move.b #12,d0
    move.b d0,RIGHT
; BOTTOM = 15
    move.b #15,d0
    move.b d0,BOTTOM
; VIEW_LEFT = 5
    move.b #5,d0
    move.b d0,VIEW_LEFT
; VIEW_TOP = 0
    move.b #0,d0
    move.b d0,VIEW_TOP
; VIEW_RIGHT = 10
    move.b #10,d0
    move.b d0,VIEW_RIGHT
; VIEW_BOTTOM = 10
    move.b #10,d0
    move.b d0,VIEW_BOTTOM
    ifne BROKEN
; VIEW_RIGHT = 255
    move.b #255,d0
    move.b d0,VIEW_RIGHT
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of toolkit client.
