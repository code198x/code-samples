playing_state:
    inc frame_counter       ; count frames

    lda invuln_timer
    beq @no_invuln
    ; ...
