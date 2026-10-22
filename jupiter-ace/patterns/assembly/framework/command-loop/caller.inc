; FORTH: reserve dictionary through code_end; execute 15616 CALL.
; IX/IY and the data stack stay untouched. SP is the ROM return stack.
start:
    ld a,INITIAL
    call turn_init
    call draw_box
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
    call trigger_sound
    jr main
finished:
    jp (iy)
