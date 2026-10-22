; TIA channel0; sound duration is serviced in overscan, not a CPU delay.
trigger_sound:
    lda #4
    sta $15
    lda #15
    sta $17
    sta $19
    lda #8
    sta $85
    rts
service_sound:
    lda $85
    beq sound_done
    dec $85
    bne sound_done
    lda #0
    sta $19
sound_done:
    rts
