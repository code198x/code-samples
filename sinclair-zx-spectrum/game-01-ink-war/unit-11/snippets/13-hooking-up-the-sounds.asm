show_results:
        ; ... all the printing code ...

        ; Play result sound
        ld a, (winner)
        or a
        jr z, .play_draw
        cp 1
        jr z, .play_win

        ; CPU wins - player loses
        call beep_defeat
        ret

.play_win:
        call beep_victory
        ret

.play_draw:
        call beep_draw
        ret
