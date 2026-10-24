exercise_rules:
    lea OUTPUT,a4
    move.b #165,(a4)+
    move.b #8,(a4)+
    move.b #CUSTOM,(a4)+
    lea STATE,a0
    moveq #13,d0
dirty_state:
    move.b #255,(a0)+
    dbra d0,dirty_state
    bsr viewport_world_transform_init
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
    bsr viewport_world_transform_init
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
    bsr viewport_world_transform_step
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
; WORLD_X_LO = 255
    move.b #255,d0
    move.b d0,WORLD_X_LO
; WORLD_X_HI = 255
    move.b #255,d0
    move.b d0,WORLD_X_HI
; WORLD_Y_LO = 255
    move.b #255,d0
    move.b d0,WORLD_Y_LO
; WORLD_Y_HI = 255
    move.b #255,d0
    move.b d0,WORLD_Y_HI
; CAMERA_X_LO = 254
    move.b #254,d0
    move.b d0,CAMERA_X_LO
; CAMERA_X_HI = 255
    move.b #255,d0
    move.b d0,CAMERA_X_HI
; CAMERA_Y_LO = 254
    move.b #254,d0
    move.b d0,CAMERA_Y_LO
; CAMERA_Y_HI = 255
    move.b #255,d0
    move.b d0,CAMERA_Y_HI
; WIDTH = 2
    move.b #2,d0
    move.b d0,WIDTH
; HEIGHT = 2
    move.b #2,d0
    move.b d0,HEIGHT
    ifne BROKEN
; WORLD_X_HI = 0
    move.b #0,d0
    move.b d0,WORLD_X_HI
    endif
    bsr checked_step
    bsr emit_state
    rts
    else
; WORLD_X_LO = 5
    move.b #5,d0
    move.b d0,WORLD_X_LO
; WORLD_X_HI = 1
    move.b #1,d0
    move.b d0,WORLD_X_HI
; WORLD_Y_LO = 10
    move.b #10,d0
    move.b d0,WORLD_Y_LO
; WORLD_Y_HI = 1
    move.b #1,d0
    move.b d0,WORLD_Y_HI
; CAMERA_X_LO = 250
    move.b #250,d0
    move.b d0,CAMERA_X_LO
; CAMERA_X_HI = 0
    move.b #0,d0
    move.b d0,CAMERA_X_HI
; CAMERA_Y_LO = 0
    move.b #0,d0
    move.b d0,CAMERA_Y_LO
; CAMERA_Y_HI = 1
    move.b #1,d0
    move.b d0,CAMERA_Y_HI
; WIDTH = 32
    move.b #32,d0
    move.b d0,WIDTH
; HEIGHT = 24
    move.b #24,d0
    move.b d0,HEIGHT
    ifne BROKEN
; WORLD_X_HI = 0
    move.b #0,d0
    move.b d0,WORLD_X_HI
    endif
    bsr checked_step
    bsr emit_state
    endif
    rts
; End of nightone client.
