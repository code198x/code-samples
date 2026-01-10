; Board state array: 64 bytes tracking who owns each cell
; 0 = empty, 1 = Player 1, 2 = Player 2

board_state:    defs 64, 0      ; All cells start empty

; Index calculation: row × 8 + column
; Cell (2,5) = 2 × 8 + 5 = 21
; board_state + 21 holds the owner of that cell

current_player: defb 1          ; Whose turn (1 or 2)
