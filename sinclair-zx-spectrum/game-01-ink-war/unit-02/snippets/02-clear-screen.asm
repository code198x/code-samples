; Clear all attributes using LDIR (block copy)
; This is much faster than a loop

clear_attributes:
        ld hl, ATTR_START   ; Source address ($5800)
        ld de, ATTR_START+1 ; Destination (one byte ahead)
        ld bc, ATTR_SIZE-1  ; Count: 767 bytes
        ld (hl), %00111000  ; Set first byte: white paper, black ink
        ldir                ; Copy (HL) to (DE), repeat BC times
        ret

; LDIR copies the first byte to the second position,
; then the second to the third, and so on.
; Result: all 768 bytes become the same value.
