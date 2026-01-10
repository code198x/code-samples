; Winner codes
WINNER_P1   equ 1           ; Player 1 wins
WINNER_P2   equ 2           ; Player 2 wins
WINNER_DRAW equ 0           ; Draw - scores equal

; Winner message position
WINNER_ROW  equ 20          ; Row for winner message
WINNER_COL  equ 11          ; Starting column

; Variables
winner:     defb 0          ; Who won

; Messages (null-terminated)
msg_red_wins:   defb "RED WINS!", 0
msg_blu_wins:   defb "BLU WINS!", 0
msg_draw:       defb "  DRAW!  ", 0
