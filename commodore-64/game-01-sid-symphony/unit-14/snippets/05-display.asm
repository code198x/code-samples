draw_final_score:
            ; Draw "SCORE:" label
            ldx #0
dfs_score:
            lda finalscore_text,x
            beq dfs_score_done
            sta SCREEN + 13 * 40 + 14,x
            lda #COL_WHITE
            sta COLOUR + 13 * 40 + 14,x
            inx
            jmp dfs_score
dfs_score_done:
            ; Draw the actual score digits
            jsr draw_final_score_value

            ; Draw "HIGH:" label
            ldx #0
dfs_high:
            lda highscore_text,x
            beq dfs_high_done
            sta SCREEN + 14 * 40 + 15,x
            lda #COL_YELLOW
            sta COLOUR + 14 * 40 + 15,x
            inx
            jmp dfs_high
dfs_high_done:
            ; Draw the high score digits
            jsr draw_high_score_value
            rts
