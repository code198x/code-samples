; =============================================================================
; check_collect — with collect sound
; =============================================================================
; After hiding the sprite and incrementing the score, three writes to the
; triangle channel registers play a short, bright note.
; =============================================================================

check_collect:
    ; Skip if already collected
    lda oam_buffer, x       ; Sprite Y position
    cmp #$EF
    beq @done

    ; --- Y overlap ---
    lda player_y
    clc
    adc #8
    cmp oam_buffer, x
    bcc @done
    beq @done

    lda oam_buffer, x
    clc
    adc #8
    cmp player_y
    bcc @done
    beq @done

    ; --- X overlap ---
    lda player_x
    clc
    adc #8
    cmp oam_buffer+3, x
    bcc @done
    beq @done

    lda oam_buffer+3, x
    clc
    adc #8
    cmp player_x
    bcc @done
    beq @done

    ; Collected! Hide the sprite and add to score
    lda #$EF
    sta oam_buffer, x
    inc score

    ; Play collect sound (triangle channel)
    lda #%00011000          ; Linear counter: halt=0, reload=24 (~100ms)
    sta TRI_LINEAR
    lda #$29                ; Timer low — bright pitch (~1330 Hz)
    sta TRI_LO
    lda #$00                ; Timer high=0, length counter=0 (10 frames)
    sta TRI_HI

@done:
    rts
