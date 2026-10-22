; Stock 7800 TIA channel0; no POKEY cartridge extension assumed.
trigger_sound:
    lda #4
    sta $15
    lda #15
    sta $17
    sta $19
    lda #8
    sta $1905
    rts
service_sound:
    lda $1905
    beq sound_done
    dec $1905
    bne sound_done
    lda #0
    sta $19
sound_done:
    rts
