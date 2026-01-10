; Flash the border to confirm key press
; Different colour for each key

        bit 0, d            ; Q pressed?
        jr z, no_q
        ld a, RED
        out (BORDER_PORT), a
        call short_delay
        ld a, BLACK
        out (BORDER_PORT), a
no_q:

        bit 4, d            ; Space pressed?
        jr z, no_space
        ld a, WHITE
        out (BORDER_PORT), a
        call short_delay
        ld a, BLACK
        out (BORDER_PORT), a
no_space:

; Visual feedback is crucial during development
; It confirms your input code works before adding game logic
