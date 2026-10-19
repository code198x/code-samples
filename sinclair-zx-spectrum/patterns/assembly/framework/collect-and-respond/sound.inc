; Short blocking ULA beep; caller keeps border black/MIC low.
; DI is required by sound_beep; restore IM1 service immediately afterwards.
; Changes AF/B/D/H/L; sound lasts about 9 ms excluding interrupts/contention.
trigger_sound:
    di
    xor a
    ld hl,$640c
    call sound_beep
    ei
    ret
