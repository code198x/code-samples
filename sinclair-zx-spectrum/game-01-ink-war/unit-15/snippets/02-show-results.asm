show_results:
            ; Display "GAME OVER" header
            ld      b, GAMEOVER_ROW
            ld      c, GAMEOVER_COL
            ld      hl, msg_gameover
            ld      e, TEXT_ATTR
            call    print_message

            ; Display final P1 score with colour
            ld      b, FINAL_ROW
            ld      c, FINAL_P1_COL
            ; ... print "P1:" and score ...
            ld      e, P1_TEXT
            call    set_attr_range

            ; Display final P2 score with colour
            ; ... same pattern for P2 ...

            ; Determine winner and display message
            ld      a, (p1_count)
            ld      b, a
            ld      a, (p2_count)
            cp      b
            jr      c, .sr_p1_wins
            jr      z, .sr_draw
            jr      .sr_p2_wins

.sr_p1_wins:
            ld      hl, msg_p1_wins
            ld      e, P1_TEXT
            call    print_message
            ; Calculate margin: p1 - p2
            call    show_margin
            jr      .sr_prompt

            ; ... similar for P2 wins and draw ...

.sr_prompt:
            ld      hl, msg_continue
            call    print_message
            ret
