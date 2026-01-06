; Initialise player sprite (Sprite 0)
    lda #120                ; Y position (middle of screen)
    sta $0200
    lda #1                  ; Tile index 1 (our ship graphic)
    sta $0201
    lda #%00000000          ; Attributes: palette 0, no flip, in front
    sta $0202
    lda #128                ; X position (middle of screen)
    sta $0203
