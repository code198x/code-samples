;───────────────────────────────────────
; Show game over message
; Input: winner = 0 (draw), 1 (P1), 2 (P2)
;───────────────────────────────────────
show_game_over:
        ; Flash the border to signal game over
        ld b, 20
.flash_loop:
        ld a, 7                 ; White
        out (254), a
        call short_delay
        ld a, 0                 ; Black
        out (254), a
        call short_delay
        djnz .flash_loop

        ; Set border to winner's colour
        ld a, (winner)
        cp 1
        jr nz, .not_p1_win
        ld a, 2                 ; Red for P1
        jr .set_final_border
.not_p1_win:
        cp 2
        jr nz, .draw_border
        ld a, 5                 ; Cyan for P2/AI
        jr .set_final_border
.draw_border:
        ld a, 6                 ; Yellow for draw
.set_final_border:
        out (254), a
        ret

short_delay:
        ld c, 10
.delay_outer:
        halt
        dec c
        jr nz, .delay_outer
        ret
