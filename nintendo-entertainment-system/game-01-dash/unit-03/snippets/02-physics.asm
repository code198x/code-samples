    ; --- Apply gravity ---
    lda vel_y
    clc
    adc #GRAVITY            ; Velocity increases downward each frame
    sta vel_y

    ; --- Apply velocity to Y position ---
    lda player_y
    clc
    adc vel_y               ; Move by current velocity
    sta player_y

    ; --- Floor collision ---
    lda player_y
    cmp #FLOOR_Y
    bcc @in_air             ; player_y < FLOOR_Y — still airborne
    lda #FLOOR_Y
    sta player_y            ; Clamp to floor
    lda #0
    sta vel_y               ; Stop falling
    lda #1
    sta on_ground           ; Back on the ground
@in_air:
