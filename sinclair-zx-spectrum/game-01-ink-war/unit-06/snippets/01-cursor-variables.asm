; Cursor position variables
; These track where the cursor is on the board (0-7 range)

cursor_row: defb 0          ; Current row (0 = top, 7 = bottom)
cursor_col: defb 0          ; Current column (0 = left, 7 = right)

; The cursor starts at (3,3) - centre of the board
; Each position maps to a cell on the game board
