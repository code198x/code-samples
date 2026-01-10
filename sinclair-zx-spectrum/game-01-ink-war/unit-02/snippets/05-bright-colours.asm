; BRIGHT colours vs normal colours
; The BRIGHT bit (bit 6) makes colours more vivid

BRIGHT      equ %01000000   ; Bit 6

; Normal red paper:
        ld a, %00010000     ; Paper = RED (2) in bits 5-3

; Bright red paper:
        ld a, %01010000     ; Same + BRIGHT bit set
        ; Or use OR:
        ld a, %00010000
        or BRIGHT           ; Add the bright bit

; The Spectrum has 15 colours total:
; 8 normal (0-7) + 7 bright (1-7 bright, black stays black)
