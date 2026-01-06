update_endscreen:
            lda space_prev
            bne +                   ; Was already pressed
            jsr check_space_key
            beq ++                  ; Not pressed now
            ; Space just pressed - return to title
            jsr draw_title_screen
            lda #STATE_TITLE
            sta game_state
++          jsr check_space_key
+           sta space_prev
            rts
