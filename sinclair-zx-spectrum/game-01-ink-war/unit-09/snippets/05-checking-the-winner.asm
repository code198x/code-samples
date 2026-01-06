;───────────────────────────────────────
; Check game over and declare winner
;───────────────────────────────────────
check_game_over:
        ; Count territories
        call count_territories

        ; Compare counts
        ld a, (p1_count)
        ld b, a
        ld a, (p2_count)
        cp b
        jr z, .draw
        jr c, .p1_wins          ; Carry if p2 < p1

        ; P2 (AI) wins
        ld a, 2
        jr .show_result

.p1_wins:
        ld a, 1
        jr .show_result

.draw:
        xor a                   ; A = 0 for draw

.show_result:
        ld (winner), a
        call show_game_over
        call wait_for_restart
        jp restart_game

winner:         defb 0          ; 0=draw, 1=P1 wins, 2=P2 wins
