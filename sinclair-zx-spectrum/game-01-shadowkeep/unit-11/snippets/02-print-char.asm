; Print a character to screen memory using the ROM's built-in font.
; The character set lives at $3C00 in ROM — 8 bytes per character.

; Entry: A = character (32-127), DE = screen address (pixel row 0)
; Exit:  DE advanced to next column (E incremented)

print_char:
            push    de              ; Save screen position
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl          ; HL = character × 8
            ld      bc, $3c00
            add     hl, bc          ; HL = address in ROM font

            ld      b, 8
.pchar:     ld      a, (hl)         ; Read font pixel row
            ld      (de), a         ; Write to screen
            inc     hl              ; Next font byte
            inc     d               ; Next pixel row (INC D = +256)
            djnz    .pchar

            pop     de              ; Restore original screen address
            inc     e               ; Move to next column
            ret
