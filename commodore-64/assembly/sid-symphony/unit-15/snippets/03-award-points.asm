; ----------------------------------------------------------------------------
; Award Points - Now with distinct sounds for each hit quality
; ----------------------------------------------------------------------------

award_points:
            jsr increment_combo

            lda hit_quality
            cmp #2
            beq award_perfect

            ; Good hit - positive but lesser feedback
            lda #GOOD_SCORE
            jsr apply_multiplier
            jsr add_score

            inc good_count

            ; Play good sound effect (softer, lower pitch)
            jsr play_good_sound

            lda #GOOD_COL           ; Yellow border flash
            sta BORDER
            lda #4                  ; Shorter flash
            sta border_flash

            lda #HEALTH_GOOD
            jsr increase_health

            jmp award_done

award_perfect:
            ; Perfect hit - bright and satisfying feedback
            lda #PERFECT_SCORE
            jsr apply_multiplier
            jsr add_score

            inc perfect_count

            ; Play perfect sound effect (bright, high pitch)
            jsr play_perfect_sound

            lda #PERFECT_COL        ; White border flash
            sta BORDER
            lda #6                  ; Longer flash
            sta border_flash

            lda #HEALTH_PERFECT
            jsr increase_health

award_done:
            jsr display_score
            rts
