main_loop:
            ; Wait for vertical blank
            bsr     wait_vblank

            ; Branch based on game mode
            move.w  game_mode,d0
            cmpi.w  #MODE_TITLE,d0
            beq     .do_title
            cmpi.w  #MODE_GAMEOVER,d0
            beq     .do_gameover

            ; MODE_PLAYING - existing gameplay
            bsr     update_game
            bra     main_loop

.do_title:
            bsr     update_title
            bra     main_loop

.do_gameover:
            bsr     update_gameover
            bra     main_loop
