dispatch:
    push af
    xor a
    ld (TURN),a
    pop af
    jp accept_command
