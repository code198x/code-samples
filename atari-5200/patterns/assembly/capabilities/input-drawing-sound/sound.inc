; POKEY channel1 at $E800; SKCTL enabled, AUDCTL conventional clocking.
trigger_sound:
    lda #3
    sta $e80f
    lda #0
    sta $e808
    lda #100
    sta $e800
    lda #$af
    sta $e801
    lda #8
    sta $1005
    rts
service_sound:
    lda $1005
    beq sound_done
    dec $1005
    bne sound_done
    lda #0
    sta $e801
sound_done:
    rts
