update_sound:
    ; Check if sound is playing
    lda sfx_timer
    beq @silent             ; no sound playing

    ; Decrement timer
    dec sfx_timer
    beq @end_sound          ; sound just ended

    ; Update pitch (sweep effect)
    lda sfx_type
    cmp #SFX_COLLECT
    beq @update_collect
    cmp #SFX_DEATH
    beq @update_death
    rts

@update_collect:
    ; Rising pitch - move through table
    inc sfx_pitch
    ldx sfx_pitch
    cpx #5                  ; table length
    bcs @done               ; past end of table
    lda collect_pitches, x
    sta APU_PULSE1_TIMER_LO
@done:
    rts

@update_death:
    ; Falling pitch
    inc sfx_pitch
    ldx sfx_pitch
    cpx #5
    bcs @done2
    lda death_pitches, x
    sta APU_PULSE1_TIMER_LO
@done2:
    rts

@end_sound:
    ; Silence the channel
    lda #%00110000          ; volume 0
    sta APU_PULSE1_CTRL
    lda #SFX_NONE
    sta sfx_type
    rts

@silent:
    rts
