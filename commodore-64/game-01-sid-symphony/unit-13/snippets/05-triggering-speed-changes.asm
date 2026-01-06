; Reset combo and multiplier on miss
            lda #$00
            sta combo_count
            lda #$01
            sta multiplier
            ; Reset speed to normal
            jsr update_speed
