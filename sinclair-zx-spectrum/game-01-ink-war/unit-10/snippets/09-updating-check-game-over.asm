check_game_over:
        call count_territories

        ld a, (p1_count)
        ld b, a
        ld a, (p2_count)
        cp b
        jr z, .draw
        jr c, .p1_wins

        ; P2 wins
        ld a, 2
        jr .store_winner

.p1_wins:
        ld a, 1
        jr .store_winner

.draw:
        xor a

.store_winner:
        ld (winner), a
        call show_results       ; New: show full results screen
        call set_winner_border  ; Set border to winner colour
        call wait_for_restart
        jp restart_game
