; Attribute colours (FBPPPIII format)
EMPTY_ATTR  equ     %00111000       ; White paper, black ink (empty cell)
CURSOR_ATTR equ     %10111000       ; White paper, black ink + FLASH
P1_ATTR     equ     %01010000       ; Red paper, black ink + BRIGHT (Player 1)
P2_ATTR     equ     %01001000       ; Blue paper, black ink + BRIGHT (Player 2)
P1_CURSOR   equ     %11010000       ; Red paper + FLASH (Player 1 cursor on own cell)
P2_CURSOR   equ     %11001000       ; Blue paper + FLASH (Player 2 cursor on own cell)
