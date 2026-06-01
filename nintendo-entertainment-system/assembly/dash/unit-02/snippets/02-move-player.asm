    ; --- Move player left/right ---
    lda buttons
    and #BTN_LEFT           ; Left pressed?
    beq @not_left
    lda player_x
    beq @not_left           ; Already at left edge (X = 0)
    dec player_x
@not_left:

    lda buttons
    and #BTN_RIGHT          ; Right pressed?
    beq @not_right
    lda player_x
    cmp #RIGHT_WALL
    bcs @not_right          ; At or past right edge
    inc player_x
@not_right:
