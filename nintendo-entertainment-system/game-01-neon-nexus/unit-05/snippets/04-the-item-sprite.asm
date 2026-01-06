.proc update_item_sprite
    lda item_y
    sta $0200 + 20          ; Sprite 5 Y ($0214)
    lda #3                  ; Tile 3 (item graphic)
    sta $0200 + 21          ; Sprite 5 tile
    lda #%00000010          ; Palette 2 (magentas)
    sta $0200 + 22          ; Sprite 5 attributes
    lda item_x
    sta $0200 + 23          ; Sprite 5 X
    rts
.endproc
