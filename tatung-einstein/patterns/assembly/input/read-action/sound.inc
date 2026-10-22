; AY channel A; preserve mixer keyboard directions (port A output/B input).
trigger_sound:
    push af
    ld a,0
    out ($02),a
    ld a,100
    out ($03),a
    ld a,1
    out ($02),a
    xor a
    out ($03),a
    ld a,7
    out ($02),a
    ld a,$7e
    out ($03),a
    ld a,8
    out ($02),a
    ld a,15
    out ($03),a
    ld a,8
    ld (SOUND_TICKS),a
    pop af
    ret
service_sound:
    ld a,(SOUND_TICKS)
    or a
    ret z
    dec a
    ld (SOUND_TICKS),a
    ret nz
    ld a,8
    out ($02),a
    xor a
    out ($03),a
    ret
