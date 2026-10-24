; Fixed labelled game state. AF/DE/HL clobbered; BC/IX/IY preserved.
dispatch:
    ld a,(DEADLINE+5)
    or a
    jr z,dispatch_key
    xor a
    ld (KEY),a
    ld hl,EXPIRIES
    inc (hl)
    ld hl,TURN
    inc (hl)
    jp deadline_start
dispatch_key:
    ld a,(KEY)
    cp 2
    jr nz,dispatch_action
    ld a,(DEADLINE+4)
    or a
    jp z,deadline_start
    xor a
    ld (DEADLINE+4),a
    ld hl,0
    ld (DEADLINE+2),hl
    ret
dispatch_action:
    cp 1
    ret nz
    ld hl,TURN
    inc (hl)
    ld a,(DEADLINE+4)
    or a
    ret z
    jp deadline_start
