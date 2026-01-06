draw_multiplier:
            lda multiplier
            clc
            adc #$30                ; Convert to ASCII digit
            sta SCREEN + ROW_SCORE * 40 + 18
            lda #24                 ; 'X' screen code
            sta SCREEN + ROW_SCORE * 40 + 19

            ; Colour based on multiplier level
            lda multiplier
            cmp #4
            bcs dm_max              ; 4x = cyan
            cmp #3
            bcs dm_high             ; 3x = green
            cmp #2
            bcs dm_mid              ; 2x = yellow
            lda #COL_GREY           ; 1x = grey
            jmp dm_set_col
dm_mid:
            lda #COL_YELLOW
            jmp dm_set_col
dm_high:
            lda #COL_GREEN
            jmp dm_set_col
dm_max:
            lda #COL_CYAN
dm_set_col:
            sta COLOUR + ROW_SCORE * 40 + 18
            sta COLOUR + ROW_SCORE * 40 + 19
            rts
