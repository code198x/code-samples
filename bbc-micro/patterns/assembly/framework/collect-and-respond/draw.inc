; VDU31,x,y,char. Input A=ASCII, X/Y=logical cell; changes A/X/Y/flags.
; MODE6 text cell positions x+10, y+6. MOS handles the screen representation.
put_cell:
    pha
    txa
    pha
    tya
    pha
    lda #31
    jsr OSWRCH
    pla
    sta draw_y
    pla
    clc
    adc #10
    jsr OSWRCH
    lda draw_y
    clc
    adc #6
    jsr OSWRCH
    pla
    jmp OSWRCH
draw_screen:
    lda #32
    ldx old_x
    ldy old_y
    jsr put_cell
    lda #32
    ldx #10
    ldy #5
    jsr put_cell
    lda item_active
    beq draw_player
    lda #42
    ldx #10
    ldy #5
    jsr put_cell
draw_player:
    lda #64
    ldx player_x
    ldy player_y
    jsr put_cell
    lda player_x
    sta old_x
    lda player_y
    sta old_y
    lda #31
    jsr OSWRCH
    lda #10
    jsr OSWRCH
    lda #2
    jsr OSWRCH
    lda score
    clc
    adc #48
    jsr OSWRCH
    rts
draw_y: !byte 0
