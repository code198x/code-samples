dispatch:
    ld a,(DEADLINE+5)
    or a
    jr z,consider_action
    ld hl,STATE+6
    inc (hl)
    ld a,2
    ld (STATE+7),a
    call commit_turn
    jp deadline_start
consider_action:
    ld a,(STATE+8)
    cp 32
    ret nz
    ld a,1
    ld (STATE+7),a
    call commit_turn
    ld a,(DEADLINE+4)
    or a
    ret z
    jp deadline_start
