; Results screen positions
; Centre everything for a clean, dedicated results display

RESULT_WINNER_ROW equ 6       ; Winner message at top
RESULT_WINNER_COL equ 11
RESULT_SCORES_ROW equ 12      ; Scores in middle
RESULT_P1_COL     equ 8       ; Left side for P1
RESULT_P2_COL     equ 18      ; Right side for P2
RESULT_MARGIN_ROW equ 16      ; Win margin below scores
RESULT_MARGIN_COL equ 9
RESULT_PROMPT_ROW equ 20      ; "Press any key" at bottom
RESULT_PROMPT_COL equ 9

; Messages for results screen
msg_red:        defb "RED:", 0
msg_blu:        defb "BLU:", 0
msg_won_by:     defb "WON BY", 0
msg_cells:      defb "CELLS", 0
msg_tied:       defb "TIED AT 32 EACH!", 0

; Variable to store win margin
win_margin:     defb 0
