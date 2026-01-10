; Board positioning constants
; Using EQU makes code readable and easy to adjust

BOARD_SIZE  equ 8           ; 8×8 playing area
BORDER_SIZE equ 10          ; 10×10 including frame

; Centre the board on the 32×24 screen
; Board is 10 cells wide with border, so:
; Left margin = (32 - 10) / 2 = 11
; Top margin = (24 - 10) / 2 = 7

BOARD_TOP   equ 8           ; First playable row
BOARD_LEFT  equ 12          ; First playable column
BORDER_TOP  equ 7           ; Border starts here
BORDER_LEFT equ 11          ; Border starts here
