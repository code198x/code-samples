; DMG pulse channel1, both outputs; non-blocking eight-frame effect.
trigger_sound:
    ld a,$80
    ld [$ff26],a
    ld a,$77
    ld [$ff24],a
    ld a,$11
    ld [$ff25],a
    xor a
    ld [$ff10],a
    ld a,$80
    ld [$ff11],a
    ld a,$f0
    ld [$ff12],a
    xor a
    ld [$ff13],a
    ld a,$87
    ld [$ff14],a
    ld a,8
    ld [$c004],a
    ret
service_sound:
    ld a,[$c004]
    or a
    ret z
    dec a
    ld [$c004],a
    ret nz
    xor a
    ld [$ff12],a
    ret
