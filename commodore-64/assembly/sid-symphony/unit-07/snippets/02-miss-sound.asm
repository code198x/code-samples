; ----------------------------------------------------------------------------
; Miss Sound Settings
; ----------------------------------------------------------------------------

MISS_FREQ   = $08               ; Low rumble
MISS_WAVE   = $81               ; Noise waveform
MISS_AD     = $00               ; Instant attack, no decay
MISS_SR     = $90               ; High sustain, fast release

; ----------------------------------------------------------------------------
; Play Miss Sound - Harsh noise burst
; ----------------------------------------------------------------------------

play_miss_sound:
            ; Use voice 3 for miss sound (temporary override)
            lda #0
            sta SID_V3_FREQ_LO
            lda #MISS_FREQ
            sta SID_V3_FREQ_HI
            lda #MISS_AD
            sta SID_V3_AD
            lda #MISS_SR
            sta SID_V3_SR
            lda #MISS_WAVE
            ora #$01            ; Gate on
            sta SID_V3_CTRL
            rts
