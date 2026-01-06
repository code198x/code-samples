jsr update_display

update_display:
            jsr convert_score
            jsr draw_score
            jsr convert_streak
            jsr draw_streak
            rts
