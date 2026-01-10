; Constants define memory addresses and values we'll use throughout
; Using names instead of numbers makes code readable and maintainable

ATTR_START  equ $5800       ; Attribute memory starts here
BORDER_PORT equ $FE         ; Border colour port

; The Spectrum has 8 colours (0-7)
BLACK       equ 0
BLUE        equ 1
RED         equ 2
MAGENTA     equ 3
GREEN       equ 4
CYAN        equ 5
YELLOW      equ 6
WHITE       equ 7
