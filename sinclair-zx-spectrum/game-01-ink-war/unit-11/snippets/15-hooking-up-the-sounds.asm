;───────────────────────────────────────
; Play appropriate end-game sound
;───────────────────────────────────────
play_result_sound:
        ld a, (winner)
        or a
        jr z, .draw
        cp 1
        jr z, .p1_wins

        ; CPU wins
        call beep_defeat
        ret

.p1_wins:
        call beep_victory
        ret

.draw:
        call beep_draw
        ret
