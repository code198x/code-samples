; Non-blocking SID voice-1 gate. Master volume belongs to demo startup.
; Changes A/X/flags. Call service_sound once per frame BEFORE update_player.
trigger_sound:
    lda #$22
    ldx #$4b
    jsr sid_note_on
    lda #8
    sta sound_ticks
    rts
service_sound:
    lda sound_ticks
    beq sound_done
    dec sound_ticks
    bne sound_done
    jsr sid_note_off
sound_done:
    rts
