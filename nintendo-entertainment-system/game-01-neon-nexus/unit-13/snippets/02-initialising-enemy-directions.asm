init_enemies:
    ; Enemy 0: top-left, moves down
    lda #30
    sta enemy_x
    lda #50
    sta enemy_y
    lda #0              ; direction: down
    sta enemy_dir

    ; Enemy 1: top-right, moves up
    lda #200
    sta enemy_x+1
    lda #50
    sta enemy_y+1
    lda #1              ; direction: up
    sta enemy_dir+1

    ; Enemy 2: bottom-left (horizontal only)
    lda #30
    sta enemy_x+2
    lda #180
    sta enemy_y+2

    ; Enemy 3: bottom-right (horizontal only)
    lda #200
    sta enemy_x+3
    lda #180
    sta enemy_y+3

    rts
