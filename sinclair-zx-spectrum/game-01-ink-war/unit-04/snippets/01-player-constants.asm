; Player state constants
EMPTY       equ 0           ; Cell is unclaimed
PLAYER1     equ 1           ; Cell belongs to Player 1
PLAYER2     equ 2           ; Cell belongs to Player 2

; Attribute colours for each state
; Bright colours stand out against the white board
EMPTY_ATTR  equ %00111000   ; White paper, black ink
P1_ATTR     equ %01010000   ; Bright red paper, black ink
P2_ATTR     equ %01001000   ; Bright blue paper, black ink

; Red vs Blue - classic rivals
; The bright bit makes them vivid and distinct
