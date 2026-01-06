game_loop:
    ; Wait for vblank
    lda nmi_ready
    beq game_loop
    lda #0
    sta nmi_ready

    ; Dispatch based on state
    lda game_state

    cmp #STATE_TITLE
    beq @title_state

    cmp #STATE_PLAYING
    beq @playing_state

    ; Must be STATE_GAMEOVER
    jmp @gameover_state

@title_state:
    jsr read_controller
    lda buttons
    and #BTN_START
    beq game_loop           ; wait for Start

    ; Start pressed - begin game
    jsr clear_playfield
    jsr reset_game
    lda #STATE_PLAYING
    sta game_state
    jmp game_loop

@playing_state:
    ; ... existing game logic ...
    jsr read_controller
    jsr update_player
    ; etc.
    jmp game_loop

@gameover_state:
    jsr read_controller
    lda buttons
    and #BTN_START
    beq game_loop           ; wait for Start

    ; Restart game
    jsr clear_playfield
    jsr reset_game
    lda #STATE_PLAYING
    sta game_state
    jmp game_loop
