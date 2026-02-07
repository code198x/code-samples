; -----------------------------------------------------------------------------
; check_collect: Check if the player overlaps a collectible sprite
; Input:  X = OAM buffer offset (8, 12, or 16)
; Effect: If overlapping, hides the sprite (sets OAM Y to $EF)
; -----------------------------------------------------------------------------
check_collect:
    ; Skip if already collected
    lda oam_buffer, x       ; Sprite Y position
    cmp #$EF
    beq @done

    ; --- Y overlap ---
    ; Player bottom vs item top
    lda player_y
    clc
    adc #8
    cmp oam_buffer, x
    bcc @done
    beq @done

    ; Item bottom vs player top
    lda oam_buffer, x
    clc
    adc #8
    cmp player_y
    bcc @done
    beq @done

    ; --- X overlap ---
    ; Player right vs item left
    lda player_x
    clc
    adc #8
    cmp oam_buffer+3, x
    bcc @done
    beq @done

    ; Item right vs player left
    lda oam_buffer+3, x
    clc
    adc #8
    cmp player_x
    bcc @done
    beq @done

    ; Collected! Hide the sprite
    lda #$EF
    sta oam_buffer, x

@done:
    rts
