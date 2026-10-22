    ld a,$10
    ld [$ff00],a             ; select action buttons (P15 low)
    ld a,[$ff00]
    ld a,[$ff00]
    ld a,[$ff00]
    ld a,[$ff00]
    ld a,[$ff00]
    ld a,[$ff00]
    cpl
    and 1
    ld b,a
