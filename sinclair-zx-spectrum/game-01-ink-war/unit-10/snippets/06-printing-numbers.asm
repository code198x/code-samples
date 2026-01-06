;───────────────────────────────────────
; Print a number (0-99)
; Input: A = number to print
;───────────────────────────────────────
print_number:
        ld c, a                 ; Save original
        ld b, 0                 ; Tens counter

.count_tens:
        cp 10
        jr c, .print_digits
        sub 10
        inc b
        jr .count_tens

.print_digits:
        ld c, a                 ; Save units in C

        ; Print tens if non-zero OR if we need it for padding
        ld a, b
        or a
        jr z, .print_units      ; No tens digit
        add a, '0'
        rst $10

.print_units:
        ld a, c
        add a, '0'
        rst $10
        ret
