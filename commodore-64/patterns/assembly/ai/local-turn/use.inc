; Call from your opponent's decision update. The included board/state are writable.
; Include local-turn.inc once. This is a callable fragment, not a loadable PRG.
move_one_turn:
    jsr choose_target
    jsr choose_turn
    ldx choice
    cpx #$ff
    beq move_done
    lda actor_x
    clc
    adc turn_dx,x
    sta actor_x
    lda actor_y
    clc
    adc turn_dy,x
    sta actor_y
move_done:
    rts
