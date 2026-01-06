@title_state:
    ; Draw title screen if not already drawn
    lda screen_drawn
    bne @title_input
    jsr draw_title_screen
    lda #1
    sta screen_drawn

@title_input:
    jsr read_controller
    ; ... rest of title handling
