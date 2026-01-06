update_title:
            jsr check_space_key
            beq +
            jsr start_game
+           rts
