.proc init_enemies
    ; Enemy 0: left side
    lda #50
    sta enemy_x
    lda #32
    sta enemy_y

    ; Enemy 1: left-centre
    lda #100
    sta enemy_x + 1
    lda #48
    sta enemy_y + 1

    ; Enemy 2: right-centre
    lda #156
    sta enemy_x + 2
    lda #24
    sta enemy_y + 2

    ; Enemy 3: right side
    lda #206
    sta enemy_x + 3
    lda #40
    sta enemy_y + 3

    rts
.endproc
