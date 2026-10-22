; Reuses the stock BASIC READ/POKE/USR entry, then takes over until reset.
start:
    di
    ld sp,$F7F0
    ld a,INITIAL
    call turn_init
    xor a
    ld (CTX+1),a
    ld (CTX+2),a
    ld (CTX+3),a
    in a,($02)
    xor a
    out ($02),a
    ld a,$80
    out ($02),a
    xor a
    out ($02),a
    ld a,$81
    out ($02),a
    call show_turn
main:
    call wait_frame
    ld hl,(CTX+2)
    inc hl
    ld (CTX+2),hl
    ld a,RESET_EACH
    or a
    jr z,keep_state
    xor a
    call turn_init
keep_state:
    call sample_action
    or a
    jr z,no_action
    call turn_advance
no_action:
    call show_turn
    jr main
