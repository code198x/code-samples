    ; --- Animation ---
    lda moving
    beq @reset_anim

    inc anim_timer
    lda anim_timer
    cmp #ANIM_SPEED
    bcc @anim_done
    lda #0
    sta anim_timer
    lda anim_frame
    eor #1                  ; Toggle between 0 and 1
    sta anim_frame
    jmp @anim_done

@reset_anim:
    lda #0
    sta anim_timer
    sta anim_frame

@anim_done:

    ; --- Update sprite positions ---
    lda player_y
    sta oam_buffer+0
    lda player_x
    sta oam_buffer+3

    ; Set animation tile
    lda anim_frame
    beq @frame1
    lda #PLAYER_TILE_2
    jmp @set_tile
@frame1:
    lda #PLAYER_TILE_1
@set_tile:
    sta oam_buffer+1
