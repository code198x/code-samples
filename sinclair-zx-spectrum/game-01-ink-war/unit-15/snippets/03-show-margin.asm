; ----------------------------------------------------------------------------
; Show Margin
; ----------------------------------------------------------------------------
; Displays "BY nn CELLS" for victory margin
; A = margin (difference in scores)

show_margin:
            push    af              ; Save margin
            ; Print "BY "
            ld      b, MARGIN_ROW
            ld      c, MARGIN_COL
            ld      hl, msg_by
            ld      e, TEXT_ATTR
            call    print_message
            ; Print margin number
            ld      c, MARGIN_COL + 3
            pop     af
            call    print_two_digits
            ; Print " CELLS"
            ld      c, MARGIN_COL + 5
            ld      hl, msg_cells
            call    print_message
            ret
