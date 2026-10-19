; Paula channel0 only, eight-frame gate. A5 custom base, changes D0/D1/D2/A0.
; Reuses play_sample/stop_sample; trigger must follow >=one off frame.
; This caller's item spacing guarantees it; a faster caller must enforce it.
trigger_sound:
    lea wave,a0
    moveq #8,d0
    move.w #424,d1
    moveq #64,d2
    bsr play_sample
    move.w #8,sound_ticks
    rts
service_sound:
    tst.w sound_ticks
    beq sound_done
    subq.w #1,sound_ticks
    bne sound_done
    bsr stop_sample
sound_done:
    rts
