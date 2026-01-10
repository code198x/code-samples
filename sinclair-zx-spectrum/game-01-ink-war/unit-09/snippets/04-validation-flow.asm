; Complete validation flow

check_claim:
        bit 4, d            ; Space pressed?
        ret z               ; No - return

        ; Get cell state
        call get_board_state_address
        ld a, (hl)

        ; Validate: is it empty?
        or a
        jr nz, invalid_move ; Not empty = invalid

        ; Valid: proceed with claim
        call valid_move
        ret

invalid_move:
        call play_error_sound
        ; Flash red, extra long
        ld a, 2
        out (BORDER_PORT), a
        call short_delay
        call short_delay    ; Double delay
        xor a
        out (BORDER_PORT), a
        ret                 ; Turn does NOT change

valid_move:
        ; Claim, display, feedback, switch
        ; ...
        call play_success_sound
        call switch_player
        ret
