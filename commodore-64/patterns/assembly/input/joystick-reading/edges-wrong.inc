; Deliberately broken: forget the previous sample before every poll.
joy_wrong_poll:
    lda #0
    sta joy1
    sta joy2
    jmp joy_poll_edges
