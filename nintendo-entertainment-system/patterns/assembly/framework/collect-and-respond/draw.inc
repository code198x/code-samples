; A=tile, X=x,Y=y; changes A/X/Y/flags. Call only during vblank.
; Nametable $2000, logical grid inset column 8,row 6. No OAM or sprites used.
put_cell:
    sta draw_tile
    tya
    clc
    adc #6
    sta draw_y
    lsr
    lsr
    lsr
    ora #$20
    sta $2006
    lda draw_y
    and #7
    asl
    asl
    asl
    asl
    asl
    sta draw_y
    txa
    clc
    adc #8
    ora draw_y
    sta $2006
    lda draw_tile
    sta $2007
    rts
draw_screen:
    bit $2002
    lda #0
    ldx old_x
    ldy old_y
    jsr put_cell
    lda #0
    ldx #10
    ldy #5
    jsr put_cell
    lda item_active
    beq draw_player
    lda #2
    ldx #10
    ldy #5
    jsr put_cell
draw_player:
    lda #1
    ldx player_x
    ldy player_y
    jsr put_cell
    lda player_x
    sta old_x
    lda player_y
    sta old_y
    lda score
    clc
    adc #3
    ldx #0
    ldy #0
    jsr put_cell
    lda #0
    sta $2005
    sta $2005
    lda #$80
    sta $2000
    rts
