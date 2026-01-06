;───────────────────────────────────────
; Beep for cursor movement
;───────────────────────────────────────
beep_move:
        ld de, 50               ; High pitch
        ld bc, 20               ; Very short
        call play_beep
        ret
