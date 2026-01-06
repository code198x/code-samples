calculate_grade:
            lda hit_position
            cmp #ZONE_PERFECT       ; < 3 = Perfect
            bcs cg_not_perfect
            ; PERFECT!
            lda #GRADE_PERFECT
            sta current_grade
            lda #POINTS_PERFECT
            jmp cg_add_score

cg_not_perfect:
            cmp #ZONE_GOOD          ; < 6 = Good
            bcs cg_late
            ; GOOD
            lda #GRADE_GOOD
            sta current_grade
            lda #POINTS_GOOD
            jmp cg_add_score

cg_late:
            ; LATE (positions 6-7)
            lda #GRADE_LATE
            sta current_grade
            lda #POINTS_LATE

cg_add_score:
            ; Add points (A contains point value)
            clc
            adc score_lo
            sta score_lo
            bcc cg_done
            inc score_hi
cg_done:
            rts
