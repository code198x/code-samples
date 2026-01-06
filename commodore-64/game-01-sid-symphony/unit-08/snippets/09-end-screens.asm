draw_gameover_screen:
            ldx #$00
-           lda gameover_text,x
            beq +
            sta SCREEN + (10 * 40) + 15,x
            lda #COL_RED
            sta COLOUR + (10 * 40) + 15,x
            inx
            bne -
+           jsr draw_final_score
            rts

draw_victory_screen:
            ldx #$00
-           lda victory_text,x
            beq +
            sta SCREEN + (10 * 40) + 12,x
            lda #COL_GREEN
            sta COLOUR + (10 * 40) + 12,x
            inx
            bne -
+           jsr draw_final_score
            rts
