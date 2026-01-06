move_enemies:
    ; Get horizontal speed from difficulty
    ldx difficulty
    lda enemy_speeds, x
    sta temp                ; horizontal speed

    ldx #0                  ; enemy index

@loop:
    ; --- Horizontal movement (all enemies) ---
    lda enemy_x, x
    sec
    sbc temp
    sta enemy_x, x

    ; Check horizontal wrap
    cmp #250
    bcc @check_vertical
    lda #248
    sta enemy_x, x

@check_vertical:
    ; Only enemies 0-1 move vertically
    cpx #2
    bcs @next               ; enemies 2-3 skip vertical

    ; --- Vertical movement ---
    lda enemy_dir, x
    beq @move_down
    ; Moving up
    lda enemy_y, x
    sec
    sbc #1                  ; move up 1 pixel
    cmp #24                 ; top boundary (below HUD)
    bcs @store_y
    ; Hit top - reverse to down
    lda #0
    sta enemy_dir, x
    lda #24
    jmp @store_y

@move_down:
    lda enemy_y, x
    clc
    adc #1                  ; move down 1 pixel
    cmp #216                ; bottom boundary
    bcc @store_y
    ; Hit bottom - reverse to up
    lda #1
    sta enemy_dir, x
    lda #215

@store_y:
    sta enemy_y, x

@next:
    inx
    cpx #NUM_ENEMIES
    bne @loop

    rts
