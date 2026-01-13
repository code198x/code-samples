; ----------------------------------------------------------------------------
; Draw Board
; ----------------------------------------------------------------------------
; Draws the 8x8 game board with border

draw_board:
            ; Draw the 8x8 playing field (white cells)
            ld      b, BOARD_SIZE   ; 8 rows
            ld      c, BOARD_ROW    ; Start at row 8

.row_loop:
            push    bc

            ld      b, BOARD_SIZE   ; 8 columns
            ld      d, BOARD_COL    ; Start at column 12

.col_loop:
            push    bc

            ; Calculate attribute address: ATTR_BASE + row*32 + col
            ld      a, c            ; Row
            ld      l, a
            ld      h, 0
            add     hl, hl          ; *2
            add     hl, hl          ; *4
            add     hl, hl          ; *8
            add     hl, hl          ; *16
            add     hl, hl          ; *32
            ld      a, d            ; Column
            add     a, l
            ld      l, a
            ld      bc, ATTR_BASE
            add     hl, bc          ; HL = attribute address

            ld      (hl), EMPTY_ATTR ; Set to white (empty cell)

            pop     bc
            inc     d               ; Next column
            djnz    .col_loop

            pop     bc
            inc     c               ; Next row
            djnz    .row_loop

            ret
