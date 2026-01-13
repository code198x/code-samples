; Game states
STATE_EMPTY equ     0
STATE_P1    equ     1
STATE_P2    equ     2

; ----------------------------------------------------------------------------
; Variables
; ----------------------------------------------------------------------------

cursor_row:     defb    0
cursor_col:     defb    0
key_pressed:    defb    0
current_player: defb    1           ; 1 = Player 1 (Red), 2 = Player 2 (Blue)
board_state:    defs    64, 0       ; 64 bytes, all initialised to 0
