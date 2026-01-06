;──────────────────────────────────────────────────────────────
; Draw one attribute row of cells (8 cells, each 2 chars wide)
; HL = attribute address for start of row
;──────────────────────────────────────────────────────────────
draw_cell_row:
            push hl

            ld a, 0
            ld (cell_x), a

.cell_loop:
            ; Get colour for this cell
            call get_cell_colour

            ; Write 2 attribute bytes (cell is 2 chars wide)
            ld (hl), a
            inc hl
            ld (hl), a
            inc hl

            ; Next cell
            ld a, (cell_x)
            inc a
            ld (cell_x), a
            cp 8
            jr nz, .cell_loop

            pop hl
            ret
