draw_title_screen:
            ; Clear screen
            jsr clear_screen

            ; Draw title
            ldx #$00
-           lda title_text,x
            beq +
            sta SCREEN + (5 * 40) + 13,x
            lda #COL_CYAN
            sta COLOUR + (5 * 40) + 13,x
            inx
            bne -
+
            ; Draw instructions
            ldx #$00
-           lda press_space_text,x
            beq +
            sta SCREEN + (12 * 40) + 10,x
            lda #COL_WHITE
            sta COLOUR + (12 * 40) + 10,x
            inx
            bne -
+
            ; Draw controls
            ldx #$00
-           lda controls_text,x
            beq +
            sta SCREEN + (16 * 40) + 8,x
            lda #COL_GREY
            sta COLOUR + (16 * 40) + 8,x
            inx
            bne -
+           rts
