; ----------------------------------------------------------------------------
; Draw Board Border
; ----------------------------------------------------------------------------
; Draws a visible border around the 8x8 playing area

draw_board_border:
            ; Top border (row 7, columns 11-20)
            ld      c, BOARD_ROW-1      ; Row 7
            ld      d, BOARD_COL-1      ; Start at column 11
            ld      b, BOARD_SIZE+2     ; 10 cells wide
            call    draw_border_row

            ; Bottom border (row 16, columns 11-20)
            ld      c, BOARD_ROW+BOARD_SIZE  ; Row 16
            ld      d, BOARD_COL-1
            ld      b, BOARD_SIZE+2
            call    draw_border_row

            ; Left border (rows 8-15, column 11)
            ld      c, BOARD_ROW        ; Start at row 8
            ld      d, BOARD_COL-1      ; Column 11
            ld      b, BOARD_SIZE       ; 8 cells tall
            call    draw_border_col

            ; Right border (rows 8-15, column 20)
            ld      c, BOARD_ROW
            ld      d, BOARD_COL+BOARD_SIZE  ; Column 20
            ld      b, BOARD_SIZE
            call    draw_border_col

            ret
