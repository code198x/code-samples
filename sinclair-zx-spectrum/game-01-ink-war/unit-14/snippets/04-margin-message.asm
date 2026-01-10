; Draw win margin message
; Shows "WON BY X CELLS" or "TIED AT 32 EACH!"

draw_margin_message:
        ld a, (winner)
        or a
        jr z, draw_tied_msg

        ; Set white attributes for margin row
        ld hl, ATTR_START + (RESULT_MARGIN_ROW * ATTR_WIDTH) + RESULT_MARGIN_COL
        ld a, %00000111         ; White ink
        ld b, 14
set_margin_attr:
        ld (hl), a
        inc hl
        djnz set_margin_attr

        ; "WON BY"
        ld hl, msg_won_by
        ld b, RESULT_MARGIN_ROW
        ld c, RESULT_MARGIN_COL
        call print_string

        ; Print margin number
        ld a, (win_margin)
        ld b, RESULT_MARGIN_ROW
        ld c, RESULT_MARGIN_COL + 7
        call print_two_digit

        ; "CELLS"
        ld hl, msg_cells
        ld b, RESULT_MARGIN_ROW
        ld c, RESULT_MARGIN_COL + 10
        call print_string

        ret

draw_tied_msg:
        ; Special message for draws
        ld hl, ATTR_START + (RESULT_MARGIN_ROW * ATTR_WIDTH) + RESULT_MARGIN_COL - 1
        ld a, %00000111         ; White ink
        ld b, 16
set_tied_attr:
        ld (hl), a
        inc hl
        djnz set_tied_attr

        ld hl, msg_tied
        ld b, RESULT_MARGIN_ROW
        ld c, RESULT_MARGIN_COL - 1
        call print_string
        ret
