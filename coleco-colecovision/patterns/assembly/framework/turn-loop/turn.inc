; Seven private bytes: turns, previous, fields low/high, current, step, accepted.
; init_turn: A=initial. Clobbers AF. No hardware access.
init_turn:
    ld (T),a
    xor a
    ld (T+1),a
    ld (T+2),a
    ld (T+3),a
    ld (T+4),a
    ld (T+6),a
    inc a
    ld (T+5),a
    ret
; A=active-high sample. Clobbers AF/B; preserves DE/HL/IX/IY.
sample_turn:
    ld (T+4),a
    ld b,a
    include "edge.inc"
    jr z,no_action
    ld a,(T)
    ld b,a
    ld a,(T+5)
    add a,b
    ld (T),a
    ld a,1
    jr remember
no_action:
    xor a
remember:
    ld (T+6),a
    ld a,(T+4)
    ld (T+1),a
    ret
; One serviced display field; HL clobbered; flags preserved.
service_tick:
    ld hl,(T+2)
    inc hl
    ld (T+2),hl
    ret
turn_end:
