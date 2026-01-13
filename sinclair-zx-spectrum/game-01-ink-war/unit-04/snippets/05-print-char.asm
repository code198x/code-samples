; ----------------------------------------------------------------------------
; Print Character
; ----------------------------------------------------------------------------
; A = ASCII character (32-127), B = row (0-23), C = column (0-31)
; Writes character directly to display file using ROM character set

print_char:
            push    bc
            push    de
            push    hl
            push    af

            ; Calculate character data address: CHAR_SET + char*8
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl          ; HL = char * 8
            ld      de, CHAR_SET
            add     hl, de          ; HL = source address

            push    hl              ; Save character data address

            ; Calculate display file address
            ; Screen address: high byte varies with row, low byte = column
            ld      a, b            ; A = row (0-23)
            and     %00011000       ; Get which third (0, 8, 16)
            add     a, $40          ; Add display file base high byte
            ld      d, a

            ld      a, b            ; A = row
            and     %00000111       ; Get line within character row
            rrca
            rrca
            rrca                    ; Shift to bits 5-7
            add     a, c            ; Add column
            ld      e, a            ; DE = screen address

            pop     hl              ; HL = character data

            ; Copy 8 bytes (8 pixel rows of character)
            ld      b, 8
.pc_loop:
            ld      a, (hl)
            ld      (de), a
            inc     hl
            inc     d               ; Next screen line (add 256)
            djnz    .pc_loop

            pop     af
            pop     hl
            pop     de
            pop     bc
            ret
