start:
        ; Show title screen
        call show_title
        call wait_for_start

        ; Now start the game
        call init_game

        jp main_loop
