    ; --- Collision with obstacle ---
    lda on_ground
    beq @no_collide         ; In the air — jumped over it!

    lda obstacle_x
    cmp #240
    bcs @no_collide         ; Obstacle near screen edge — skip

    ; Check X overlap between player and obstacle
    ; Both sprites are 8 pixels wide
    lda player_x
    clc
    adc #8                  ; Player right edge
    cmp obstacle_x          ; Past obstacle left edge?
    bcc @no_collide
    beq @no_collide

    lda obstacle_x
    clc
    adc #8                  ; Obstacle right edge
    cmp player_x            ; Past player left edge?
    bcc @no_collide
    beq @no_collide

    ; Hit! Reset player to starting position
    lda #PLAYER_X
    sta player_x

@no_collide:
