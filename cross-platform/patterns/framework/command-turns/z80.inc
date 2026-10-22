; Caller defines TURN (four writable bytes) and ACCEPT_KEY.
; init_turn: A/F clobbered. accept_command: A/F/HL clobbered.
init_turn:
    ld (TURN),a
    ld a,1
    ld (TURN+1),a
    xor a
    ld (TURN+2),a
    ld (TURN+3),a
    ret
accept_command:
    ld (TURN+3),a
    xor a
    ld (TURN+2),a
    ld a,(TURN+3)
    cp ACCEPT_KEY
    ret nz
    ld hl,TURN+1
    ld a,(TURN)
    add a,(hl)
    ld (TURN),a
    ld a,1
    ld (TURN+2),a
    ret
