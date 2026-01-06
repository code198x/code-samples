MODE_TITLE      equ     0
MODE_PLAYING    equ     1
MODE_GAMEOVER   equ     2
MODE_ENTRY      equ     3       ; Name entry

; In main loop:
main_loop:
            bsr     wait_vblank

            move.w  game_mode,d0
            cmpi.w  #MODE_TITLE,d0
            beq     .do_title
            cmpi.w  #MODE_GAMEOVER,d0
            beq     .do_gameover
            cmpi.w  #MODE_ENTRY,d0
            beq     .do_entry

            bsr     update_game
            bra     main_loop

.do_entry:
            bsr     update_name_entry
            bra     main_loop
