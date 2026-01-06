trigger_game_over:
            lda #$00
            sta game_running

            ; Draw "GAME OVER" text
            ldx #$00
-           lda gameover_text,x
            beq +
            sta SCREEN + (14 * 40) + 15,x
            lda #COL_RED
            sta COLOUR + (14 * 40) + 15,x
            inx
            bne -
+           rts

gameover_text:
            !scr "game over"
            !byte 0
