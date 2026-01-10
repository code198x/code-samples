; Fill the 8×8 board area with white (empty cells)

draw_board:
        ; Calculate start address: $5800 + (row × 32) + column
        ld hl, ATTR_START + (BOARD_TOP * 32) + BOARD_LEFT

        ld b, BOARD_SIZE        ; 8 rows

board_row:
        push bc                 ; Save row counter
        push hl                 ; Save row start address

        ld b, BOARD_SIZE        ; 8 columns
        ld a, %00111000         ; White paper, black ink

board_col:
        ld (hl), a              ; Write attribute
        inc hl                  ; Next column
        djnz board_col          ; Repeat for all columns

        pop hl                  ; Restore row start
        ld de, 32               ; 32 bytes per row
        add hl, de              ; Move to next row
        pop bc                  ; Restore row counter
        djnz board_row          ; Repeat for all rows

        ret
