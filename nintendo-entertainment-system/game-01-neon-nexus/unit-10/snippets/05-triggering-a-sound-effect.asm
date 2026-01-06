play_collect_sound:
    lda #SFX_COLLECT
    sta sfx_type
    lda #15                 ; duration in frames
    sta sfx_timer
    lda #0                  ; start at pitch index 0
    sta sfx_pitch

    ; Set initial sound
    lda #%10111111          ; 50% duty, constant, volume 15
    sta APU_PULSE1_CTRL
    lda #0
    sta APU_PULSE1_SWEEP

    ; High-pitched start
    lda collect_pitches
    sta APU_PULSE1_TIMER_LO
    lda #%00001000          ; length counter load + timer high
    sta APU_PULSE1_TIMER_HI

    rts

play_death_sound:
    lda #SFX_DEATH
    sta sfx_type
    lda #20                 ; longer duration
    sta sfx_timer
    lda #0
    sta sfx_pitch

    lda #%10111111
    sta APU_PULSE1_CTRL
    lda #0
    sta APU_PULSE1_SWEEP

    ; Low-pitched start
    lda death_pitches
    sta APU_PULSE1_TIMER_LO
    lda #%00001000
    sta APU_PULSE1_TIMER_HI

    rts
