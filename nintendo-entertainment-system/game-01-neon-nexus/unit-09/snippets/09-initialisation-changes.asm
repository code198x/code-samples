reset:
    ; ... existing setup ...

    ; Start at title screen
    lda #STATE_TITLE
    sta game_state
    lda #0
    sta screen_drawn

    ; Draw title immediately
    jsr draw_title_screen
    lda #1
    sta screen_drawn
