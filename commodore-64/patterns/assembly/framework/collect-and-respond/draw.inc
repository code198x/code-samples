; Draw one character cell. Input A=screen code, X=x, Y=y; destroys A/X/Y.
; Caller reserves zero page $fb-$fe. Screen $0400, character ROM, colour RAM.
put_cell:
    pha
    txa
    clc
    adc #10
    sta $fd
    lda #<$04f0             ; row 6 of the 40-column screen
    sta $fb
    lda #>$04f0
    sta $fc
row_address:
    cpy #0
    beq row_ready
    clc
    lda $fb
    adc #40
    sta $fb
    bcc row_no_carry
    inc $fc
row_no_carry:
    dey
    bne row_address
row_ready:
    ldy $fd
    pla
    sta ($fb),y
    lda $fc
    clc
    adc #$d4
    sta $fc
    lda #1
    sta ($fb),y
    rts
draw_screen:
    lda #32
    ldx old_x
    ldy old_y
    jsr put_cell
    ldx #10
    ldy #5
    lda #32
    jsr put_cell
    lda item_active
    beq draw_player
    lda #42                 ; asterisk: collectible
    ldx #10
    ldy #5
    jsr put_cell
draw_player:
    lda #0                  ; @ in the C64 screen-code set
    ldx player_x
    ldy player_y
    jsr put_cell
    lda player_x
    sta old_x
    lda player_y
    sta old_y
    lda score
    clc
    adc #48
    sta $045a
    lda #1
    sta $d85a
    rts
