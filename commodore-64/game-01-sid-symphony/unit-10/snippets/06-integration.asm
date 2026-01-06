check_hit_on_track:
            ; ... find note in hit zone ...

            ; HIT! Save position for grade calculation
            lda note_x,x
            sta hit_position

            jsr erase_note
            lda #NOTE_INACTIVE
            ldx hit_note_idx
            sta note_x,x

            ; Calculate grade and add appropriate score
            jsr calculate_grade

            ; Show grade text on screen
            jsr show_grade_text

            ; Continue with hit flash, crowd update, etc.
