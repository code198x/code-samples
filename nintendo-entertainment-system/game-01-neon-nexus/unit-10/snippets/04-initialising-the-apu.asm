init_apu:
    ; Enable pulse 1 and pulse 2
    lda #%00000011
    sta APU_STATUS

    ; Silence pulse 1
    lda #%00110000          ; duty 00, halt, constant, volume 0
    sta APU_PULSE1_CTRL

    ; Disable sweep
    lda #0
    sta APU_PULSE1_SWEEP

    ; Clear sound effect state
    lda #0
    sta sfx_timer
    sta sfx_type

    rts
