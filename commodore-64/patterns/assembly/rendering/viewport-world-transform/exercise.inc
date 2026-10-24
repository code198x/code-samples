exercise_rules:
    lda #<(OUTPUT)
    sta ptr
    lda #>(OUTPUT)
    sta ptr+1
    lda #165
    jsr emit
    lda #8
    jsr emit
    lda #CUSTOM
    jsr emit
    ldx #0
    lda #255
dirty_state:
    sta STATE,x
    inx
    cpx #14
    bne dirty_state
    ldy #$93
    jsr viewport_world_transform_init
    cpy #$93
    bne failed_register
    jsr emit_state
    lda #<(case_table)
    sta input_ptr
    lda #>(case_table)
    sta input_ptr+1
    lda #64
    sta cases_left
case_loop:
    ldx #0
case_read:
    ldy #0
    lda (input_ptr),y
    sta STATE,x
    inc input_ptr
    bne case_read_next
    inc input_ptr+1
case_read_next:
    inx
    cpx #14
    bne case_read
    jsr checked_step
    jsr emit_state
    dec cases_left
    bne case_loop
    jsr viewport_world_transform_init
    jsr preview_rules
    ldx #0
preview_copy:
    lda #0
    sta preview,x
    inx
    cpx #8
    bne preview_copy
    ldx #0
preview_state:
    lda STATE,x
    sta preview,x
    inx
    cpx #8
    bne preview_state
    lda #239
    jsr emit
    rts
checked_step:
    ldy #$93
    jsr viewport_world_transform_step
    cpy #$93
    bne failed_register
    rts
failed_register:
    jmp failed_register
emit_state:
    ldx #0
emit_state_loop:
    lda STATE,x
    jsr emit
    inx
    cpx #14
    bne emit_state_loop
    rts
emit:
    sty saved_y
    ldy #0
    sta (ptr),y
    inc ptr
    bne emit_done
    inc ptr+1
emit_done:
    ldy saved_y
    rts
; Sequential client: retain private state between service calls.
preview_rules:
!if CUSTOM {
; WORLD_X_LO = 255
    lda #255
    sta WORLD_X_LO
; WORLD_X_HI = 255
    lda #255
    sta WORLD_X_HI
; WORLD_Y_LO = 255
    lda #255
    sta WORLD_Y_LO
; WORLD_Y_HI = 255
    lda #255
    sta WORLD_Y_HI
; CAMERA_X_LO = 254
    lda #254
    sta CAMERA_X_LO
; CAMERA_X_HI = 255
    lda #255
    sta CAMERA_X_HI
; CAMERA_Y_LO = 254
    lda #254
    sta CAMERA_Y_LO
; CAMERA_Y_HI = 255
    lda #255
    sta CAMERA_Y_HI
; WIDTH = 2
    lda #2
    sta WIDTH
; HEIGHT = 2
    lda #2
    sta HEIGHT
!if BROKEN {
; WORLD_X_HI = 0
    lda #0
    sta WORLD_X_HI
}
    jsr checked_step
    jsr emit_state
    rts
} else {
; WORLD_X_LO = 5
    lda #5
    sta WORLD_X_LO
; WORLD_X_HI = 1
    lda #1
    sta WORLD_X_HI
; WORLD_Y_LO = 10
    lda #10
    sta WORLD_Y_LO
; WORLD_Y_HI = 1
    lda #1
    sta WORLD_Y_HI
; CAMERA_X_LO = 250
    lda #250
    sta CAMERA_X_LO
; CAMERA_X_HI = 0
    lda #0
    sta CAMERA_X_HI
; CAMERA_Y_LO = 0
    lda #0
    sta CAMERA_Y_LO
; CAMERA_Y_HI = 1
    lda #1
    sta CAMERA_Y_HI
; WIDTH = 32
    lda #32
    sta WIDTH
; HEIGHT = 24
    lda #24
    sta HEIGHT
!if BROKEN {
; WORLD_X_HI = 0
    lda #0
    sta WORLD_X_HI
}
    jsr checked_step
    jsr emit_state
}
    rts
; End of nightone client.
