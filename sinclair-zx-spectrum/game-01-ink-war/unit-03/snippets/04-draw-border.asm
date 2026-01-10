; Draw a frame around the board
; Top row, bottom row, then left and right sides

draw_border:
        ld a, %00111111         ; White paper, white ink (solid)

        ; Top border row
        ld hl, ATTR_START + (BORDER_TOP * 32) + BORDER_LEFT
        ld b, BORDER_SIZE       ; 10 cells
top_loop:
        ld (hl), a
        inc hl
        djnz top_loop

        ; Bottom border row (9 rows below top)
        ld hl, ATTR_START + ((BORDER_TOP + 9) * 32) + BORDER_LEFT
        ld b, BORDER_SIZE
bottom_loop:
        ld (hl), a
        inc hl
        djnz bottom_loop

        ; Left and right sides (middle 8 rows)
        ld hl, ATTR_START + ((BORDER_TOP + 1) * 32) + BORDER_LEFT
        ld b, 8                 ; 8 rows between top and bottom
sides_loop:
        push bc
        push hl
        ld (hl), a              ; Left side
        ld de, 9                ; Move 9 cells right
        add hl, de
        ld (hl), a              ; Right side
        pop hl
        ld de, 32               ; Next row
        add hl, de
        pop bc
        djnz sides_loop

        ret
