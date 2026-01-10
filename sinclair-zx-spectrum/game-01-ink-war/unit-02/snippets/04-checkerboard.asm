; Draw a checkerboard: alternate colours based on position
; XOR row with column - if result is odd, use colour A; else colour B

draw_checkerboard:
        ld hl, ATTR_START + (8 * 32) + 12   ; Start at row 8, column 12
        ld d, 0             ; Row counter

checker_row:
        ld e, 0             ; Column counter

checker_col:
        ld a, d             ; Get row number
        xor e               ; XOR with column number
        and 1               ; Check if result is odd
        jr z, use_blue
        ld a, %00010000     ; Red paper
        jr store_it
use_blue:
        ld a, %00001000     ; Blue paper

store_it:
        ld (hl), a          ; Write to screen
        inc hl              ; Next column
        inc e
        ld a, e
        cp 8                ; Done 8 columns?
        jr nz, checker_col

        ld bc, 24           ; Skip to next row (32 - 8 = 24)
        add hl, bc
        inc d               ; Next row
        ld a, d
        cp 8                ; Done 8 rows?
        jr nz, checker_row
        ret
