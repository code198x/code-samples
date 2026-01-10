; Flash border in winner's colour
; Called repeatedly in game over loop

flash_winner_border:
        ld a, (winner)
        or a
        jr z, flash_white   ; Draw = white flash

        cp WINNER_P1
        jr z, flash_red

flash_blue:
        ld a, 5             ; Cyan
        jr do_flash

flash_red:
        ld a, 2             ; Red
        jr do_flash

flash_white:
        ld a, 7             ; White

do_flash:
        out (BORDER_PORT), a
        call short_delay

        xor a               ; Black
        out (BORDER_PORT), a
        call short_delay

        ret

; The main game over loop:
game_over_loop:
        call flash_winner_border
        jr main_loop
