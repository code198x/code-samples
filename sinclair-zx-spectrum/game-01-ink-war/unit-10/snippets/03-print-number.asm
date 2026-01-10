; Print two-digit number (0-64)
; Input: A = number, B = row, C = starting column

; Scratch variables
tens_digit:     defb 0
units_digit:    defb 0
print_row:      defb 0
print_col:      defb 0

print_two_digit:
        ; Save position in scratch variables
        ld (print_row), a       ; Temporarily store number
        ld a, b
        ld (units_digit), a     ; Row
        ld a, c
        ld (tens_digit), a      ; Column

        ; Calculate tens and units digits
        ld a, (print_row)       ; Get number back
        ld b, 0                 ; Tens counter

        cp 10
        jr c, td_no_tens

td_calc_tens:
        sub 10
        inc b
        cp 10
        jr nc, td_calc_tens

td_no_tens:
        ; B = tens digit, A = units digit
        ld (print_col), a       ; Save units
        ld a, b
        ld (print_row), a       ; Save tens

        ; Restore position
        ld a, (units_digit)     ; Row
        ld b, a
        ld a, (tens_digit)      ; Column
        ld c, a

        ; Print tens digit (or space if zero)
        ld a, (print_row)       ; Get tens
        or a
        jr z, td_space

        add a, '0'              ; Convert to ASCII
        call print_char
        jr td_units

td_space:
        ld a, ' '
        call print_char

td_units:
        ; Print units digit
        ld a, (units_digit)     ; Row
        ld b, a
        ld a, (tens_digit)      ; Column
        inc a                   ; Next column
        ld c, a

        ld a, (print_col)       ; Get units
        add a, '0'              ; Convert to ASCII
        call print_char

        ret
