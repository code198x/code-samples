.proc update_enemy_sprites
    ldx #0                  ; Enemy index
    ldy #4                  ; OAM offset (skip sprite 0)
@loop:
    ; Y position
    lda enemy_y, x
    sta $0200, y
    iny

    ; Tile index (enemy graphic)
    lda #2                  ; Tile 2 = enemy
    sta $0200, y
    iny

    ; Attributes (palette 1, no flip)
    lda #%00000001          ; Sprite palette 1
    sta $0200, y
    iny

    ; X position
    lda enemy_x, x
    sta $0200, y
    iny

    ; Next enemy
    inx
    cpx #4
    bne @loop
    rts
.endproc
