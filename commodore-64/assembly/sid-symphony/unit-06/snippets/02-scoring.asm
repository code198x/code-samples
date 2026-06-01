; ----------------------------------------------------------------------------
; Award Points - Add score based on hit quality
; ----------------------------------------------------------------------------

award_points:
            lda hit_quality
            cmp #2
            beq award_perfect

            ; Good hit - add 50 points
            lda score_lo
            clc
            adc #GOOD_SCORE
            sta score_lo
            lda score_hi
            adc #0
            sta score_hi

            ; Yellow border flash for good
            lda #GOOD_COL
            sta BORDER
            lda #4              ; Flash for 4 frames
            sta border_flash

            jmp award_done

award_perfect:
            ; Perfect hit - add 100 points
            lda score_lo
            clc
            adc #PERFECT_SCORE
            sta score_lo
            lda score_hi
            adc #0
            sta score_hi

            ; White border flash for perfect
            lda #PERFECT_COL
            sta BORDER
            lda #6              ; Flash for 6 frames
            sta border_flash

award_done:
            jsr display_score
            rts
