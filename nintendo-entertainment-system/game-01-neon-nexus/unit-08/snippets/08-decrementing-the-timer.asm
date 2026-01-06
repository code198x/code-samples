game_loop:
    ; Wait for vblank
    lda nmi_ready
    beq game_loop
    lda #0
    sta nmi_ready

    ; Only update if playing
    lda game_state
    bne @check_start

    ; Decrement invulnerability timer
    lda invuln_timer
    beq @no_invuln
    dec invuln_timer
@no_invuln:

    ; ... rest of game logic ...
