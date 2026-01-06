;──────────────────────────────────────────────────────────────
; Draw the 8x8 game board with coloured cells
; Each cell is 2x2 character cells
; Board starts at screen row 4, column 8
;──────────────────────────────────────────────────────────────
draw_board:
            ; Attribute area starts at 22528
            ; Each screen row is 32 attribute bytes
            ; Starting at row 4, col 8: 22528 + (4*32) + 8 = 22664

            ld hl, 22528 + (4 * 32) + 8

            ; cell_y goes 0-7 (8 rows of cells)
            ld a, 0
            ld (cell_y), a

.row_loop:
            ; Each cell is 2 attribute rows tall
            ; Draw first row of this cell row
            call draw_cell_row

            ; Move to next attribute row
            ld de, 32
            add hl, de

            ; Draw second row of this cell row (same colours)
            call draw_cell_row

            ; Move to next attribute row
            add hl, de

            ; Next cell row
            ld a, (cell_y)
            inc a
            ld (cell_y), a
            cp 8
            jr nz, .row_loop

            ret
