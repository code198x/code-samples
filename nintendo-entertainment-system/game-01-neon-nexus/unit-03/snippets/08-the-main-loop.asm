; Main loop
forever:
    lda frame_counter
@wait:
    cmp frame_counter       ; Has NMI fired?
    beq @wait               ; No - keep waiting

    jsr read_controller
    jsr update_player

    jmp forever
