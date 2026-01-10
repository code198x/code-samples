; Boundary checking prevents cursor leaving the board

; Top boundary (row 0):
        ld a, (cursor_row)
        or a                ; Sets Z flag if A is zero
        jr z, cant_go_up    ; If zero, can't move up

; Bottom boundary (row 7):
        ld a, (cursor_row)
        cp 7                ; Compare with 7
        jr z, cant_go_down  ; If equal, can't move down

; Left boundary (column 0):
        ld a, (cursor_col)
        or a
        jr z, cant_go_left

; Right boundary (column 7):
        ld a, (cursor_col)
        cp 7
        jr z, cant_go_right

; The check happens BEFORE modifying the position
; If at boundary, we skip the modification entirely
