show_grade_text:
            ; Determine which track to show grade on
            lda check_track
            cmp #TRACK_1
            bne sgt_not_t1
            ; Track 1
            lda #GRADE_FLASH_TIME
            sta grade_timer_t1
            ldx #ROW_TRACK1
            jmp sgt_draw

sgt_not_t1:
            cmp #TRACK_2
            bne sgt_t3
            ; Track 2
            lda #GRADE_FLASH_TIME
            sta grade_timer_t2
            ldx #ROW_TRACK2
            jmp sgt_draw

sgt_t3:
            ; Track 3
            lda #GRADE_FLASH_TIME
            sta grade_timer_t3
            ldx #ROW_TRACK3

sgt_draw:
            ; X = row number, calculate base address
            stx grade_row
            lda current_grade
            cmp #GRADE_PERFECT
            bne sgt_not_perf

            ; Draw "PERFECT" in green
            jsr draw_perfect_text
            rts

sgt_not_perf:
            cmp #GRADE_GOOD
            bne sgt_is_late

            ; Draw "GOOD" in yellow
            jsr draw_good_text
            rts

sgt_is_late:
            ; Draw "LATE" in red
            jsr draw_late_text
            rts
