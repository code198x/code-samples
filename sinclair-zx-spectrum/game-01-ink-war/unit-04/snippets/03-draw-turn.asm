; ----------------------------------------------------------------------------
; Draw Turn Indicator
; ----------------------------------------------------------------------------
; Shows "TURN" with current player's colour

draw_turn_indicator:
            ; Print "TURN"
            ld      b, TURN_ROW
            ld      c, TURN_COL
            ld      a, 'T'
            call    print_char
            inc     c
            ld      a, 'U'
            call    print_char
            inc     c
            ld      a, 'R'
            call    print_char
            inc     c
            ld      a, 'N'
            call    print_char

            ; Set attribute based on current player
            ld      a, (current_player)
            cp      1
            jr      z, .dti_p1
            ld      e, P2_TEXT
            jr      .dti_set
.dti_p1:
            ld      e, P1_TEXT

.dti_set:
            ld      a, TURN_ROW
            ld      c, TURN_COL
            ld      b, 4                ; "TURN" = 4 chars
            call    set_attr_range

            ret
