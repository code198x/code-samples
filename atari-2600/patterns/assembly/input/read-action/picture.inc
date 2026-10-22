; TIA playfield, fixed black backdrop; one white bar moves horizontally.
init_picture:
    lda #0
    sta $09
    sta $85
    lda #14
    sta $08                  ; COLUPF
    rts
draw_picture:
    lda $80
    and #1
    beq draw_left
    lda #$40
    bne draw_bar
draw_left:
    lda #$80
draw_bar:
    sta $0e                  ; PF1, mirrored/repeated by TIA across each scanline
    rts
