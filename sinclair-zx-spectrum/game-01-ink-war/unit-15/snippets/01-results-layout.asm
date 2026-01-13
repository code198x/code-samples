; Results screen positions
GAMEOVER_ROW equ    18              ; "GAME OVER" header
GAMEOVER_COL equ    11              ; (32-9)/2 = 11.5
FINAL_ROW   equ     20              ; Final score row
FINAL_P1_COL equ    8               ; "P1: nn"
FINAL_P2_COL equ    20              ; "P2: nn"
WINNER_ROW  equ     22              ; Winner announcement
WINNER_COL  equ     10              ; Centred
MARGIN_ROW  equ     23              ; "BY nn CELLS"
MARGIN_COL  equ     11

; Messages for results screen
msg_gameover:   defb    "GAME OVER", 0
msg_final:      defb    "FINAL SCORE", 0
msg_by:         defb    "BY ", 0
msg_cells:      defb    " CELLS", 0
