; Print a single character to screen
; Input: A = ASCII character, B = row (0-23), C = column (0-31)
; Uses ROM character set at $3D00

CHAR_ROM    equ $3D00       ; Character set in ROM

print_char:
        push af             ; Save character
        push bc             ; Save row/col

        ; Calculate screen address for character row B, column C
        ; Spectrum screen layout:
        ; High byte: 010TT000 where TT = row/8
        ; Low byte:  RRRCCCCC where RRR = row%8, CCCCC = column

        ; Build high byte: $40 + (row/8)*8
        ld a, b             ; Get row
        and %00011000       ; Keep (row/8)*8 in bits 3-4
        or %01000000        ; Add $40 base
        ld h, a

        ; Build low byte: (row%8)*32 + column
        ld a, b             ; Get row again
        and %00000111       ; row % 8
        rrca                ; Shift to bits 5-7
        rrca
        rrca                ; Now in bits 5,6,7
        or c                ; Add column
        ld l, a

        ; HL now points to first pixel line of character cell
        pop bc              ; Restore row/col
        pop af              ; Get character back
        push hl             ; Save screen address

        ; Character address = $3D00 + (char - 32) * 8
        sub 32              ; Characters start at space (32)
        ld l, a
        ld h, 0
        add hl, hl          ; * 2
        add hl, hl          ; * 4
        add hl, hl          ; * 8
        ld de, CHAR_ROM
        add hl, de          ; HL = character data address

        ex de, hl           ; DE = char data
        pop hl              ; HL = screen address

        ; Copy 8 bytes (8 pixel lines of character)
        ld b, 8
print_char_loop:
        ld a, (de)
        ld (hl), a
        inc de
        inc h               ; Next pixel line (add $100)
        djnz print_char_loop

        ret
