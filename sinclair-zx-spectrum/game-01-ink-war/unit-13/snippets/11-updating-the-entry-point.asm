start:
        im 1
        ei

        call show_title
        call wait_for_mode      ; Changed from wait_for_start

        call init_game

        jp main_loop
