exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #2,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #7,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr aimed_projectile_init
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
    bsr aimed_projectile_init
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
    bsr aimed_projectile_step
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
; ORIGIN_X = 0
    move.b #0,d0
    move.b d0,ORIGIN_X
; ORIGIN_Y = 0
    move.b #0,d0
    move.b d0,ORIGIN_Y
; TARGET_X = 255
    move.b #255,d0
    move.b d0,TARGET_X
; TARGET_Y = 128
    move.b #128,d0
    move.b d0,TARGET_Y
; SPEED = 15
    move.b #15,d0
    move.b d0,SPEED
    ifne BROKEN
; TARGET_X = ORIGIN_X
    move.b ORIGIN_X,d0
    move.b d0,TARGET_X
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; ORIGIN_X = 100
    move.b #100,d0
    move.b d0,ORIGIN_X
; ORIGIN_Y = 100
    move.b #100,d0
    move.b d0,ORIGIN_Y
; TARGET_X = 80
    move.b #80,d0
    move.b d0,TARGET_X
; TARGET_Y = 90
    move.b #90,d0
    move.b d0,TARGET_Y
; SPEED = 6
    move.b #6,d0
    move.b d0,SPEED
    ifne BROKEN
; TARGET_X = ORIGIN_X
    move.b ORIGIN_X,d0
    move.b d0,TARGET_X
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of nighttwo client.
