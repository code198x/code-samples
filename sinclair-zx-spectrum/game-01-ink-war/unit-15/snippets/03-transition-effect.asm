; Screen transition effect when restarting
; Creates a brief flash to signal the state change

flash_screen_transition:
        ; Flash screen to white
        ld a, 7                 ; White border
        out (BORDER_PORT), a

        ld hl, ATTR_START
        ld de, ATTR_START + 1
        ld bc, ATTR_SIZE - 1
        ld (hl), %00111111      ; Bright white
        ldir

        call short_delay
        call short_delay

        ; Fade to black
        xor a                   ; Black border
        out (BORDER_PORT), a

        ld hl, ATTR_START
        ld de, ATTR_START + 1
        ld bc, ATTR_SIZE - 1
        ld (hl), 0              ; Black
        ldir

        call short_delay
        ret

; Restart sound - ascending tones
play_restart_sound:
        ld hl, 100              ; Lowest pitch
        ld de, 100
        call beep
        ld hl, 80               ; Middle pitch
        ld de, 100
        call beep
        ld hl, 60               ; Highest pitch
        ld de, 100
        call beep
        ret
