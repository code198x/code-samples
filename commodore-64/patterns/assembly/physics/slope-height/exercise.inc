exercise_rules:
    lda #<(OUTPUT)
    sta ptr
    lda #>(OUTPUT)
    sta ptr+1
    lda #165
    jsr emit
    lda #19
    jsr emit
    lda #CUSTOM
    jsr emit
    ldx #0
    lda #255
dirty_state:
    sta STATE,x
    inx
    cpx #13
    bne dirty_state
    ldy #$93
    jsr slope_height_init
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
    cpx #13
    bne case_read
    jsr checked_step
    jsr emit_state
    dec cases_left
    bne case_loop
    jsr slope_height_init
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
    jsr slope_height_step
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
    cpx #13
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
; LOCAL_X = 1
    lda #1
    sta LOCAL_X
; BASE_Y = 100
    lda #100
    sta BASE_Y
; H0 = 7
    lda #7
    sta H0
; H1 = 6
    lda #6
    sta H1
; H2 = 5
    lda #5
    sta H2
; H3 = 4
    lda #4
    sta H3
; H4 = 3
    lda #3
    sta H4
; H5 = 2
    lda #2
    sta H5
; H6 = 1
    lda #1
    sta H6
; H7 = 0
    lda #0
    sta H7
; MIRROR = 1
    lda #1
    sta MIRROR
!if BROKEN {
; LOCAL_X = 0
    lda #0
    sta LOCAL_X
}
    jsr checked_step
    jsr emit_state
; LOCAL_X = 6
    lda #6
    sta LOCAL_X
!if BROKEN {
; LOCAL_X = 0
    lda #0
    sta LOCAL_X
}
    jsr checked_step
    jsr emit_state
    rts
} else {
; LOCAL_X = 1
    lda #1
    sta LOCAL_X
; BASE_Y = 100
    lda #100
    sta BASE_Y
; H0 = 7
    lda #7
    sta H0
; H1 = 6
    lda #6
    sta H1
; H2 = 5
    lda #5
    sta H2
; H3 = 4
    lda #4
    sta H3
; H4 = 3
    lda #3
    sta H4
; H5 = 2
    lda #2
    sta H5
; H6 = 1
    lda #1
    sta H6
; H7 = 0
    lda #0
    sta H7
!if BROKEN {
; LOCAL_X = 0
    lda #0
    sta LOCAL_X
}
    jsr checked_step
    jsr emit_state
; LOCAL_X = 6
    lda #6
    sta LOCAL_X
!if BROKEN {
; LOCAL_X = 0
    lda #0
    sta LOCAL_X
}
    jsr checked_step
    jsr emit_state
}
    rts
; End of gamekit client.
