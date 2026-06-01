    ; --- Read controller ---
    jsr read_controller

    ; --- State dispatch ---
    lda game_state
    cmp #STATE_TITLE
    beq title_update
    cmp #STATE_GAMEOVER
    beq gameover_update
    jmp playing_update

; -----------------------------------------------------------------------------
; Title State
; -----------------------------------------------------------------------------
title_update:
    ; Check for Start press (edge: pressed now, not held before)
    lda buttons
    and #BTN_START
    beq @done
    lda prev_buttons
    and #BTN_START
    bne @done

    ; Start pressed — begin game
    jsr init_game_screen
    lda #STATE_PLAYING
    sta game_state

@done:
    lda buttons
    sta prev_buttons
    jmp main_loop

; -----------------------------------------------------------------------------
; Game Over State
; -----------------------------------------------------------------------------
gameover_update:
    ; Check for Start press (edge)
    lda buttons
    and #BTN_START
    beq @done
    lda prev_buttons
    and #BTN_START
    bne @done

    ; Start pressed — return to title
    jsr init_title_screen
    lda #STATE_TITLE
    sta game_state

@done:
    lda buttons
    sta prev_buttons
    jmp main_loop
