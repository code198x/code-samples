; ----------------------------------------------------------------------------
; Print Two Digits
; ----------------------------------------------------------------------------
; A = number (0-99), B = row, C = column (will advance by 2)
; Prints number as two digits

print_two_digits:
            push    bc

            ; Calculate tens digit
            ld      d, 0            ; Tens counter
.ptd_tens:
            cp      10
            jr      c, .ptd_print
            sub     10
            inc     d
            jr      .ptd_tens

.ptd_print:
            push    af              ; Save units digit

            ; Print tens digit
            ld      a, d
            add     a, '0'
            call    print_char
            inc     c

            ; Print units digit
            pop     af
            add     a, '0'
            call    print_char
            inc     c

            pop     bc
            ret
