;──────────────────────────────────────────────────────────────
; Get colour for cell at (cell_x, cell_y)
; Returns attribute byte in A
;──────────────────────────────────────────────────────────────
get_cell_colour:
            ; Red zone: top-left corner (x<3, y<3)
            ld a, (cell_x)
            cp 3
            jr nc, .not_red
            ld a, (cell_y)
            cp 3
            jr nc, .not_red

            ; Red cell: PAPER 2 (red), INK 7 (white)
            ld a, 2 * 8 + 7
            ret

.not_red:
            ; Cyan zone: bottom-right corner (x>=5, y>=5)
            ld a, (cell_x)
            cp 5
            jr c, .neutral
            ld a, (cell_y)
            cp 5
            jr c, .neutral

            ; Cyan cell: PAPER 5 (cyan), INK 7 (white)
            ld a, 5 * 8 + 7
            ret

.neutral:
            ; Unclaimed: PAPER 7 (white), INK 0 (black)
            ld a, 7 * 8 + 0
            ret
