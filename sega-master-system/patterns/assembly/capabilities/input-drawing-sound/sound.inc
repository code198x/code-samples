PSG equ $7f
; Pulse on SN76489 tone0, eight serviced frames. Other channels are muted here.
trigger_sound:
    push af
    ld a,$80
    out (PSG),a
    ld a,$10
    out (PSG),a
    ld a,$90
    out (PSG),a
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
    ld a,$9f
    out (PSG),a
    ret
