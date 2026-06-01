; ----------------------------------------------------------------------------
; Polished Sound Effect Routines
; ----------------------------------------------------------------------------

; Play Perfect Hit Sound - Bright, high, satisfying
play_perfect_sound:
            lda #0
            sta SID_V3_FREQ_LO
            lda #PERFECT_SFX_FREQ   ; Higher pitch = brighter
            sta SID_V3_FREQ_HI
            lda #$08
            sta SID_V3_PWHI
            lda #PERFECT_SFX_AD     ; Fast attack
            sta SID_V3_AD
            lda #PERFECT_SFX_SR
            sta SID_V3_SR
            lda #PERFECT_SFX_WAVE   ; Sawtooth for brightness
            ora #$01                ; Gate on
            sta SID_V3_CTRL
            rts

; Play Good Hit Sound - Positive but lesser
play_good_sound:
            lda #0
            sta SID_V3_FREQ_LO
            lda #GOOD_SFX_FREQ      ; Lower pitch than perfect
            sta SID_V3_FREQ_HI
            lda #$08
            sta SID_V3_PWHI
            lda #GOOD_SFX_AD        ; Slower decay
            sta SID_V3_AD
            lda #GOOD_SFX_SR
            sta SID_V3_SR
            lda #GOOD_SFX_WAVE      ; Triangle for softness
            ora #$01                ; Gate on
            sta SID_V3_CTRL
            rts

; Play Miss Sound - Harsh buzz
play_miss_sound:
            lda #0
            sta SID_V3_FREQ_LO
            lda #MISS_FREQ          ; Low, ominous
            sta SID_V3_FREQ_HI
            lda #MISS_AD            ; Instant attack
            sta SID_V3_AD
            lda #MISS_SR
            sta SID_V3_SR
            lda #MISS_WAVE          ; Noise = harsh
            ora #$01                ; Gate on
            sta SID_V3_CTRL
            rts

; Play Menu Select Sound - Click
play_menu_select:
            lda #0
            sta SID_V3_FREQ_LO
            lda #MENU_SELECT_FREQ
            sta SID_V3_FREQ_HI
            lda #$08
            sta SID_V3_PWHI
            lda #MENU_SELECT_AD     ; Instant
            sta SID_V3_AD
            lda #MENU_SELECT_SR     ; Very short
            sta SID_V3_SR
            lda #MENU_SELECT_WAVE   ; Pulse for click
            ora #$01                ; Gate on
            sta SID_V3_CTRL
            rts
