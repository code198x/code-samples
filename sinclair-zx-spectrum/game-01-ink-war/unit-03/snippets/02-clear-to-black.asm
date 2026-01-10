; Clear entire screen to black
; This gives us a clean slate to draw the board on

clear_screen:
        ld hl, ATTR_START       ; $5800
        ld de, ATTR_START + 1   ; $5801
        ld bc, 768 - 1          ; 767 bytes to copy
        ld (hl), %00000000      ; Black paper, black ink
        ldir                    ; Fill all attributes
        ret
