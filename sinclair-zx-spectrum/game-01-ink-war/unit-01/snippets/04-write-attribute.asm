; Write an attribute byte to screen
; Attribute memory starts at $5800
; Each byte = one 8x8 pixel cell

        ld hl, $5800        ; Point HL to first attribute cell
        ld a, %00010111     ; Red paper, white ink
        ld (hl), a          ; Write to memory

        ; Move to next cell
        inc hl              ; HL now points to second cell
        ld a, %00001110     ; Blue paper, yellow ink
        ld (hl), a          ; Write to memory
