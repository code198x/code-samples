; ----------------------------------------------------------------------------
; Show Results
; ----------------------------------------------------------------------------
; Displays winner message based on scores

show_results:
            ; Clear turn indicator
            ld      a, TURN_ROW
            ld      c, TURN_COL
            ld      b, 4
            ld      e, TEXT_ATTR
            call    set_attr_range

            ; Determine winner
            ld      a, (p1_count)
            ld      b, a
            ld      a, (p2_count)
            cp      b
            jr      c, .sr_p1_wins      ; p2 < p1, so p1 wins
            jr      z, .sr_draw         ; p1 == p2, draw
            ; p2 > p1, p2 wins
            jr      .sr_p2_wins

.sr_p1_wins:
            ; Display "P1 WINS!"
            ld      b, RESULT_ROW
            ld      c, RESULT_COL
            ld      hl, msg_p1_wins
            ld      e, P1_TEXT
            call    print_message
            ret

.sr_p2_wins:
            ; Display "P2 WINS!"
            ld      b, RESULT_ROW
            ld      c, RESULT_COL
            ld      hl, msg_p2_wins
            ld      e, P2_TEXT
            call    print_message
            ret

.sr_draw:
            ; Display "DRAW!"
            ld      b, RESULT_ROW
            ld      c, RESULT_COL + 2   ; Centre "DRAW!" better
            ld      hl, msg_draw
            ld      e, TEXT_ATTR
            call    print_message
            ret
