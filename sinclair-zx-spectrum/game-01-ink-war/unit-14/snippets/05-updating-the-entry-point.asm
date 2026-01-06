start:
        im 1
        ei

        call show_title
        call wait_for_mode

        ; Show difficulty selection for 1P mode only
        ld a, (game_mode)
        cp 1
        jr nz, .skip_difficulty

        call show_difficulty
        call wait_for_difficulty

.skip_difficulty:
        call init_game

        jp main_loop
