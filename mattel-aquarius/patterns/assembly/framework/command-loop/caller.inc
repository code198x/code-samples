; Reserve above CLEAR 50,15871. Enter through the normal USR vector.
start:
    push af
    push bc
    push de
    push hl
    push ix
    push iy
    ld a,INITIAL
    call turn_init
main:
    ld a,RESET_EACH
    or a
    jr z,keep_state
    xor a
    call turn_init
keep_state:
    call show_turn
    call new_action
    or a
    jr z,finished
    call turn_advance
    jr main
finished:
    pop iy
    pop ix
    pop hl
    pop de
    pop bc
    pop af
    ret
