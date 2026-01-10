; Draw the complete results screen
; Called after clearing screen in enter_results_state

draw_results_screen:
        call draw_winner_message    ; "RED WINS!" / "BLU WINS!" / "DRAW!"
        call draw_result_scores     ; "RED: 35    BLU: 29"
        call draw_margin_message    ; "WON BY 6 CELLS" or "TIED AT 32 EACH!"
        call draw_result_prompt     ; "PRESS ANY KEY"
        ret

draw_winner_message:
        ld a, (winner)
        or a
        jr z, draw_draw_msg

        cp WINNER_P1
        jr z, draw_p1_wins

        ; P2 wins - cyan
        ld hl, msg_blu_wins
        ld a, %00000101         ; Cyan ink
        jr draw_winner_text

draw_p1_wins:
        ld hl, msg_red_wins
        ld a, %00000010         ; Red ink
        jr draw_winner_text

draw_draw_msg:
        ld hl, msg_draw
        ld a, %00000111         ; White ink

draw_winner_text:
        push hl
        push af

        ; Set attributes for winner row
        ld hl, ATTR_START + (RESULT_WINNER_ROW * ATTR_WIDTH) + RESULT_WINNER_COL
        pop af
        push af
        ld b, 9
set_winner_attr:
        ld (hl), a
        inc hl
        djnz set_winner_attr

        pop af
        pop hl
        ld b, RESULT_WINNER_ROW
        ld c, RESULT_WINNER_COL
        call print_string
        ret
