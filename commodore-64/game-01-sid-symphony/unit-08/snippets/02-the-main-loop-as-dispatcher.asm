main_loop:
            jsr wait_frame

            lda game_state
            cmp #STATE_TITLE
            bne +
            jsr update_title
            jmp main_loop
+           cmp #STATE_PLAYING
            bne +
            jsr update_playing
            jmp main_loop
+           jsr update_endscreen      ; Game over or victory
            jmp main_loop
